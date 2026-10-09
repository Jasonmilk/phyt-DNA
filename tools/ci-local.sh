#!/usr/bin/env bash
# ci-local.sh — 逐字复现 .github/workflows/phyt.yml 的每一步（第三十五条的机械落地）。
#
# 为什么存在：2026-10-09 我因为「本地绿」就推送，而 CI 的 step 2/5（spec-lint）与 step 4（全仓扫描）
# 都是红的 ⇒ 每次 push 都触发一次失败通知。根因不是那两处代码，是【我从没在本地复现 CI】：
#   · 我跑的是【自己的工具】（--probe-all），CI 跑的是【它自己的工作流】——两者不等价
#   · spec-lint 禁止 check: 里出现 `2>/dev/null`（静默失败=伪证），我在三处写了
#   · 我自己的夹具【字面包含】了它要注入的违规，于是被 step 4 扫到
# ⇒ 判据：推送前跑它；五步全 0 才算"本地绿"。
#
# Usage: bash tools/ci-local.sh
set -uo pipefail
# ★ 复现【不应改动仓库】：探针会写 kind:probe 账本 ⇒ 让它写进临时目录，
# 否则每跑一次 ci-local 都弄脏 ledger/hits-2026.jsonl（实测过）。
export PHYT_LEDGER="$(mktemp -d)"
trap 'rm -rf "$PHYT_LEDGER"' EXIT
fail=0
step(){ printf '  %-42s ' "$1"; }

step "1 · 资产完整性"; if ./tools/check-baseline.sh >/dev/null 2>&1; then echo OK; else echo "★ RED"; fail=1; fi
step "2 · spec-lint";  if ./tools/spec-lint.sh docs/PROTECTION.md >/dev/null 2>&1; then echo OK; else echo "★ RED"; fail=1; fi

step "3 · 全部闸门能力心跳"
f3=0
for id in $(ls decisions/*.md | xargs -n1 basename | sed 's/\.md$//'); do
  grep -q '^hard: true$' "decisions/$id.md" || continue
  grep -q '^status: deprecated' "decisions/$id.md" && continue
  ./tools/validate.sh --probe "$id" >/dev/null 2>&1 || { echo; echo "      ★ $id"; f3=1; }
done
[ "$f3" = 0 ] && echo "OK（$(grep -l '^hard: true$' decisions/ADR-*.md | wc -l | tr -d ' ') 条）" || { echo "      ★ RED"; fail=1; }

step "4 · 全仓违规扫描（timing:post）"
f4=0
for f in $(git ls-files '*.md' '*.py' '*.sh' '*.yml'); do
  printf '{"tool":"Write","paths":["%s"]}\n' "$f" | ./tools/validate.sh --timing post >/dev/null 2>&1
  [ $? = 2 ] && { echo; echo "      ★ 违规: $f"; f4=1; }
done
[ "$f4" = 0 ] && echo "OK" || { echo "      ★ RED"; fail=1; }

step "5 · spec-lint（必须真实可红）"; if ./tools/spec-lint.sh docs/PROTECTION.md >/dev/null 2>&1; then echo OK; else echo "★ RED"; fail=1; fi

echo
if [ "$fail" = 0 ]; then echo "CI-LOCAL: 五步全绿 ⇒ GitHub Actions 会过（不再有失败通知）"; exit 0; fi
echo "CI-LOCAL: 有步骤红 ⇒ **不要推送**（推送会触发失败通知）" >&2; exit 1
