#!/usr/bin/env bash
# regex-census.sh —— 按【调用形状】清点正则用法（不按引号抓串：那样会把散文/heredoc 也数进来，实测虚高到 40+）。
# ★ 裁定 2（2026-10-12）：**计数脚本本身必须有正样本** —— `--selftest` 用 12 条已知形状自检，
#   自检不过 ⇒ 脚本自己红（否则它就是又一个"恒绿的断言"）。
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"

SHAPES="grep +sed +egrep"   # 形状：grep 带 E 标志 · sed 带 E 标志 · egrep（grep -E 的别名）
count_one(){  # 从 stdin 读文本，输出命中的【正则调用】次数
  grep -oE '(grep|sed)[[:space:]]+(-[A-Za-z]+[[:space:]]+)*-?[A-Za-z]*E([[:space:]]|$)|egrep([[:space:]]|$)' | wc -l | tr -d ' '
}
if [ "${1:-}" = "--selftest" ]; then
  S=$(cat <<'SAMPLE'
grep -q '^## Start here' "$F"
grep -qE '^status: deprecated' "$F"
grep -oE 'tools/[a-z]+' "$F" | sort -u
sed -E 's/x/y/' "$F"
egrep 'a|b' "$F"
grep -cE '^\\|' "$F"
grep -nE '✅' "$F"
grep -vE '^$' "$F"
grep -lE 'x' docs/*.md
sed -nE '1p' "$F"
grep -qF '✅' "$F"
egrep -c 'a' "$F"
SAMPLE
)
  n=$(printf '%s' "$S" | count_one)
  echo "  计数器自检：样本里 12 条形状（含 grep -qE/-oE/-cE/-nE/-vE/-lE · sed -E/-nE · egrep ×2 · 以及不该数的 grep -q(无E) 与 grep -qF）"
  echo "  计数器数到：$n 条（期望 10：样本 12 条里 grep -q（无 E）与 grep -qF 不算正则）"
  [ "$n" = 10 ] && { echo "  ✅ 自检通过"; exit 0; } || { echo "  ★ 自检失败：计数器数到的形状与预期不符" >&2; exit 2; }
fi
TOT=0
printf '%-52s %s\n' "门（ADR）" "正则调用数"
for f in decisions/ADR-*.md; do
  awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$f" | sed 's/^  //' > /tmp/.census.$$
  n=$(count_one < /tmp/.census.$$)
  rm -f /tmp/.census.$$
  if [ "$n" != 0 ]; then printf '%-52s %s\n' "$(basename "$f" .md)" "$n"; TOT=$((TOT+n)); fi
done
echo "  ── 合计：$TOT 次正则调用"
