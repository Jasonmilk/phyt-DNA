#!/usr/bin/env bash
# 注入：pre 型路径黑名单，内容无关，写入任意内容触发
printf 'probe-junk\n' >> "$F"
