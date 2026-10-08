#!/usr/bin/env bash
# 隔离注入：备份原文件，清空它；探针结束后还原
# 注意：必须操作 $F 本身（检测目标 = 注入目标）
cp "$F" /tmp/_probe_plan_backup 2>&1
: > "$F"
