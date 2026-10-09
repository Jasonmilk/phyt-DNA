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
# ★ K22 的修法（ADR-…-dangerous-action-shapes-must-be-blocked，timing: pre）——以下三例是【回归判据】：
#   形状题与权威卷题**必须拦**（exit 2）；而普通路径必须放行（上面那几例）。
case_ "★回归·rm -rf 形状 ⇒ 必须拦"            2 '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/x"}}'
case_ "★回归·git push --force ⇒ 必须拦"       2 '{"tool_name":"Bash","tool_input":{"command":"git push --force origin v2"}}'
case_ "★回归·写 DNA.md（权威卷）⇒ 必须拦"      2 '{"tool_name":"Write","tool_input":{"file_path":"DNA.md"}}'
case_ "safety·git push --force-with-lease ⇒ 放行" 0 '{"tool_name":"Bash","tool_input":{"command":"git push --force-with-lease origin v2"}}'

# ★ K22 已修：原先这两行【断言旧真相】（写 DNA.md / rm -rf 都放行）—— 现在它们已被
# 上面两处修法拦下（权威卷由 ADR 闸门、命令形状由 hook 的 L0.5）⇒ 旧断言已无对象，删除。
echo
echo "hook_test: $pass passed, $fail failed"
[ "$fail" = 0 ] || exit 1
