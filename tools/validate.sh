#!/usr/bin/env bash
# validate.sh v2 · 真数据驱动：闸门全部来自 decisions/，引擎零硬编码
set -uo pipefail
mode=check; target=""; only_timing=""
case "${1:-}" in
  --probe) mode=probe; target="$2";;
  --timing) only_timing="$2";;
  --override) printf '{"ts":"%s","gate_id":"%s","verdict":"block","override":true,"source":"cli","event_id":"manual","note":"%s"}\n' "$(TZ=CST-8 date +%Y-%m-%dT%H:%M:%S%z)" "$2" "${4:-无理由}" >> ledger/hits-2026.jsonl; echo "override 已留痕"; exit 0;;
  --appeal) printf '{"ts":"%s","gate_id":"%s","verdict":"appeal","override":false,"source":"user-appeal","event_id":"manual","note":"%s"}\n' "$(TZ=CST-8 date +%Y-%m-%dT%H:%M:%S%z)" "$2" "${4:-无理由}" >> ledger/appeals-2026.jsonl; echo "申诉已独立留痕"; exit 0;;
esac

gates(){ for f in decisions/*.md; do [ -e "$f" ] || continue
  grep -q '^hard: true' "$f" || continue
  grep -q '^status: deprecated' "$f" && continue
  basename "$f" .md; done; }
glob_first(){ local id="$1" g p
  while read -r g; do
    g=$(printf '%s' "$g" | sed 's/^ *//;s/ *$//'); [ -n "$g" ] || continue
    re=$(printf '%s' "$g" | sed 's/\./\\./g; s/\*\*/\x01/g; s/\*/[^\/]*/g; s/\x01/.*/g')
    while read -r p; do
      [[ "$p" =~ ^${re}$ ]] && { echo "$p"; return 0; }   # 首个真实存在的匹配
    done < <(git ls-files 2>/dev/null || find . -type f -not -path './.git/*' | sed 's|^\./||')
    echo "$g"; return 0
  done < <(grep '^applies-to:' "decisions/$id.md" | sed 's/.*\[//;s/\]//' | tr -d '"' | tr ',' '\n')
}
check_of(){ awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "decisions/$1.md" | sed 's/^  //'; }

if [ "$mode" = probe ]; then
  F=$(glob_first "$target")
  [ -f "$F" ] || { echo "  [B] 拓扑失配: $F 不存在" >&2; exit 2; }
  fx="fixtures/$target/inject.sh"
  [ -f "$fx" ] || { echo "  [A] 缺 fixture inject.sh" >&2; exit 2; }
  cp "$F" /tmp/inj.bak
  F="$F" bash "$fx" >/dev/null 2>&1
  out=$(F="$F" bash -c "$(check_of "$target")" 2>/dev/null)
  cp /tmp/inj.bak "$F" 2>/dev/null; rm -f /tmp/inj.bak
  if [ -n "$out" ]; then echo "  心跳 RED — 检出: $out"; exit 0
  else echo "  心跳 NOT RED — 闸门已腐化" >&2; exit 2; fi
fi

input=$(cat)
# T0-1：路径提取改 python3 JSON 解析（grep 正则会在含引号/转义命令上截断漏报）
paths=$(printf '%s' "$input" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    p = d.get("paths") or []
    print("\n".join(str(x) for x in p if isinstance(x, str)))
except Exception:
    pass
')
[ -z "$paths" ] && { printf '{"verdict":"pass","scanned":0,"hits":0}\n'; exit 0; }
scanned=0; hits=""
while read -r id; do
  [ -n "$id" ] || continue
  if [ -n "$only_timing" ]; then
    t=$(grep '^timing:' "decisions/$id.md" | head -1 | awk '{print $2}')
    [ "${t:-post}" = "$only_timing" ] || continue
  fi
  while read -r gg; do
    gg=$(echo "$gg" | sed 's/^ *//;s/ *$//'); [ -n "$gg" ] || continue
    while read -r p; do
      [ -n "$p" ] || continue
      re=$(printf '%s' "$gg" | sed 's/\./\\./g; s/\*\*/\x01/g; s/\*/[^\/]*/g; s/\x01/.*/g')
      if [[ "$p" =~ ^${re}$ ]]; then
        scanned=$((scanned+1))
        # 引擎级落实 ADR-0007：输入失效 = fail-closed，绝不静默放行
        if [ ! -e "$p" ]; then
          out="[输入失效] $p 不存在 —— 按 fail-closed 处理（静默放行=伪证）"
        else
          out=$(F="$p" bash -c "$(check_of "$id")" 2>&1)
        fi
        [ -n "$out" ] && hits="$hits|$id:$out"
        break
      fi
    done <<< "$paths"
  done < <(grep '^applies-to:' "decisions/$id.md" | sed 's/.*\[//;s/\]//' | tr -d '"' | tr ',' '\n')
done < <(gates)

if [ -z "$hits" ]; then printf '{"verdict":"pass","scanned":%d,"hits":0}\n' "$scanned"; exit 0; fi
printf '{"verdict":"block","scanned":%d,"hits":%d,"rule_id":"%s"}\n' "$scanned" "$(echo "$hits"|tr '|' '\n'|grep -c .)" "$(echo "$hits"|sed 's/^|//'|cut -d: -f1)"
echo "违规: $hits" >&2
exit 2