#!/usr/bin/env bash
# 注入：向常驻阅读层文件追加 250 行 ⇒ 合计越过 320（当前基线 288）
printf 'x\n%.0s' $(seq 1 250) >> "$F"
