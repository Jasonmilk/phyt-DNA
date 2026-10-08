#!/usr/bin/env bash
# PreToolUse hook —— 真实拦截点
# Claude Code 传入 JSON 到 stdin；exit 2 = 阻塞，stderr 回传给模型（官方证实）
set -uo pipefail
input=$(cat)
tool=$(printf '%s' "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')
path=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')
[ -z "$path" ] && path=$(printf '%s' "$input" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -c1-200)
[ -z "$tool$path" ] && exit 0

out=$(printf '{"tool":"%s","paths":["%s"]}' "$tool" "$path" | ./tools/validate.sh 2>&1)
rc=$?
if [ "$rc" = 2 ]; then
  printf '{"decision":"block","reason":"%s"}\n' "$(echo "$out" | grep 违规 | cut -c1-160)"
  echo "⛔ 闸门拦截: $tool $path" >&2
  echo "$out" | grep 违规 >&2
  echo "出口: validate --override <id> --note \"理由\" （留痕放行）" >&2
  exit 2
fi
exit 0
