#!/usr/bin/env bash
# validate.sh v2 · 真数据驱动：闸门全部来自 decisions/，引擎零硬编码
set -uo pipefail
# ── P2 · 路径声明式（BACKFLOW 2026-10-09）──────────────────────────────────────
# 本文件已有 `PHYT_LEDGER`；此处把另外两处也做成配置，理由同一条：
# 硬编码路径会逼采用者【改脚本】，而改脚本 = 分叉 = 漂移。
#   PHYT_DECISIONS=docs/decisions PHYT_FIXTURES=fixtures bash tools/validate.sh
DEC_DIR="${PHYT_DECISIONS:-decisions}"
FIX_DIR="${PHYT_FIXTURES:-fixtures}"
LED_DIR="${PHYT_LEDGER:-ledger}"
mode=check; target=""; only_timing=""
case "${1:-}" in
  --probe-all) mode=probe; target="";;
  --probe) mode=probe; target="$2";;
  --timing) only_timing="$2";;
  --override) printf '{"ts":"%s","gate_id":"%s","verdict":"block","override":true,"source":"cli","event_id":"manual","note":"%s"}\n' "$(TZ=CST-8 date +%Y-%m-%dT%H:%M:%S%z)" "$2" "${4:-无理由}" >> "$LED_DIR"/hits-2026.jsonl; echo "override 已留痕"; exit 0;;
  --appeal) printf '{"ts":"%s","gate_id":"%s","verdict":"appeal","override":false,"source":"user-appeal","event_id":"manual","note":"%s"}\n' "$(TZ=CST-8 date +%Y-%m-%dT%H:%M:%S%z)" "$2" "${4:-无理由}" >> "$LED_DIR"/appeals-2026.jsonl; echo "申诉已独立留痕"; exit 0;;
  --cull) mode=cull;;
esac

