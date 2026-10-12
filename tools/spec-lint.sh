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

# ★ 2026-10-12（YB 3 · 净 0）：两条断言 —— 专治【死判据】与【红不知道是哪一条】
#   ① 每个 ADR 的 check 体（剥 2 空格后）必须是合法 bash：实测教训 —— 续行/多行管道让一条判据
#      【整段不跑】，而它照绿（哑失败第 6 类）；`bash -n` 当场抓住。
#   ② 声明了编号判据的门（正文有 `| ① |` 形状的表）⇒ check 体里必须带同样的编号前缀
#      （红要能一眼指出是哪一条判据，而不是笼统"README 有问题"）。
dead=""; unnum=""
for f in decisions/ADR-*.md; do
  grep -q '^check: |' "$f" || continue
  body=$(awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$f" | sed 's/^  //')
  printf '%s' "$body" | bash -n 2>/tmp/bn.$$.err || dead="$dead $(basename "$f")"
  if grep -q '^| ① |' "$f"; then
    for n in ① ② ③ ④; do
      grep -q "^| $n |" "$f" || continue
      printf '%s' "$body" | grep -q "$n" || unnum="$unnum $(basename "$f"):$n"
    done
  fi
done
rm -f /tmp/bn.$$.err
if [ -n "$dead" ]; then red "check 体不是合法 bash（剥 2 空格后 ⇒ 该判据整段不跑＝死判据）:$dead"; else grn "所有 check 体（剥 2 空格后）都是合法 bash"; fi
if [ -n "$unnum" ]; then red "声明了编号判据但 check 体缺对应编号:$unnum"; else grn "编号判据的 check 体都带编号前缀"; fi

# ★ 2026-10-12（裁定 2 · 净 0）：**裸匹配断言** —— ADR 的 check 体里 grep 前言字段必须**行首锚定**（`^field:`）。
#   实测教训：`'status: deprecated' in s` 把"正文里提到 deprecated"当成"自己是 deprecated" ⇒ 多建 4 份归档记录。
#   字段面：id / status / supersedes / hard / timing / applies-to / revisit-on / expires-on / risk / origin / check。
bare=""
for f in decisions/ADR-*.md; do
  grep -q '^check: |' "$f" || continue
  body=$(awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$f" | sed 's/^  //')
  bad=$(printf '%s' "$body" | grep -nE "grep[^|]*'(id|status|supersedes|hard|timing|applies-to|revisit-on|expires-on|risk|origin|check): " | grep -v '\^' )
  if [ -n "$bad" ]; then bare="$bare $(basename "$f")"; fi
done
if [ -n "$bare" ]; then red "check 体里有未行首锚定的前言字段匹配（裸匹配 = 会被正文里的同名文字骗）:$bare"; else grn "前言字段匹配都行首锚定"; fi

echo
[ "$fail" = 0 ] && { echo "spec-lint: PASS"; exit 0; }
echo "spec-lint: BLOCK（规范自身未过闸门）" >&2
exit 2
