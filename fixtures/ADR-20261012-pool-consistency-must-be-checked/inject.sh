#!/usr/bin/env bash
# 注入：在【被测文件所在目录】里造一对"半对 supersede" —— 新 ADR 声明取代一条仍 accepted 的 ADR。
# ⇒ 全池扫描必须红（而按文件判的 timing:post 看不见它 —— 这正是本闸门存在的理由）。
D=$(dirname "$F")
cat > "$D/ADR-99999999-injected-predecessor.md" <<'E'
---
id: ADR-99999999-injected-predecessor
status: accepted
hard: false
applies-to: ["*"]
timing: post
check: |
  true
---
E
sed -i.bak -E 's/^supersedes: .*/supersedes: ADR-99999999-injected-predecessor/' "$F" && rm -f "$F.bak"
