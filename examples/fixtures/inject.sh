#!/usr/bin/env bash
# 好：用 $F（与 applies-to 同源），且注入量真的越过阈值
printf 'x\n%.0s' $(seq 1 151) >> "$F"
