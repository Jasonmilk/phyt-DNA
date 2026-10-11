#!/usr/bin/env bash
# 注入：造出"已过期却从未重放"的形状 —— 把被测 ADR 换成一个【新 id】（账本里没有它的任何重放记录）
# 并把 revisit-on 改到过去。★ 普查之后每个真闸门都有重放记录，所以只有"新 id"才造得出这个形状。
sed -i.bak -E 's/^id: .*/id: ADR-20261011-injected-never-replayed/; s/^revisit-on: .*/revisit-on: 2020-01-01/' "$F" && rm -f "$F.bak"
