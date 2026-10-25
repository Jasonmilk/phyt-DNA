#!/usr/bin/env bash
# hard: report 门的真实调用点（B 方案 · 2026-10-26）
#   跑每条 `hard: report` 非 deprecated 的 ADR ⇒ **永不红**，只写账本 ledger/reports-<year>.jsonl。
#   字段：run_id · gate · file · findings(条数) · items[] · ts · note
#   findings 为空也要写一行（findings: 0）——否则「没 findings」与「门根本没跑」不可区分。
#   ★ 不进五类、不进 judged_gates、不影响 rc。
set -uo pipefail
DEC_DIR=${DEC_DIR:-decisions}; LED_DIR=${LED_DIR:-ledger}
RUN_ID=${CI_RUN_ID:-${RUN_ID:-$(date +%Y%m%dT%H%M%S)-$$}}
YEAR=$(date +%Y); LEDGER="$LED_DIR/reports-$YEAR.jsonl"
JSON=0; [ "${1:-}" = "--json" ] && JSON=1
gates(){ for f in "$DEC_DIR"/ADR-*.md; do [ -e "$f" ] || continue
  grep -q '^hard: report$' "$f" || continue
  grep -q '^status: deprecated' "$f" && continue
  basename "$f" .md; done; }
[ -d "$LED_DIR" ] || mkdir -p "$LED_DIR"
n=0; total=0; first=1; items='['
while read -r g; do
  [ -n "$g" ] || continue
  n=$((n+1))
  # 判据 = 该 ADR 声明的 applies-to 路径是否存在；不存在的路径各算 1 条 finding（可复跑）。
  f="$DEC_DIR/$g.md"
  findings_json='[]'; cnt=0
  at=$(grep '^applies-to:' "$f" | sed 's/^applies-to: *//')
  ck=$(grep -m1 '^check:' "$f" | awk '{print $2}')
  if [ "${ck:-}" = dangling-pointer ]; then
    while IFS= read -r ref; do
      [ -n "$ref" ] || continue
      [ -e "$ref" ] || { cnt=$((cnt+1)); findings_json=$(printf '%s' "$findings_json" | python3 -c 'import json,sys;d=json.load(sys.stdin);d.append(sys.argv[1]);print(json.dumps(d,ensure_ascii=False))' "悬空: $ref"); }
    done < <(grep -ohE '(docs|tools|decisions|ledger|fixtures|ecosystem)/[A-Za-z0-9_./-]+\.[a-z]+' $at 2>/dev/null | sort -u)
  else
  for p in $at; do
    [ -e "$p" ] || { cnt=$((cnt+1)); findings_json=$(printf '%s' "$findings_json" | python3 -c 'import json,sys;d=json.load(sys.stdin);d.append(sys.argv[1]);print(json.dumps(d,ensure_ascii=False))' "applies-to 不存在: $p"); }
  done
  fi
  total=$((total+cnt))
  python3 -c '
import json,sys,time
row={"run_id":sys.argv[1],"gate":sys.argv[2],"file":sys.argv[3],"findings":int(sys.argv[4]),
     "items":json.loads(sys.argv[5]),"ts":time.strftime("%Y-%m-%dT%H:%M:%S%z",time.localtime())}
open(sys.argv[6],"a",encoding="utf-8").write(json.dumps(row,ensure_ascii=False)+"\n")' \
    "$RUN_ID" "$g" "$f" "$cnt" "$findings_json" "$LEDGER"
  [ $first = 1 ] || items="$items,"; first=0
  items="$items{\"gate\":\"$g\",\"findings\":$cnt}"
done < <(gates)
items="$items]"
echo "  [report] run_id=$RUN_ID 门=$n 条 · findings 合计=$total · 账本=$LEDGER"
[ $JSON = 1 ] && printf '{"run_id":"%s","report_gates":%d,"report_findings":%d,"reported":%s}\n' "$RUN_ID" "$n" "$total" "$items"
# 心跳对账（第 6/7 件）：本 run_id 的账本条数 == 活着的 report 门数；缺一条 ⇒ 具名红（rc=3）
if [ -f "$LEDGER" ]; then
  rows=$(grep -c "\"run_id\": \"$RUN_ID\"\|$RUN_ID" "$LEDGER" 2>/dev/null || echo 0)
  if [ "$n" -gt 0 ] && [ "$rows" -lt "$n" ]; then
    echo "  [RED] 心跳对账失败：run_id=$RUN_ID 账本 $rows 行 < report 门 $n 条 ⇒ 有门没跑" >&2; exit 3; fi
fi
exit 0
