#!/usr/bin/env bash
# emit-failures.sh —— 把测试失败【在机器读得到的地方具名】。
#
# ★ 为什么存在（2026-10-10 实测）：读 CI 失败的通道依次被堵死 ——
#   logs 端点需 admin(403) · artifacts 需凭据(401) · job summary 只在网页（API 的 output.summary 为 null）。
#   ⇒ 而 **annotations 是公开可读的** ⇒ 把失败行写成 `::error` ⇒ **读数由工具自己出，不靠人肉粘贴**。
# ★ 实战战果（同一招连中三次）：helix-mind ⇒ 缺 protoc；anaphase ⇒ 计数器把 __pycache__ 当未知扩展名；anaphase ⇒ 跨仓测试的被检对象没被检出。
#
# 用法（在 `run:` 里，失败分支内）：bash path/to/emit-failures.sh /tmp/test.log
set -uo pipefail
log="${1:-}"
# ★ 韧性（2026-10-10 实测教训 · 由豆包在 Cellrix 实证）：调用方把日志路径**写死**过，而各仓 tee 的目标不同
#   （Cellrix=/tmp/rust-gate.log · Tuck=/tmp/verify.log · anaphase=/tmp/test.log）
#   ⇒ emit 每次打"找不到日志" ⇒ **失败名从未进 annotations**（"红没有故事"）⇒ 根因不可见。
#   **改工具，不改小心**：给什么都不怕 —— 路径缺失就自己找（取 /tmp 下最新的 *.log），并**明说用了哪个**。
if [ -n "$log" ] && [ ! -f "$log" ]; then
  echo "::notice title=失败具名::传入的日志 $log 不存在 ⇒ 自动发现最新 /tmp/*.log"
  log=""
fi
if [ -z "$log" ] || [ ! -f "$log" ]; then
  log="$(ls -t /tmp/*.log 2>/dev/null | head -1 || true)"
fi
if [ -z "$log" ] || [ ! -f "$log" ]; then
  echo "::warning title=失败具名跳过::/tmp 下没有任何 *.log（判读不了，不等于没有失败）"; exit 0
fi
echo "::notice title=失败具名::读取 $log"
{
  grep -aE "^test .* FAILED|^failures:$|panicked at|^error(\[|:)|No such file|NotFound|Could not find|cannot find|^assertion|CHECKER ERROR" "$log" | head -12
  grep -aA4 "panicked at" "$log" | grep -avE "^--|^\s*$" | head -14
} | awk '!seen[$0]++' | head -24 | while IFS= read -r _l; do
    echo "::error title=失败具名::$(printf %s "$_l" | tr -d "\r" | cut -c1-400)"
  done
