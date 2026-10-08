#!/usr/bin/env bash
# 注入：PLAN 追加 151 行，越过 150 阈值
printf 'x\n%.0s' $(seq 1 151) >> "$F"
