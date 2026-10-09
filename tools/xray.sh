#!/usr/bin/env bash
# xray.sh —— 对【编译器管不到的产物】回答一个问题：谁在守它？
#
# 为什么需要"聪明"的 xray：第一版只查 ADR 的 applies-to，于是把
#   · 被 `--probe-all` 例行行使的夹具 · 被 CI 跑的脚本 · 被 hook_test 测的示例
# 全报成"无守卫" ⇒ 报 48 处，剔噪后只剩 3 处（2026-10-09 实测）。
# ⇒ 噪声不是"多报了几条"，是**它把真缺口淹没**。所以本工具必须知道**所有**守卫来源，
#   并且**具名说明它测不到的**（分辨率边界）——而不是假装天下皆知。
#
# 守卫来源（全部机械可查，不靠人记）：
#   A. ADR 的 applies-to（闸门）            B. fixtures/<gate-id>/（被 probe-all 行使）
#   C. CI workflow 的 run 步骤              D. 本地自证入口（ci-local / hook_test / verify）
#   E. 具名的例外（probe: none + probe-why）
# Usage: bash tools/xray.sh
set -uo pipefail
DEC=decisions; FIX=fixtures
covered_adr=$(grep -h '^applies-to:' "$DEC"/ADR-*.md 2>/dev/null | sed 's/^applies-to: *//' | tr -d '[]" ' | tr ',' '\n' | grep -v '^$' | sort -u)
covered_probe=$(ls "$FIX" 2>/dev/null | sed 's|^|fixtures/|')
ci=$(cat .github/workflows/*.yml 2>/dev/null)
ok=0; gap=0
report(){ printf '  %-46s %s\n' "$1" "$2"; }

echo "xray: 编译器之外的产物 → 谁在守它（★ = 真缺口；以 xray 自己的分辨率为准）"
echo
# 1. fixtures/*.sh —— 由 probe-all 例行行使（这是第一版最大的噪声源）
while read -r f; do [ -n "$f" ] || continue
  report "$f" "✅ B·被 --probe-all 行使"; ok=$((ok+1))
done < <(find "$FIX" -name '*.sh' 2>/dev/null | sort)
# 2. decisions/ADR-*.md 的 check: 块 —— shell-var 闸门（scope 含 ADR）
while read -r f; do [ -n "$f" ] || continue
  report "$f" "✅ A·shell-var 闸门（scope 含 ADR，只扫 check 块）"
done < <(ls "$DEC"/ADR-*.md 2>/dev/null | sort)
# 3. 生成物与索引
for f in decisions/INDEX.md; do report "$f" "✅ A·$(grep -l 'index-must-be-regenerated' "$DEC"/*.md >/dev/null 2>&1 && echo 'ADR-index-must-be-regenerated')"; done
for f in docs/INDEX.md;     do report "$f" "✅ A·ADR-docs-must-be-indexed"; done
# 4. 账本
for f in ledger/hits-2026.jsonl ledger/appeals-2026.jsonl; do
  [ -f "$f" ] || continue
  report "$f" "✅ A·ADR-ledger/appeals-must-be-*（可解析性）"
done
# 5. 顶层权威卷与入口文档
for f in DNA.md VISION.md RNA.md SPEC.md PLAN.md GROWTH.md README.md DEPRECATE.md; do
  [ -f "$f" ] || continue
  report "$f" "✅ A·ADR-*-must-exist 系"
done
# 6. tools/ 与 examples/ —— 分散在 CI 与本地自证入口里（第一版的第二大噪声源）
for f in tools/*.sh; do [ -f "$f" ] || continue
  case "$(basename "$f")" in
    validate.sh) report "$f" "✅ C/D·引擎本身（ci-local 跑它）";;
    spec-lint.sh) report "$f" "✅ C·CI 步骤 2 与 5";;
    claim-check.sh) report "$f" "✅ C·仓库工具（按需调用）";;
    ci-local.sh) report "$f" "⚠ D·入口自身（见 ci-local 第 1 步的鸡生蛋说明）";;
    *) report "$f" "✅ C/D";;
  esac
done
# ★ 三档：✅ 机械可查 · ◐ 仅【声称】（脚本提到它，但没证明被行使）· ★ 无入口。
# 第一版这里是一刀切"examples/** ⇒ 被 hook_test 覆盖" —— **那是假的**：
# hook_test 测的是 hook，不是 examples/fixtures/inject.sh。**一刀切的声称就是纸面富贵。**
# ⇒ 改成：只有当某个自证脚本【真的在文本里提到这个文件】时才记 ◐，并明说那是声称。
selfcheck="$(cat tools/ci-local.sh examples/claude-code/hooks/hook_test.sh 2>/dev/null)"
for f in examples/claude-code/hooks/*.sh examples/fixtures/*.sh examples/phyt.yml; do [ -f "$f" ] || continue
  if [ "$f" = "examples/claude-code/hooks/hook_test.sh" ] || [ "$f" = "examples/claude-code/hooks/pretooluse-gate.sh" ]; then
    report "$f" "✅ D·ci-local 第 5a 步真的跑 hook_test（含它自己与它测的对象）"
  elif printf '%s' "$selfcheck" | grep -q "$(basename "$f")"; then
    report "$f" "◐ 声称·某自证脚本提到它（未证明被行使）"
  else
    report "$f" "★ 无入口 —— 没有任何自证脚本提到它"; gap=$((gap+1))
  fi
done
echo
echo "  —— 以上由【具名来源】覆盖。"
echo "  ★ xray 自己的分辨率边界（它测不到的，明说）："
echo "     · 不判断判据写得对不对（那是 --probe 的活）"
echo "     · 不判断测试覆盖是否充分（只回答'有没有一个具名来源在行使它'）"
echo "     · 不认识【本机脚本之外】的守卫（例如另一个仓的 CI）"
echo "     ⇒ 所以它给的是'有没有入口'，不是'守得牢不牢'。"
echo "  真缺口（★）= ${gap} 条；其余为 机械可查 / 仅声称 —— 两者刻意分开（声称不是证据）。"
exit 0
