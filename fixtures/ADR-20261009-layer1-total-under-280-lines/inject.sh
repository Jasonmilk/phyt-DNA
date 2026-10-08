#!/usr/bin/env bash
# 注入：向 layer1 任一文件追加 151 行，三层合计越过 280（当前基线 ≈178）
printf 'x\n%.0s' $(seq 1 151) >> "$F"
