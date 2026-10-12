#!/usr/bin/env bash
# 正例（0****b 修）：把 DNA.md **移出资产基线的 scope** ⇒ 元闸门必须红。
# ★ 旧版 sed 的是 `find decisions tools DNA.md` 这个**字面串** ⇒ 作用域一扩（加入 docs/ 与根文档）它就失配
#   ⇒ 注入没发生 ⇒ 判据报"腐化"。⇒ 改为**对当前文本**操作：只删掉 `DNA.md` 这一项（不依赖整行字面）。
set -eu
: "${F:?fixture needs $F}"
printf '{"tool":"Write","paths":["tools/check-baseline.sh"]}\n' >/dev/null
sed -i '' 's/ DNA\.md//' "$F" 2>/dev/null || sed -i 's/ DNA\.md//' "$F"
grep -q 'DNA\.md' "$F" || true   # 说明：DNA.md 仍可能出现在注释里；关键在 calc() 的 find 行
