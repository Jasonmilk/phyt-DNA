#!/usr/bin/env bash
# deprecated_skip_test.sh —— 【跳过路径】的心跳（reviewer 微点② · 2026-10-11）
# ★ 为什么需要：引擎 `gates()` 里有 `grep -q '^status: deprecated' && continue` ——
#   这条【跳过逻辑】此前只有实现、没有心跳：没人证明"退役的闸门真的不再开火"。
#   若它坏掉（不再跳过），退役的闸门会继续拦人，而**没有任何东西会报红**。
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
fail=0
# ★ 注入入口 = 引擎自己的环境变量 `PHYT_DECISIONS`（`DEC_DIR="${PHYT_DECISIONS:-decisions}"`）
#   —— 【勿用不存在的 `--adr-dir`】：那会让引擎读真的 decisions/，测试变成**假绿**
#   （本测试的第一版正是如此，被它自己的对照组抓出："对照组都不开火 ⇒ 测试无牙"）。
# ① 退役闸门 + 会红的 check ⇒ 引擎【应当跳过】它
cat > "$TMP/ADR-99999999-retired-probe.md" <<'EOF2'
---
id: ADR-99999999-retired-probe
status: deprecated
hard: true
applies-to: ["*"]
timing: post
check: |
  echo "这个闸门已退役，不该再开火"
EOF2
out=$(PHYT_DECISIONS="$TMP" PHYT_QUIET=1 bash tools/validate.sh --timing post 2>&1 <<< '{"tool":"Write","paths":["README.md"]}')
rc=$?
if printf '%s' "$out" | grep -q "已退役，不该再开火"; then
  echo "  FAIL 退役闸门仍在开火（跳过逻辑坏了）"; fail=1
else
  echo "  ok   退役闸门被跳过（跳过路径活着）"
fi
# ② 对照：同形状但 status: accepted ⇒ 必须开火（否则测试自己没牙）
sed 's/^status: deprecated/status: accepted/' "$TMP/ADR-99999999-retired-probe.md" > "$TMP/ADR-99999998-live-probe.md"
out2=$(PHYT_DECISIONS="$TMP" PHYT_QUIET=1 bash tools/validate.sh --timing post 2>&1 <<< '{"tool":"Write","paths":["README.md"]}')
if printf '%s' "$out2" | grep -q "已退役，不该再开火"; then
  echo "  ok   对照组（accepted）确实开火 ⇒ 测试有牙"
else
  echo "  FAIL 对照组都不开火 ⇒ 测试无牙（判据自己死了）"; fail=1
fi
[ "$fail" = 0 ] && { echo "deprecated_skip_test: PASS（跳过与开火两侧都活着）"; exit 0; }
echo "deprecated_skip_test: BLOCK" >&2; exit 1
