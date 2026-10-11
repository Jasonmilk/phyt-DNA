#!/usr/bin/env bash
# 注入：把【最新一条】"名目重抄"行里的第一个名目改错 ⇒ 必须红（漂移的形状）
# ★ 用 sed（不写 python）：避免编码/代理字符问题（曾把夹具弄成"闸门已腐化"）
last=$(grep -n '名目重抄' "$F" | tail -1 | cut -d: -f1)
[ -n "$last" ] && sed -i.bak "${last}s/：小步可验证/：小步可验证【被篡改】/" "$F" && rm -f "$F.bak"
