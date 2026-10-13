#!/usr/bin/env bash
# inject.sh — 真形状：**新增一条指向不存在文件的指针**（"从未存在"形态；比删除更隐蔽）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_protocol_named_files_backup
printf '\n另见 `docs/THIS-FILE-NEVER-EXISTED.md`（本行由夹具注入）。\n' >> "$F"
