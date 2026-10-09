#!/usr/bin/env bash
# check-baseline.sh —— 闸门资产完整性：decisions/ 与 tools/ 不得被就地篡改
# ADR-0004 的检测器：让"禁止制造通过的假象"从祈祷变成能红的断言
set -uo pipefail
BASE="tools/baseline.sha256"
RED(){ printf '  RED  %s\n' "$1" >&2; fail=1; }
fail=0

# DNA.md 也在 scope 内（P9 元闸门的第一例）：'DNA 不可改'由【已有的资产基线】守，不新增机制。
calc(){ find decisions tools DNA.md -type f \( -name '*.md' -o -name '*.sh' \) -print0 \
        | sort -z | xargs -0 sha256sum | grep -v 'baseline.sha256'; }

case "${1:-}" in
  --update) calc > "$BASE"; echo "基线已更新: $(wc -l < "$BASE") 个文件"; exit 0 ;;
  # ★ --scope：把【真实 scope 输出】给出去，供元闸门断言"机制在位"。
  # 元闸门必须问这个输出，**不得 grep 本文件的源码文本** —— 否则又盯错对象（第 29 条同源）。
  --scope) calc | awk '{print $2}'; exit 0 ;;
esac

[ -f "$BASE" ] || { echo "无基线，先跑 --update" >&2; exit 2; }

echo "check-baseline: 校验闸门资产未被就地篡改"
# 1. 已有文件被改
while read -r sum file; do
  [ -f "$file" ] || { RED "资产被删除: $file"; continue; }
  now=$(sha256sum "$file" | cut -d' ' -f1)
  [ "$sum" = "$now" ] || RED "资产被就地修改（ADR-0004 违规）: $file"
done < "$BASE"
# 2. 新增未登记文件
while read -r f; do
  grep -q " $f\$" "$BASE" || RED "资产未登记（须走 ADR）: $f"
done < <(find decisions tools -type f \( -name '*.md' -o -name '*.sh' \) | grep -v baseline)

[ "$fail" = 0 ] && { echo "check-baseline: PASS"; exit 0; }
echo "check-baseline: BLOCK —— ADR-0004 被违反" >&2
exit 2
