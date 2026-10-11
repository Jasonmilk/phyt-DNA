#!/usr/bin/env bash
# 注入：抹掉被测 ADR 的 origin 字段 ⇒ 闸门必须红（这是"没有出处的闸门"的形状）
tmp="$(mktemp)"; sed 's/^origin:.*/origin: ""/' "$F" > "$tmp" && mv "$tmp" "$F"
