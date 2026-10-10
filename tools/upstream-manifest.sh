#!/usr/bin/env bash
# upstream-manifest.sh —— 生成/校验【引擎】的上游指纹清单。
#
# 为什么需要（实证 2026-10-09）：`Cellrix/tools/validate.sh` 是"环境适配的副本"，
# 与上游已差 274 行、且缺后来新增的能力 ⇒ **副本必然漂**。
# 分层原则（极致解耦 + 极致复用）：
#   · **工件**（decisions/ fixtures/ ledger/ 七卷）= 每项目一份（它们是该项目的事实）
#   · **引擎**（tools/*.sh）= 可复制以保**零安装自足**，但**必须可校验是否与上游一致**
# 校验用**标准工具**，不发明格式：
#     维护者: bash tools/upstream-manifest.sh --write      # 重算 tools/UPSTREAM.sha256
#     采纳者: shasum -c tools/UPSTREAM.sha256              # 一行查出引擎是否漂
# 而**路径永远不必改脚本**（声明式）：
#     PHYT_DECISIONS=docs/decisions PHYT_FIXTURES=fixtures bash tools/validate.sh
set -uo pipefail
MAN="tools/UPSTREAM.sha256"
FILES=$(ls tools/*.sh | grep -vE '^tools/(upstream-manifest)\.sh$')
if [ "${1:-}" = "--write" ]; then
  # shellcheck disable=SC2086
  shasum $FILES > "$MAN"
  printf '已写入 %s（%s 个引擎文件）\n' "$MAN" "$(printf '%s\n' $FILES | wc -l | tr -d ' ')"
else
  [ -f "$MAN" ] || { printf '缺 %s ⇒ 维护者先跑：bash tools/upstream-manifest.sh --write\n' "$MAN"; exit 2; }
  if shasum -c "$MAN" >/dev/null 2>&1; then
    printf 'OK: 引擎与上游一致\n'
  else
    printf '★ 引擎副本已漂（与 %s 不一致）⇒ 同步上游为先；若确要分叉，请在提交信息里具名说明\n' "$MAN"
    shasum -c "$MAN" 2>&1 | grep -v ': OK$' | head -6 || true
    exit 1
  fi
fi
