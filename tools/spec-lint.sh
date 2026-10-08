#!/usr/bin/env bash
# spec-lint.sh —— 用 phyt-DNA 自己的规则，检查 phyt-DNA 自己的规范文档
# 这是「坑变闸机」的第一次真实应用：规范自己过一遍 GAT
set -uo pipefail
SPEC="${1:-docs/PROTECTION.md}"
[ -f "$SPEC" ] || { echo "缺规范文件: $SPEC" >&2; exit 2; }

fail=0
red(){ printf '  RED  %s\n' "$1" >&2; fail=1; }
grn(){ printf '  GRN  %s\n' "$1"; }

echo "spec-lint: $SPEC"

# 闸门1：出错时的失败策略必须显式存在（这条自己在重写中消失过两次）
if grep -q 'fail-open' "$SPEC" && grep -q 'fail-closed' "$SPEC"; then
  grn "失败策略(fail-open/fail-closed)存在"
else
  red "失败策略缺失 —— 该规则已在历史重写中静默消失 ≥1 次，必须靠脚本守住"
fi

# 闸门2：三种死亡终点必须有各自承载字段
if grep -qE '^\s*(expires-on|auto-expire):' "$SPEC"; then
  grn "自动删除有承载字段"
else
  red "三种终点只有 revisit-on 一个字段 —— 「自动删除」无路由器"
fi
grep -q '^revisit-on:' "$SPEC" && grn "续期/复审有承载字段" || red "revisit-on 缺失"
grep -q '^risk:' "$SPEC" && grn "风险复审有承载字段" || red "risk 缺失"

# 闸门3：每条"官方已证实"的断言必须带可核查出处
claims=$(grep -c '已证实' "$SPEC")
links=$(grep -cE 'https?://' "$SPEC")
if [ "$claims" -gt 0 ] && [ "$links" -eq 0 ]; then
  red "声称 $claims 处「已证实」但全文 0 个链接 —— 半年后无人能查证"
else
  grn "出处登记: $claims 处断言 / $links 个链接"
fi

# 闸门4：不得承诺无证据的定量结论
if grep -qE '每增加 ?[0-9]+ ?行.*遵从度下降' "$SPEC"; then
  red "承诺了无直接证据的遵从度衰减率"
else
  grn "未承诺无证据的衰减率"
fi

# 闸门5：不得引用未获官方证实的实践
if grep -q 'lessons.md' "$SPEC" && ! grep -q '未获官方证实' "$SPEC"; then
  red "引用 lessons.md 但未标注未证实"
else
  grn "未证实项已标注"
fi

# 闸门6：check 表达式不得静默失败（EXP-E 漏报实证）
if grep -rqE '^\s+.*2>/dev/null' decisions/*.md 2>/dev/null; then
  bad=$(grep -lE '^\s+.*2>/dev/null' decisions/*.md 2>/dev/null | tr '\n' ' ')
  red "check 表达式含 2>/dev/null（静默失败=伪证）: $bad"
else
  grn "check 表达式无静默失败"
fi

# 闸门7：测试基础设施不得含全量还原（ADR-0009，五次同族现身）
# 只扫 *.sh 脚本：fixtures/README.md 等文档示例文字会合法地提及禁令本身（T0 顺带修复）
BAD=$(grep -rlE --include='*.sh' 'git checkout -- \.|git clean -fd|git stash' tools/ fixtures/ 2>/dev/null | grep -v 'spec-lint.sh')
if [ -n "$BAD" ]; then
  red "测试脚本含全量还原命令（会破坏被测物）: $(echo $BAD | tr '\n' ' ')"
else
  grn "测试脚本无全量还原命令"
fi

echo
[ "$fail" = 0 ] && { echo "spec-lint: PASS"; exit 0; }
echo "spec-lint: BLOCK（规范自身未过闸门）" >&2
exit 2
