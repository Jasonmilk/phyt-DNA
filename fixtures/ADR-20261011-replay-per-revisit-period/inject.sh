#!/usr/bin/env bash
# 注入：把被测 ADR 的 revisit-on 改到【过去】，并让账本里没有它的任何 replay ⇒ 形成"已过期却从未重放"
# ⇒ 必须红。（夹具只动 $F 与【临时账本】PHYT_LEDGER，不碰真账本。）
sed -i.bak -E 's/^revisit-on: .*/revisit-on: 2020-01-01/' "$F" && rm -f "$F.bak"
if [ -n "${PHYT_LEDGER:-}" ]; then mkdir -p "$PHYT_LEDGER"; : > "$PHYT_LEDGER/hits-2026.jsonl"; fi
