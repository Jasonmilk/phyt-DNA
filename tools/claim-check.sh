#!/usr/bin/env bash
# claim-check.sh —— 报告自查：每个"已实测"断言，账本里有记录吗？
# 这是把审查者的方法论对准我们自己：规范天天查 agent，谁查规范？
set -uo pipefail
DOC="${1:-}"; LED="${2:-ledger/hits-2026.jsonl}"
[ -f "$DOC" ] || { echo "用法: claim-check.sh <报告.md> [ledger]" >&2; exit 2; }
[ -f "$LED" ] || { echo "缺账本: $LED" >&2; exit 2; }

fail=0
echo "claim-check: $DOC"

# 关键词 → 该断言在账本中应能找到的证据关键词
declare -A EVID=(
  ["真实拦截"]="拦截|block"
  ["永绿"]="永绿|探针|腐化"
  ["冷存"]="冷存|deprecated"
  ["hook"]="hook"
  ["真实重构"]="重构"
  ["override"]="override"
  ["心跳"]="心跳"
)

while IFS= read -r line; do
  # 抓含"已实测/真实/实测"的行
  printf '%s\n' "$line" | grep -qE '已实测|真实|实测' || continue
  claim=$(printf '%s' "$line" | sed 's/^[[:space:]]*//' | cut -c1-60)
  # 找出该行涉及哪个关键词
  found_ev=0
  for k in "${!EVID[@]}"; do
    printf '%s\n' "$line" | grep -q "$k" || continue
    if grep -qE "${EVID[$k]}" "$LED"; then found_ev=1; fi
  done
  if [ "$found_ev" = 0 ]; then
    printf '  ⚠ 无账本支撑: %s\n' "$claim" >&2
    fail=$((fail+1))
  fi
done < <(grep -nE '已实测|实测|真实' "$DOC")

echo
if [ "$fail" = 0 ]; then echo "claim-check: PASS（所有断言均可在账本中定位）"; exit 0; fi
printf 'claim-check: %s 条断言无账本支撑 —— 要么去跑，要么改标"未验证"\n' "$fail" >&2
exit 2
