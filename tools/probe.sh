#!/usr/bin/env bash
# probe.sh —— 跑探针并【断言不留痕】（reviewer 刺六 2026-10-11：把"不留痕"从纪律变机检）
#
# ★ 为什么：钩子会自动重生 INDEX/基线 ⇒ **探针的爆炸半径被放大**（2026-10-11 的残留正如此，
#   而更狠的一次是：探针的清理动作 `git checkout -- decisions/` 把一次【宪法修正静默回滚】）。
#   ⇒ 结构化：探针跑完立刻断言"工作树与暂存区与开跑前逐字相同"。
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2
snap(){ { git status --porcelain; echo "--- staged ---"; git diff --cached --name-only; } 2>/dev/null; }
before=$(snap)
bash tools/validate.sh "$@"; rc=$?
after=$(snap)
if [ "$before" != "$after" ]; then
  echo "" >&2
  echo "★ 探针留下了痕迹 —— 开跑前后工作树/暂存区不同（探针必须不留痕）:" >&2
  diff <(printf '%s\n' "$before") <(printf '%s\n' "$after") | head -12 >&2
  echo "  ⇒ 处置：核对并还原（**还原也要断言生效** —— 别让清理动作回滚合法成果）" >&2
  exit 3
fi
exit $rc
