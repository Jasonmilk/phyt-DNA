#!/usr/bin/env bash
# check-pool.sh —— 【全池一致性】扫描（reviewer ③ 的答案 · 2026-10-11）
#
# ★ 为什么存在（实测）：引擎按【文件】判（timing:post：写谁判谁）⇒
#   **存在于闸门出生之前、或此后无人再写的违规 ⇒ 永远不被判**。
#   实证：配对闸门出生时 pair 已断（lesson=accepted 而新 ADR 已声明 supersedes 它），
#   此后三笔（5208c23 / 7a044c8 / b210819）无人再写那两份文件 ⇒ **三个 commit 静默通过**。
# ⇒ 本步把【全池】一次喂给引擎，补上那个盲区。
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
# ★ 参数化目标目录（reviewer ① · 2026-10-11）：原先硬读 decisions/ ⇒ **隔离夹具根本没被读**（夹具逃逸）。
#   修法：`check-pool.sh [dir]`（默认 decisions）⇒ 夹具目录能被真读 ⇒ 两侧可验。
DIR="${1:-decisions}"
files=$(ls "$DIR"/ADR-*.md 2>/dev/null | LC_ALL=C tr '\n' ' ')
n=$(printf '%s' "$files" | wc -w | tr -d ' ')
payload=$(python3 - "$@" <<'PY'
import json,sys
paths=[p for p in (' '.join(sys.argv[1:])).split() if p]
print(json.dumps({"tool":"Write","paths":paths}))
PY
)
out=$(PHYT_DECISIONS="$DIR" PHYT_QUIET=1 bash tools/validate.sh --timing post 2>&1 <<< "$payload"); rc=$?
if [ "$rc" = 2 ]; then
  echo "★ 全池有违规（按文件判会漏掉的那些）:"
  printf '%s\n' "$out" | grep -E '违规' | head -12 | sed 's/^/    /'
  exit 1
fi
echo "OK: 全池 $n 份 ADR（目录 ${DIR}）一致 —— 扫描面 = **全部 timing:post 闸门**（不止 pair # 见各 ADR 的 applies-to）"
