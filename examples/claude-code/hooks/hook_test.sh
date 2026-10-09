#!/usr/bin/env bash
# hook_test.sh —— PreToolUse 执行闸的测试（**它的第一次**）。
#
# 为什么需要：这个 hook 是 AITL 的"做"那一侧的执行闸，而它此前**没有任何测试**（x 光 2026-10-09 查出）。
# 与真夹具（fixtures/*/inject.sh）一样，它必须**被行使**——否则"闸门在"只是纸面事实。
#
# 判据形态：一行一例（输入 → 期望退出码）。**能红**：把 hook 改成 fail-open，下面多数例会红。
# 其中"非法 JSON ⇒ 2"与"依赖缺失 ⇒ 2"是**它自己的 fail-closed 声明**（见其头部注释），
# 故它们是【契约】，不是观察 —— 不许因为"看起来会过"就删掉。
#
# Usage: bash examples/claude-code/hooks/hook_test.sh
set -uo pipefail
HOOK="$(cd "$(dirname "$0")" && pwd)/pretooluse-gate.sh"
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
pass=0; fail=0
# case <描述> <期望退出码> <stdin JSON>
case_() {
  local desc="$1" want="$2" input="$3" rc
  printf '%s' "$input" | (cd "$ROOT" && bash "$HOOK" >/dev/null 2>&1); rc=$?
  if [ "$rc" = "$want" ]; then pass=$((pass+1)); printf '  ok   %-46s exit=%s\n' "$desc" "$rc"
  else fail=$((fail+1)); printf '  FAIL %-46s exit=%s（期望 %s）\n' "$desc" "$rc" "$want"; fi
}

echo "hook_test: ${HOOK}（cwd=${ROOT}）"
case_ "非法 JSON ⇒ fail-closed 拦截"        2 '{ это не json'
case_ "空对象（无工具无路径）⇒ 放行"          0 '{}'
case_ "工具无路径 ⇒ 放行"                    0 '{"tool_name":"Bash","tool_input":{}}'
case_ "普通文件写入（不违任何闸门）⇒ 放行"     0 '{"tool_name":"Write","tool_input":{"file_path":"tmp/scratch.txt"}}'
case_ "写 PLAN.md（有 post 闸门）⇒ 由引擎判"   0 '{"tool_name":"Write","tool_input":{"file_path":"PLAN.md"}}'
# ★★ 下面两行【断言的是当前真相】，而那个真相是一个缺陷（K22）——所以它们被单独标注。
# 不把它们写成"期望拦截"：那样测试会红，而红的原因是【产品缺陷】不是【测试写错】——
# 混在一起会让后来的人以为"测试坏了"。⇒ 真相记在这里，缺陷记在 KNOWN_ISSUES。
case_ "★真相·写 DNA.md ⇒ 放行（pre 时刻无守卫；DNA 守卫是 post）" 0 '{"tool_name":"Write","tool_input":{"file_path":"DNA.md"}}'
case_ "★真相·rm -rf ⇒ 放行（本仓闸门全是内容型，无一条管命令形状）" 0 '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/x"}}'

echo
echo "  ⚠️ 上两行是【纸面 vs 真相】的实证：hook 自述'三层 fail-closed'，"
echo "     但它只对【解析/依赖错误】fail-closed；对【真危险动作】是 fail-open。见 KNOWN_ISSUES K22。"
echo "  ⇒ 这也说明该 hook 【缺一条判据】：'危险动作形状'（rm -rf / force push / 权威卷路径）"
echo
echo "hook_test: $pass passed, $fail failed"
[ "$fail" = 0 ] || exit 1
