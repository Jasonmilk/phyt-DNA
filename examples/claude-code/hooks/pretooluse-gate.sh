#!/usr/bin/env bash
# PreToolUse hook v2 · 三层 fail-closed（T0-1）
# 非法 JSON / 依赖缺失 / 引擎异常 全部 exit 2 —— 静默放行 = 伪证
# 解析用 python3 + json：grep 正则会在含引号/转义命令上截断漏报（T0 审计）
set -uo pipefail

# L2 · 依赖缺失
if ! command -v python3 >/dev/null 2>&1; then
  echo "⛔ fail-closed: python3 不可用，hook 无法解析输入（依赖缺失）" >&2
  exit 2
fi

input=$(cat)

# L1 · 非法 JSON（json.dumps 保证含引号命令的转义正确）
parsed=$(printf '%s' "$input" | python3 -c '
import sys, json
raw = sys.stdin.read()
try:
    d = json.loads(raw)
except Exception:
    print("__INVALID__")
    sys.exit(0)
tool = str(d.get("tool_name") or "")
ti = d.get("tool_input") or {}
path = ""
if isinstance(ti, dict):
    path = str(ti.get("file_path") or ti.get("command") or ti.get("path") or "")
print(json.dumps({"tool": tool, "paths": [path] if path else []}))
')
if [ "$parsed" = "__INVALID__" ]; then
  echo "⛔ fail-closed: 非法 JSON —— 无法判定工具与路径，按拦截处理" >&2
  exit 2
fi

tool=$(printf '%s' "$parsed" | python3 -c 'import sys,json; print(json.load(sys.stdin)["tool"])')
paths=$(printf '%s' "$parsed" | python3 -c 'import sys,json; print(" ".join(json.load(sys.stdin)["paths"]))')
[ -z "$tool$paths" ] && exit 0

# 送检引擎：合法 JSON 直通 stdin（含引号命令不再被 grep 截断）
out=$(printf '%s' "$parsed" | ./tools/validate.sh 2>&1)
rc=$?

# L3 · 引擎异常：仅 0（放行）与 2（拦截）是合法结局，其余一律 fail-closed
if [ "$rc" != 0 ] && [ "$rc" != 2 ]; then
  echo "⛔ fail-closed: 引擎异常（exit ${rc}）—— 不得静默放行" >&2
  exit 2
fi

if [ "$rc" = 2 ]; then
  echo "⛔ 闸门拦截: $tool $paths" >&2
  printf '%s\n' "$out" | grep 违规 >&2 || printf '%s\n' "$out" >&2
  echo "出口: validate.sh --override <id> --note \"理由\"（留痕放行）" >&2
  exit 2
fi
exit 0
