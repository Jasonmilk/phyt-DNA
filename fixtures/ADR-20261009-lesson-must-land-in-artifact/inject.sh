#!/usr/bin/env bash
# 注入：把装饰性检查写回工件（教训未落地 = 应被检出）
printf '  git diff --exit-code HEAD -- .claude/\n' >> "$F"