# P5/假-gate 修（BACKFLOW）：闸门只认 `ADR-*.md` —— 文档里的 YAML 示例含 `hard: true` 时，
# `decisions/README.md` 会被当成一个闸门（第二个采用者的第一次运行就抓到了这个假 gate）。
gates(){ for f in "$DEC_DIR"/ADR-*.md; do [ -e "$f" ] || continue
  grep -q '^hard: true$' "$f" || continue
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
  done < <(grep '^applies-to:' "$DEC_DIR/$id.md" | sed 's/.*\[//;s/\]//' | tr -d '"' | tr ',' '\n')
}
check_of(){ awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$DEC_DIR/$1.md" | sed 's/^  //'; }

# ── P3 · 零闸门具名（BACKFLOW 2026-10-09）──────────────────────────────────────
# 空集合上的"全部通过"是伪证：没有任何断言被执行过。
NG=$(gates | wc -l | tr -d ' ')
if [ "$NG" = 0 ]; then
  echo "  [BLOCK] 零闸门 —— $DEC_DIR 里没有一份带 'hard: true' 的 ADR。" >&2
  echo "          空集合上的'全部通过'是伪证：没有任何断言被执行过。" >&2
  exit 2
fi

# ── P11 · 探针要留痕 + 要跑得完 + 要有反例（BACKFLOW 2026-10-09）────────────────
# 不写账本就不算闭环："我没跑过它"与"我跑过且它红了"在账本上无法区分。
rec(){ # rec <gate_id> <verdict> <note>
  [ -d "$LED_DIR" ] || return 0
  printf '{"ts":"%s","gate_id":"%s","verdict":"%s","override":false,"source":"probe","event_id":"probe-%s-%s","kind":"probe","note":"%s"}\n' \
    "$(TZ=CST-8 date +%Y-%m-%dT%H:%M:%S%z)" "$1" "$2" "$1" "$(date +%s)-$$-$RANDOM" "$3" >> "$LED_DIR"/hits-2026.jsonl
}
probe_one(){ # probe_one <gate-id> → 0=闸门活着（RED）· 2=腐化/拓扑失配/假阳性
  local id="$1" F fx out cf out2
  F=$(glob_first "$id")
  if [ ! -f "$F" ]; then echo "  [B] 拓扑失配: $F 不存在" >&2; rec "$id" block "topology-mismatch"; return 2; fi
  fx="$FIX_DIR/$id/inject.sh"
  if [ ! -f "$fx" ]; then echo "  [A] 缺 fixture: ${fx}（无夹具就无法证明闸门能红）" >&2; rec "$id" block "no-fixture"; return 2; fi
  cp "$F" /tmp/inj.bak
  F="$F" bash "$fx" >/dev/null 2>&1
  out=$(F="$F" bash -c "$(check_of "$id")" 2>/dev/null)
  cp /tmp/inj.bak "$F" 2>/dev/null; rm -f /tmp/inj.bak
  if [ -z "$out" ]; then echo "  心跳 NOT RED — 闸门已腐化（夹具没能越过阈值）" >&2
    rec "$id" block "corrupted: fixture did not cross the threshold"; return 2; fi
  echo "  心跳 RED — 检出: $out"
  # 反例：内容不变的改动【必须不】触发判据。
  # 只有正例时，一个读时钟的判据照样能红（inject 追加字节同时改了内容与 mtime）⇒ 退化无人发现。
  cf="$FIX_DIR/$id/counter.sh"
  if [ ! -f "$cf" ]; then
    echo "  [具名] 无反例夹具 ${cf} —— 该闸门只证了'该红的红'，没证'不该红的不红'" >&2
    rec "$id" pass "probe: ${out}（no counter-fixture: negative direction unproven）"; return 0
  fi
  # ★ 判据是【结论是否改变】，不是【是否红】—— 因为 gate 可能【本来就红】
  # （本仓就有一条：PLAN.md 177 行 > 它自定的 150）。只看"是否红"会把"本来就红"
  # 误报成假阳性 —— 这个缺陷是在真闸门上加反例时才现形的。
  before_out=$(F="$F" bash -c "$(check_of "$id")" 2>/dev/null)
  cp "$F" /tmp/cnt.bak
  F="$F" bash "$cf" >/dev/null 2>&1
  after_out=$(F="$F" bash -c "$(check_of "$id")" 2>/dev/null)
  cp /tmp/cnt.bak "$F" 2>/dev/null; rm -f /tmp/cnt.bak
  if [ "$before_out" != "$after_out" ]; then
    echo "  [假阳性] 内容未变，结论却变了：'${before_out}' → '${after_out}'" >&2
    echo "          判据在'变了'与'没变'两个世界给出不同结论 ⇒ 按 Ω 是装饰品" >&2
    rec "$id" block "false-positive: conclusion changed on a content-preserving edit"; return 2
  fi
  echo "  反例守住 — 内容未变时不红 ✅"
  rec "$id" pass "probe: ${out}; counter: not tripped"; return 0
}

if [ "$mode" = probe ]; then
  if [ -n "$target" ]; then probe_one "$target"; exit $?; fi
  rc=0; ran=0; skipped=""
  while read -r g; do [ -n "$g" ] || continue
    if [ -f "$FIX_DIR/$g/inject.sh" ]; then ran=$((ran+1)); probe_one "$g" || rc=2
    else skipped="$skipped $g"; fi
  done < <(gates)
  [ -n "$skipped" ] && echo "  [具名跳过] 无夹具的闸门:${skipped}" >&2
  echo "  probe-all: 跑了 $ran 个闸门$( [ -n "$skipped" ] && echo "，跳过 $(echo $skipped | wc -w | tr -d ' ')" )"
  exit $rc
fi

if [ "$mode" = cull ]; then
  # 法官（T7）：只报告不删。法来自 ADR（无名规则不可引用，N 不写死在引擎）
  N=$(grep '^cull-after:' "$DEC_DIR"/ADR-*.md 2>/dev/null | head -1 | awk '{print $2}')
  if [ -z "$N" ]; then echo "  [法未立] 无 cull-after ADR —— 用默认 N=20（请结晶成 ADR）" >&2; N=20; fi
  ldir="$LED_DIR"
  taskhits=$(grep -h '"kind"[[:space:]]*:[[:space:]]*"task"' "$ldir"/hits-*.jsonl 2>/dev/null | tail -n "$N")
  cnt=$(printf '%s\n' "$taskhits" | grep -c . || true)
  if [ "${cnt:-0}" -lt "$N" ]; then
    echo "  cull: ledger 仅 ${cnt:-0}/$N 条 kind:task —— 样本不足，不判定"; exit 0
  fi
  found=0
  for id in $(gates); do
    grep -q '^risk: high' "$DEC_DIR/$id.md" && continue
    grep -q '^expires-on: [^n]' "$DEC_DIR/$id.md" && continue
    if ! printf '%s\n' "$taskhits" | grep -q "\"gate_id\"[[:space:]]*:[[:space:]]*\"$id\""; then
      echo "  冷存候选: ${id}（最近 $N 个 kind:task 未命中 ∧ 心跳仍红）—— 报告制，需人批准"
      found=1
    fi
  done
  [ "$found" = 0 ] && echo "  cull: 无冷存候选"
  exit 0
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
    t=$(grep '^timing:' "$DEC_DIR/$id.md" | head -1 | awk '{print $2}')
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
  done < <(grep '^applies-to:' "$DEC_DIR/$id.md" | sed 's/.*\[//;s/\]//' | tr -d '"' | tr ',' '\n')
done < <(gates)

if [ -z "$hits" ]; then printf '{"verdict":"pass","scanned":%d,"hits":0}\n' "$scanned"; exit 0; fi
printf '{"verdict":"block","scanned":%d,"hits":%d,"rule_id":"%s"}\n' "$scanned" "$(echo "$hits"|tr '|' '\n'|grep -c .)" "$(echo "$hits"|sed 's/^|//'|cut -d: -f1)"
echo "违规: $hits" >&2
exit 2