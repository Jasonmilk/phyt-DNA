#!/usr/bin/env bash
# inject.sh — 造一个【只缺一条】的世界，使 RED 由【注入】造成，而不是由"本仓还没有重放机制"造成。
#
# 为什么必须这样：本仓此刻 kind:replay 记录为零 ⇒ 闸门本来就红。
# 若夹具只是"让世界保持违规"，它就什么都没证明（缺陷没越过阈值）。
# 所以先给【每条】结晶写一行 replay，唯独漏掉 OMIT 指定的那一条 ⇒ 红只可能因为它。
set -eu
: "${F:?fixture needs \$F (the ledger)}"
cp "$F" /tmp/_probe_replay_backup
OMIT="ADR-20261009-PLAN-must-exist"
for f in decisions/ADR-*.md; do
  grep -q '^hard: true$' "$f" || continue
  grep -q '^status: deprecated' "$f" && continue
  id=$(basename "$f" .md)
  [ "$id" = "ADR-20261009-lesson-must-be-replayed" ] && continue
  [ "$id" = "$OMIT" ] && continue
  printf '{"ts":"2026-10-09T00:00:00+0800","gate_id":"%s","verdict":"pass","override":false,"source":"fixture","event_id":"fx-%s","kind":"replay","note":"injected by fixtures/ADR-20261009-lesson-must-be-replayed"}\n' "$id" "$id" >> "$F"
done
