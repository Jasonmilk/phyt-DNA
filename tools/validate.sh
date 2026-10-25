#!/usr/bin/env bash
# validate.sh v2 · 真数据驱动：闸门全部来自 decisions/，引擎零硬编码
set -uo pipefail
# ★ 宿主环境隔离（健壮性修复 · 2026-10-19）：BASH_ENV 会让 bash 在【非交互】下 source 启动文件；
#   叠加 -u 后，宿主 .bashrc 里的未定义变量（实测 PS1）会被引擎误判为【判据自身失败】
#   ⇒ 全部闸门记 unmeasurable —— 环境脏被当成判据坏（假指控）。判据宿主必须环境无关。
unset BASH_ENV ENV 2>/dev/null || true
# ── P2 · 路径声明式（BACKFLOW 2026-10-09）──────────────────────────────────────
# 本文件已有 `PHYT_LEDGER`；此处把另外两处也做成配置，理由同一条：
# 硬编码路径会逼采用者【改脚本】，而改脚本 = 分叉 = 漂移。
#   PHYT_DECISIONS=docs/decisions PHYT_FIXTURES=fixtures bash tools/validate.sh
# ★ 采纳者的【布局声明】（2026-10-09）：引擎与工件分层 —— 引擎**字节不变**，
#   布局差异写进 `tools/paths.env`（一行，如 `PHYT_DECISIONS=docs/decisions`）。
# 为什么需要它（实证）：`Cellrix/tools/validate.sh` 曾用"环境适配的副本"解决同一件事
#   ⇒ 与上游差 274 行、缺 `--index`/`--cull`，而**改脚本 = 分叉 = 漂移**（本文件自己的注释）。
#   ⇒ 有了它，布局不同的采纳者**不改引擎**、只提交一行声明；引擎仍受上游指纹保护。
_d=$(dirname "$0"); [ -f "$_d/paths.env" ] && . "$_d/paths.env"
DEC_DIR="${PHYT_DECISIONS:-decisions}"
FIX_DIR="${PHYT_FIXTURES:-fixtures}"
# ★ 守卫修（2026-10-13）：**账本路径必须绝对锚定** —— 此前 `LED_DIR="${PHYT_LEDGER:-ledger}"` 是**相对**的，
#   于是"在别的 cwd 里跑判据"会把行写进 `<那个 cwd>/ledger/hits-XXXX.jsonl`（实测 `/tmp/tmp.*/ledger/hits-2026.jsonl` **十几份**、1174–1534 行）。
#   ⇒ 单一写入点 + 绝读改写 + **cwd 无关**。
LED_DIR="${PHYT_LEDGER:-$(git rev-parse --show-toplevel 2>/dev/null || echo .)/ledger}"
# ★ trap 用的临时态一律【全局】（trap 在脚本退出时触发，local 那时已不在作用域）
BAK=""; BAK2=""; TMP=""
# ★ 轻件 d（2026-10-09）：把"我用的布局"说出来 —— **但只在它与约定不同时才响**。
#
# ★★ 为什么必须加"只在偏离时"这个条件（血的教训，CI 实证 2026-10-09）：
#   第一版无条件打 stderr ⇒ 而**引擎把闸门 check 的 stderr 也并进"违规文本"**
#   ⇒ 任何【其 check 内部会调用 validate.sh】的闸门（如 index-must-be-regenerated）
#     都收到了一段假违规 ⇒ **一道健康的闸门被我的诊断变成假红源** ⇒ CI 第 4 步因此失败。
#   ⇒ 这是"永远红的检查"家族的新成员：**在协议通道上倒垃圾的诊断**。
#   ⇒ 正解：默认静默（零污染），**只有偏离约定布局时**才具名报出（那才是需要显形的情形）。
if [ "${PHYT_QUIET:-0}" != "1" ] && { [ -f "$_d/paths.env" ] || [ "$DEC_DIR" != "decisions" ] || [ "$FIX_DIR" != "fixtures" ] || [ "$LED_DIR" != "ledger" ]; }; then
  printf 'validate: 布局 decisions=%s fixtures=%s ledger=%s%s\n' \
    "$DEC_DIR" "$FIX_DIR" "$LED_DIR" \
    "$( [ -f "$_d/paths.env" ] && echo ' （来自 tools/paths.env）' || echo ' （非约定布局）')" >&2
fi
# ── 例外通道（override / appeal）：留痕必须是【完整的例外】，不是一句话 ──────────────
# ★ 为什么（2026-10-23 · 吸收 JM-Zen 例外审批六要素）：
#   原实现里 override 的 note 默认值就是「无理由」⇒ 一道门可以被一句话放行，
#   且没有日落、没有签署者、没有补偿、没有回退 ⇒ 护栏从"有出口"退化成"没护栏"。
#   本仓 WIP 逃生门【已有】更严的规格（ci-local ①补：commit/revisit_on/recovery 缺一即红 + 逾期具名红）
#   ⇒ 同机制两副规格 = 漂移。此处提到同一规格，并补本仓缺的两条：
#     ① 签署者必须是人类（Agent 只能提议，不能自批 —— 与"守卫不自签 / 他证禁自评"同族）
#     ② 不对称性：收窄（撤销放行）可自动；扩大（续期）必须【换人】签署。
# 用法（六要素缺一即拒绝，且【不写账本】—— 半条 override 比没有更坏）：
#   bash tools/validate.sh --override <gate_id> reason=… sunset=YYYY-MM-DD signer=@human compensation=… recovery=…
#   bash tools/validate.sh --override <gate_id> revoke=<event_id>                      # 收窄：可自动，无需签署
#   bash tools/validate.sh --override <gate_id> extend=<event_id> sunset=… signer=@other …  # 扩大：必须换人
ov_rec(){ # ov_rec <json> —— 唯一写入点 · 转义由 json 负责（与 rec() 同规格）
  LED_APPEND=1 python3 -c '
import json, sys, time
d = json.loads(sys.argv[1])
d.setdefault("ts", time.strftime("%Y-%m-%dT%H:%M:%S%z", time.localtime()))
sys.stdout.write(json.dumps(d, ensure_ascii=False) + "\n")
' "$1" >> "$LED_DIR"/hits-$(date +%Y).jsonl
}
override_act(){
  local gid="${1:-}" kv k v reason="" sunset="" signer="" compensation="" recovery="" extend="" revoke=""
  [ -n "$gid" ] || { echo "★ override 缺 gate_id（用法见本文件例外通道注释）" >&2; return 2; }
  shift
  for kv in "$@"; do
    k="${kv%%=*}"; v="${kv#*=}"
    case "$k" in
      reason) reason="$v";; sunset) sunset="$v";; signer) signer="$v";;
      compensation) compensation="$v";; recovery) recovery="$v";;
      extend) extend="$v";; revoke) revoke="$v";;
      *) echo "★ override 未知参数: ${kv}（允许 reason/sunset/signer/compensation/recovery/extend/revoke）" >&2; return 2;;
    esac
  done
  # 收窄 = 撤销一次放行 ⇒ 更安全 ⇒ 可自动（不改旧行，只追加 closure：append-only）
  if [ -n "$revoke" ]; then
    ov_rec "{\"kind\":\"closure\",\"gate_id\":\"${gid}\",\"override\":false,\"source\":\"cli\",\"event_id\":\"cl-${gid}-$(date +%s)-$$\",\"ref_event_id\":\"${revoke}\",\"note\":\"收窄覆盖：撤销放行（可自动，无需换人签署）\"}"
    echo "override 已收窄（撤销 ${revoke}）—— 收窄可自动，已留痕"
    return 0
  fi
  local miss=""
  for kv in "reason:${reason}" "sunset:${sunset}" "signer:${signer}" "compensation:${compensation}" "recovery:${recovery}"; do
    [ -n "${kv#*:}" ] || miss="$miss ${kv%%:*}"
  done
  if [ -n "$miss" ]; then
    echo "★ override 缺要素:${miss} ⇒ 拒绝放行，且不写账本（半条例外 = 无出处的放行）" >&2
    echo "  六要素: reason（理由）· sunset（日落 YYYY-MM-DD）· signer（人类签署者）· compensation（补偿控制）· recovery（回退命令）" >&2
    return 2
  fi
  case "$sunset" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
    *) echo "★ sunset 格式非法: ${sunset}（须 YYYY-MM-DD）" >&2; return 2;;
  esac
  if [[ ! "$sunset" > "$(TZ=CST-8 date +%F)" ]]; then
    echo "★ sunset 不在未来: ${sunset} ⇒ 逾期未结的例外就是永久豁免（例外必须有时限）" >&2; return 2
  fi
  # 不对称性 ①：Agent 只能提议，不能自批（他证禁自评 / 守卫不自签）
  case "$(printf '%s' "$signer" | tr 'A-Z' 'a-z')" in
    agent*|ai|auto*|bot|claude*|yuanbao|copilot|automation|system|llm|model)
      echo "★ signer 不得是 Agent / 自动化（${signer}）⇒ Agent 只能提议，不能自批" >&2; return 2;;
  esac
  # 不对称性 ②：扩大（续期）必须【换人】签署 —— 自己给自己延期 = 自批延期
  local prev=""
  if [ -n "$extend" ]; then
    prev=$(python3 -c '
import glob, io, json, sys
eid, led = sys.argv[1], sys.argv[2]
for f in sorted(glob.glob(led + "/hits-*.jsonl")):
    for l in io.open(f, encoding="utf-8"):
        try: d = json.loads(l)
        except Exception: continue
        if d.get("event_id") == eid:
            print(d.get("signer") or ""); sys.exit(0)
print("")
' "$extend" "$LED_DIR")
    [ -n "$prev" ] || { echo "★ extend 指向的 event_id 不在账本里: ${extend} ⇒ 无的放矢的续期（伪例外）" >&2; return 2; }
    if [ "$prev" = "$signer" ]; then
      echo "★ 扩大覆盖必须换人签署：原签署者 ${prev} 不得给自己续期（自批延期 = 例外无限延长）" >&2; return 2
    fi
  fi
  local sha; sha=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
  ov_rec "{\"kind\":\"override\",\"gate_id\":\"${gid}\",\"verdict\":\"block\",\"override\":true,\"source\":\"cli\",\"event_id\":\"ov-${gid}-$(date +%s)-$$\",\"signer\":\"${signer}\",\"commit\":\"${sha}\",\"revisit_on\":\"${sunset}\",\"compensation\":\"${compensation}\",\"recovery\":\"${recovery}\",\"note\":\"${reason}\",\"ref_event_id\":\"${extend:-null}\"}"
  echo "override 已留痕（六要素齐 · 日落 ${sunset} · 签署者 ${signer}${extend:+ · 续期自 ${extend}}）"
  return 0
}
appeal_act(){
  local gid="${1:-}"
  [ -n "$gid" ] || { echo "★ appeal 缺 gate_id" >&2; return 2; }
  shift || true
  local note="$*"
  [ -n "$note" ] || { echo "★ appeal 缺理由 ⇒ 拒绝（'无理由'的申诉是不留痕的抱怨）" >&2; return 2; }
  LED_APPEND=1 python3 -c '
import json, sys, time
rec = {"ts": time.strftime("%Y-%m-%dT%H:%M:%S%z", time.localtime()), "gate_id": sys.argv[1],
       "verdict": "appeal", "override": False, "source": "user-appeal", "event_id": "manual", "note": sys.argv[2]}
sys.stdout.write(json.dumps(rec, ensure_ascii=False) + "\n")
' "$gid" "$note" >> "$LED_DIR"/appeals-$(date +%Y).jsonl
  echo "申诉已独立留痕"
  return 0
}
# ── 问句账（--ask）：无人执守时的开口 —— 不问也能走，但问了就必须有人答 ──────────
# ★ 为什么（2026-10-23 · 自生长闭环）：
#   终局 = agent 在宿主项目里独立跑完一圈，人只修正歧义与丰满 VISION。
#   ⇒ 前提不是"起初问清楚"（那是预建，违反 DNA「不预写未来的 ADR」），
#     而是【遇到 VISION 未覆盖处 ⇒ 落一条带日落的问句 ⇒ 按名目默认继续】。
#   与 override 同族：开口没有日落 ⇒ 变永久悬空（实证：RNA.md:13 那句"请园丁确认"
#   自 2026-10-11 悬空至今，12 天无人答，且无任何机制让它报警）。
# ★ 为何写进 hits 而非独立账：问句的风险是【逾期不结】，必须与 kind:skip 同账，
#   才能被 ci-local ①补 的日落审计同一段代码抓到（单一真源，不抄第二份扫描）。
#   申诉才需要独立账（它破解"运营者自己分类自己"）；问句不涉不服裁决，无需分账。
# ★ signer 的语义：= 被指派答复的人（Accountable）。**agent 不得自签**
#   ⇒ 与 override 同一条不对称性：Agent 只能提问，不能自己答复自己。
# ★ compensation 的语义（问句专有）：= 【答复前的默认动作】（按名目默认继续 / 暂停该分支）
#   ⇒ 它让"问"不再阻塞：无人执守时 agent 照走，人来时读账即可。
# 用法：
#   bash tools/validate.sh --ask topic=VISION.md#scope reason=… sunset=YYYY-MM-DD \
#        signer=@human compensation=按名目默认继续 recovery="bash tools/validate.sh --ask-list"
#   bash tools/validate.sh --ask answer=<event_id> note=<答复>     # 结案：追加 closure，不改旧行
#   bash tools/validate.sh --ask-list                              # 列出未结问句（逾期具名）
ask_act(){
  local topic="" reason="" sunset="" signer="" compensation="" recovery="" gate_id="" ans="" note=""
  local kv k v
  for kv in "$@"; do
    k="${kv%%=*}"; v="${kv#*=}"
    case "$k" in
      topic) topic="$v";; reason) reason="$v";; sunset) sunset="$v";; signer) signer="$v";;
      compensation) compensation="$v";; recovery) recovery="$v";; gate_id) gate_id="$v";;
      answer) ans="$v";; note) note="$v";;
      *) echo "★ --ask 未知参数: ${kv}（允许 topic/reason/sunset/signer/compensation/recovery/gate_id/answer/note）" >&2; return 2;;
    esac
  done
  # 结案 = 收窄（把开口关上）⇒ 可自动，无需换人签署；append-only，不回改旧行
  if [ -n "$ans" ]; then
    [ -n "$note" ] || { echo "★ 结案缺 note（答复内容）—— 没有答复的结案是抹账" >&2; return 2; }
    ov_rec "{\"kind\":\"closure\",\"gate_id\":\"${gate_id:-null}\",\"override\":false,\"source\":\"cli\",\"event_id\":\"cl-ask-${ans}-$(date +%s)-$$\",\"ref_event_id\":\"${ans}\",\"note\":\"${note}\"}"
    echo "问句已结案（${ans}）—— 收窄可自动，已留痕"
    return 0
  fi
  local miss=""
  for kv in "topic:${topic}" "reason:${reason}" "sunset:${sunset}" "signer:${signer}" "compensation:${compensation}" "recovery:${recovery}"; do
    [ -n "${kv#*:}" ] || miss="$miss ${kv%%:*}"
  done
  if [ -n "$miss" ]; then
    echo "★ 问句缺要素:${miss} ⇒ 拒绝落账（没日落的问句 = 永久悬空，等于没问）" >&2
    echo "  六要素: topic（歧义在哪）· reason（为什么它改变决策）· sunset（YYYY-MM-DD）· signer（人类答复者）· compensation（答复前的默认动作）· recovery（怎么读回这本账）" >&2
    return 2
  fi
  case "$sunset" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
    *) echo "★ sunset 格式非法: ${sunset}（须 YYYY-MM-DD）" >&2; return 2;;
  esac
  if [[ ! "$sunset" > "$(TZ=CST-8 date +%F)" ]]; then
    echo "★ sunset 不在未来: ${sunset} ⇒ 逾期的问句不会有人答，只会变成装饰" >&2; return 2
  fi
  case "$(printf '%s' "$signer" | tr 'A-Z' 'a-z')" in
    agent*|ai|auto*|bot|claude*|yuanbao|copilot|automation|system|llm|model)
      echo "★ signer 不得是 Agent（${signer}）⇒ Agent 只能提问，不能自己答复自己" >&2; return 2;;
  esac
  local sha; sha=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
  ov_rec "{\"kind\":\"question\",\"gate_id\":\"${gate_id:-null}\",\"verdict\":\"open\",\"override\":false,\"source\":\"cli\",\"event_id\":\"q-$(date +%s)-$$\",\"topic\":\"${topic}\",\"signer\":\"${signer}\",\"commit\":\"${sha}\",\"revisit_on\":\"${sunset}\",\"compensation\":\"${compensation}\",\"recovery\":\"${recovery}\",\"note\":\"${reason}\"}"
  echo "问句已落账（topic=${topic} · 日落 ${sunset} · 答复者 ${signer} · 答复前默认：${compensation}）"
  return 0
}
ask_list(){
  python3 -c '
import datetime, glob, io, json, sys
led, today = sys.argv[1], datetime.date.today().isoformat()
rows, closed = [], set()
for f in sorted(glob.glob(led + "/hits-*.jsonl")):
    for l in io.open(f, encoding="utf-8"):
        try: d = json.loads(l)
        except Exception: continue
        if d.get("kind") == "closure" and d.get("ref_event_id"): closed.add(d["ref_event_id"])
        if d.get("kind") == "question": rows.append(d)
open_ = [r for r in rows if (r.get("event_id") or "") not in closed]
over = [r for r in open_ if (r.get("revisit_on") or "9999") < today]
print("问句账: 未结 %d · 逾期 %d" % (len(open_), len(over)))
for r in open_:
    flag = "★逾期" if (r.get("revisit_on") or "9999") < today else "  待答"
    print("  %s %s  topic=%s  答复者=%s  日落=%s  [默认: %s]" % (
        flag, (r.get("event_id") or "?")[:22], r.get("topic"), r.get("signer"), r.get("revisit_on"), (r.get("compensation") or "缺")[:30]))
if over: sys.exit(2)
' "$LED_DIR"
}
mode=check; target=""; only_timing=""
case "${1:-}" in
  --index) mode=index;;
  --probe-all) mode=probe; target="";;
  --probe) mode=probe; target="$2";;
  --timing) only_timing="$2";;
  --override) shift; override_act "$@"; exit $?;;
  --appeal)   shift; appeal_act   "$@"; exit $?;;
  --ask)      shift; ask_act      "$@"; exit $?;;
  --ask-list) ask_list; exit $?;;
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


# ── --index：生成 RNA.md §三 所规定的 INDEX（一行一条闸门）──────────────────────
# 复用【引擎自己的】gates()（不重写发现逻辑）+ 夹具存在性（不 grep 目录）。
# 只写【结构】（id / applies-to / 正例 / 反例 / timing），不写【状态】——
# 状态每次运行都变，写进去 INDEX 就会每次脏；结构是稳定的（确定性优先）。
if [ "$mode" = index ]; then
  printf '| 闸门 id | applies-to | 正例 inject.sh | 反例 counter.sh | timing |\n'
  printf '|---|---|---|---|---|\n'
  while read -r g; do
    [ -n "$g" ] || continue
    at=$(grep '^applies-to:' "$DEC_DIR/$g.md" | sed 's/^applies-to: *//')
    tm=$(grep -m1 '^timing:' "$DEC_DIR/$g.md" | awk '{print $2}')
    inj=$([ -f "$FIX_DIR/$g/inject.sh" ] && echo yes || echo NO)
    cnt=$([ -f "$FIX_DIR/$g/counter.sh" ] && echo yes || echo NO)
    printf '| `%s` | `%s` | %s | %s | %s |\n' "$g" "$at" "$inj" "$cnt" "${tm:-未声明}"
  done < <(gates)
  exit 0
fi

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
  # ★ 2026-10-09 修：note 此前被 **printf 直接插进 JSON**，未转义 ⇒ 只要理由里带一个 `"`
  #   整行 JSON 就非法（实测第 76 行起，账本从此读不出来，且**读者无法察觉**）。
  #   改为经 python 构造：**转义由 json.dumps 负责**，不可能再漏；且保证【一行一条】（JSONL 的下限）。
  LED_APPEND=1 python3 -c '
import json, os, sys, time
note = sys.argv[3]
rec = {"ts": time.strftime("%Y-%m-%dT%H:%M:%S%z", time.localtime()),
       "gate_id": sys.argv[1], "verdict": sys.argv[2], "override": False, "source": "probe",
       "event_id": "probe-%s-%s-%s" % (sys.argv[1], int(time.time()), os.getpid()),
       "kind": "probe", "note": note}
sys.stdout.write(json.dumps(rec, ensure_ascii=False) + "\n")
' "$1" "$2" "$3" >> "$LED_DIR"/hits-$(date +%Y).jsonl
}
probe_one(){ # probe_one <gate-id> → 0=闸门活着（RED）· 2=腐化/拓扑失配/假阳性
  local id="$1" F fx out cf out2 chk_src
  # ★（2026-10-12 自伤修复 · 两处）：① 本脚本顶部有 `set -u` ⇒ 合一 trap 引用的变量必须先声明；
  #   ② 更狠的一处：`local BAK` 只在函数作用域活 ⇒ 而 trap 在**脚本退出时**触发 ⇒ 那时 local 已失效 ⇒
  #   `BAK: unbound variable`（实测）。⇒ BAK/BAK2/TMP 一律【脚本级全局】声明（见文件顶部）。
  if grep -q '^status: deprecated' "$DEC_DIR/$id.md"; then
    echo "  具名跳过: $id 是 deprecated 存根（引擎 gates() 本就不跑它）—— 不是红，也不是绿" >&2
    rec "$id" skip "deprecated stub: gates() skips it"; return 0
  fi
  F=$(glob_first "$id")
  chk_src=$(check_of "$id")   # 判据正文取一次（原先两处各取一次）
  if [ ! -f "$F" ]; then echo "  [B] 拓扑失配: $F 不存在" >&2; rec "$id" block "topology-mismatch"; return 2; fi
  fx="$FIX_DIR/$id/inject.sh"
  if [ ! -f "$fx" ]; then echo "  [A] 缺 fixture: ${fx}（无夹具就无法证明闸门能红）" >&2; rec "$id" block "no-fixture"; return 2; fi
  # ★ 卡口（G · 2026-10-12）：夹具与判据都跑在【临时副本】上，TMP 内保持相对结构。
  #   为什么：真件可能是 append-only 的账本 —— 注入往真件追加，被 kill -9 中断即污染（实测留下 2 行垃圾）。
  #   TMP 内 decisions 做软链 ⇒ 任何"从 $F 推 ../decisions"的判据仍读到真源。
  TMP=$(mktemp -d); mkdir -p "$TMP/$(dirname "$F")"; cp "$F" "$TMP/$F"
  TR=$(git rev-parse --show-toplevel); if [ -n "$TR" ]; then ln -s "$TR/decisions" "$TMP/decisions"; fi
  # ★ 9（2026-10-13 · d-phyt-probe-fixture）：**同形目录** —— 判据体常读同门 applies-to 里的**兄弟文件**。
  #   实测 `ADR-20261011-layer1-threshold-calibrated-by-premiere`（applies-to=[PLAN.md,RNA.md]）在探针里报
  #   `bash: line 2: /tmp/…/RNA.md: No such file or directory` ⇒ 记 unmeasurable ⇒ **该门永远证不了**（判不了 ≠ 判出违规）。
  #   对策：把本门 applies-to 命中的**所有受管文件**一并复制进 TMP（保持相对结构；真件不动）。
  for _ap in $(grep -m1 '^applies-to:' "$DEC_DIR/$id.md" | sed 's/^applies-to: *//; s/[][]//g; s/"//g; s/,/ /g'); do
    for _mm in $_ap; do
      [ -f "$_mm" ] || continue
      mkdir -p "$TMP/$(dirname "$_mm")"
      [ -f "$TMP/$_mm" ] || cp "$_mm" "$TMP/$_mm"
    done
  done
  # ★ 0（2026-10-13 · 同族守卫）：**只许回写临时副本** —— 真件回写是"账本被擦"那一族的根源（ci-local 已出过一次真实事故）。
  #   非 `$TMP` 下的路径一律**拒绝回写并具名报警**（宁可留下 TMP 之外的不一致，也不许悄悄覆盖真件）。
  trap 'if [ -n "$BAK" ] && [ -f "$BAK" ]; then case "$F" in "$TMP"/*) cp "$BAK" "$F" ;; *) echo "★ 拒绝回写非临时文件: ${F}（同族守卫）" >&2; exit 3 ;; esac; rm -f "$BAK"; fi; rm -rf "$TMP"' EXIT
  echo "  判据作用于临时副本: ${TMP}/${F}（真件不动）"
  F="$TMP/$F"
  # ★ 报【两个世界】（2026-10-09 教训）：注入后的 RED 是**夹具的功劳**，不是仓库的状态。
  # 只报注入态，读者会把"夹具造出来的违规"误读成"仓库不合规"——本仓就有人这么误读过一次。
  base_out=$(F="$F" bash -u -c "$chk_src" 2>/dev/null); base_rc=$?
  # ★ 引擎认【具名跳过】（YB 2026-10-12）：rc=4 + stdout 空 ⇒ 记 skip。**既不是绿，也不是红。**
  if [ "$base_rc" = 4 ] && [ -z "$base_out" ]; then
    echo "  具名跳过: 判据拒绝在【缺历史】的场景下判（浅克隆/非 git 工作区）—— 不算绿也不算红" >&2
    rec "$id" skip "named skip: anchor not derivable (shallow clone / no history)"; return 0
  fi
  if [ -z "$base_out" ]; then echo "  [${id}] 基线（未注入）: 绿"
  else echo "  [${id}] 基线（未注入）: 红 → ${base_out}"; fi
  BAK=$(mktemp /tmp/inj.bak.XXXXXX); cp "$F" "$BAK"
  # ★ 2：trap **合一**（原先 BAK 的 trap 会覆盖 TMP 清理 ⇒ 临时目录泄漏；夹具纪律无例外）
  # ★ 0（2026-10-13 · 同族守卫）：**只许回写临时副本** —— 真件回写是"账本被擦"那一族的根源（ci-local 已出过一次真实事故）。
  #   非 `$TMP` 下的路径一律**拒绝回写并具名报警**（宁可留下 TMP 之外的不一致，也不许悄悄覆盖真件）。
  trap 'if [ -n "$BAK" ] && [ -f "$BAK" ]; then case "$F" in "$TMP"/*) cp "$BAK" "$F" ;; *) echo "★ 拒绝回写非临时文件: ${F}（同族守卫）" >&2; exit 3 ;; esac; rm -f "$BAK"; fi; if [ -n "$BAK2" ] && [ -f "$BAK2" ]; then case "$F" in "$TMP"/*) cp "$BAK2" "$F" ;; *) echo "★ 拒绝回写非临时文件: ${F}（同族守卫）" >&2; exit 3 ;; esac; rm -f "$BAK2"; fi; rm -rf "$TMP"' EXIT
  F="$F" bash "$fx" >/dev/null 2>&1
  # ★ check 自己跑不起来时，【必须具名失败】—— 不能与"无输出=通过"混同。
  # 实测（2026-10-09）：一个 check 因嵌套 heredoc 语法错误而根本没运行，
  # 而 stderr 被丢掉 ⇒ 报"NOT RED"，看起来像闸门活着。**这正是本仓禁止的"静默失败=伪证"。**
  CHK=$(mktemp /tmp/chk.out.XXXXXX)
  err=$(F="$F" bash -u -c "$chk_src" 2>&1 >"$CHK"); rc=$?
  out=$(cat "$CHK"); rm -f "$CHK"
  # ★ 0-b：**非 trap 的脚本内还原也要守**（同族不只是 trap！）—— 只许回写临时副本
  case "$F" in "$TMP"/*) cp "$BAK" "$F" ;; *) echo "★ 拒绝回写非临时文件: ${F}（同族守卫·脚本内还原）" >&2; exit 3 ;; esac; rm -f "$BAK"; BAK=
  if [ "$rc" = 4 ] && [ -z "$out" ]; then
    echo "  具名跳过: 注入后判据仍拒绝判（缺历史）—— 记 skip，不记 pass" >&2
    rec "$id" skip "named skip after injection: anchor not derivable"; return 0
  fi
  # ★ 只在【bash 语法错误】（真的没跑起来）时判失败 —— 不能用 rc：正常通过时 rc 也可能是 1。
  # ★ 1（2026-10-12）：失败模式表补齐 —— `unbound variable`（-u 生效后最常见）· `command not found`
  #   · Python 侧 `IndentationError|SyntaxError|Traceback`。注：**不再要求 stdout 为空** ——
  #   判据半途炸掉时可能已经吐了半行，那半行不是"红"。
  if printf '%s' "$err" | grep -qE 'syntax error|unexpected EOF|unexpected token|command not found|unbound variable|IndentationError|SyntaxError|Traceback'; then
    echo "  [check 失败] 判据自己没能运行：$(printf '%s' "$err" | head -1)" >&2
    # ★ 4（2026-10-13 裁定）：**判不了 ≠ 判出违规** —— 此前记 `block`（**假指控**：内容被冤枉成违规），
  #   正确 = 记 **不可量（`unmeasurable`）** 并 `return 4`（rc 契约：4 = 本次无门可判 ⇒ 调用方不报绿也不冤红）。
  rec "$id" unmeasurable "check did not run: $(printf '%s' "$err" | head -1)"; return 4
  fi
  if [ -z "$out" ]; then echo "  [${id}] 注入后: NOT RED — 闸门已腐化（夹具没能越过阈值）" >&2
    rec "$id" block "corrupted: fixture did not cross the threshold"; return 2; fi
  # ★ 夹具必须【真的改变了结论】（2026-10-09）。若注入前后的结论一字不差，那么这次"RED"
  # 不是夹具的功劳：要么它没越过阈值，要么**判据对这个文件的内容不敏感**（例如只断言文件名）。
  # 后者是一种天然长出来的 V=0 闸门 —— 恒红，永远说明不了任何事；而它此前会被报成"心跳 RED ✅"。
  # 这条不加，"守卫能抓住判据退化"就一直是未证明的（本会话悬了两轮）。
  if [ "$base_out" = "$out" ]; then
    echo "  [夹具无效] 注入前后的结论完全相同 ⇒ 夹具没越阈，或判据对该文件的内容不敏感" >&2
    echo "             结论: ${out}" >&2
    rec "$id" block "ineffective fixture: identical conclusion before/after injection"; return 2
  fi
  echo "  [${id}] 注入后: RED — 检出: ${out}"
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
  before_out=$(F="$F" bash -u -c "$(check_of "$id")" 2>/dev/null)
  BAK2=$(mktemp /tmp/cntbak.XXXXXX); cp "$F" "$BAK2"      # ★ 2：mktemp（固定路径 = 并发相撞）
  F="$F" bash "$cf" >/dev/null 2>&1
  after_out=$(F="$F" bash -u -c "$(check_of "$id")" 2>/dev/null)
  # （反例段只比"结论是否改变"；若 check 本身坏了，上面的正例段已经具名报过。）
  case "$F" in "$TMP"/*) cp "$BAK2" "$F" ;; *) echo "★ 拒绝回写非临时文件: ${F}（同族守卫·脚本内还原）" >&2; exit 3 ;; esac; rm -f "$BAK2"; BAK2=
  if [ "$before_out" != "$after_out" ]; then
    echo "  [假阳性] 内容未变，结论却变了：'${before_out}' → '${after_out}'" >&2
    echo "          判据在'变了'与'没变'两个世界给出不同结论 ⇒ 按 Ω 是装饰品" >&2
    rec "$id" block "false-positive: conclusion changed on a content-preserving edit"; return 2
  fi
  echo "  [${id}] 反例守住 — 内容未变时不红 ✅"
  rec "$id" pass "probe: ${out}; counter: not tripped"; return 0
}

if [ "$mode" = probe ]; then
  if [ -n "$target" ]; then
    # ★ 0***a（2026-10-13）：**单门路径也要读 `probe: none`** —— 否则同一份声明在单跑/全跑下说法不一致
    #   （实测：DNA 门在 --probe-all 里是"具名不可 probe"，单跑却报"腐化"）。
    if [ "$(grep -m1 '^probe:' "$DEC_DIR/$target.md" | awk '{print $2}')" = "none" ]; then
      why=$(grep -m1 '^probe-why:' "$DEC_DIR/$target.md" | sed 's/^probe-why: *//')
      echo "  [具名·不可 probe] $target —— ${why:-未给理由}" >&2
      [ -z "$why" ] && exit 2 || exit 0
    fi
    probe_one "$target"; exit $?
  fi
  rc=0; ran=0; skipped=""
  while read -r g; do [ -n "$g" ] || continue
    # ★ `probe: none` = 具名的"本闸门不可 probe"（它的回归判据在别处）。
    # 为什么要这个档：有些判据的对象是【任意输入字符串】而不是文件（例：危险动作的形状），
    # 或者它的 applies-to 正是它要禁的路径（例：权威卷）⇒ probe 的"路径模型"表达不了它，
    # 强行 probe 只会得到恒红。⇒ 与 NOT_DRAWN 同思想：**可以不被 probe，但必须具名并给理由**。
    if [ "$(grep -m1 '^probe:' "$DEC_DIR/$g.md" | awk '{print $2}')" = "none" ]; then
      why=$(grep -m1 '^probe-why:' "$DEC_DIR/$g.md" | sed 's/^probe-why: *//')
      echo "  [具名·不可 probe] $g —— ${why:-未给理由}" >&2
      [ -z "$why" ] && rc=2   # 不给理由 ⇒ 不算具名 ⇒ 失败
      continue
    fi
    if [ -f "$FIX_DIR/$g/inject.sh" ]; then ran=$((ran+1)); probe_one "$g" || rc=2
    else skipped="$skipped $g"; fi
  done < <(gates)
  # ★ 无夹具的闸门是 `unproven`，不是 `alive` ⇒ 它【必须让这条命令失败】（P11："pass 不可独报"）。
  # 早先这里是"具名跳过但 exit 0" —— 那会让 CI 在【有闸门没夹具】时照样绿，
  # 即"没装门看起来像门通过了"（I7）的同一形状。**具名仍然保留**（说清是哪些），只是结论变成失败。
  if [ -n "$skipped" ]; then
    echo "  [无夹具] 这些闸门只是 unproven，不是 alive:${skipped}" >&2
    echo "           ⇒ 各补一个 fixtures/<id>/counter.sh 与 inject.sh；证据不足时不得算通过" >&2
    rc=2
  fi
  echo "  probe-all: 跑了 $ran 个闸门$( [ -n "$skipped" ] && echo "，无夹具 $(echo $skipped | wc -w | tr -d ' ')" )$(grep -l '^probe: none' "$DEC_DIR"/ADR-*.md 2>/dev/null | wc -l | tr -d ' ' | sed 's/^/，具名不可probe /')"
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
except Exception as e:
    # ★ C（2026-10-13）：**读不懂的 payload 不许静默放行** —— 此前是 `pass` ⇒ paths 空 ⇒ 下面打印 `pass, scanned:0` 并 exit 0
    sys.stderr.write("★ payload 解析失败（静默失败=伪证）: %s\n" % e)
    raise SystemExit(4)
')
# ★ C：**`scanned=0` ⇒ 不许 pass**（具名 exit 4）—— "什么都没判"与"判过且绿"必须可区分。
#   调用方可自行区分：`rc=4` = 本次没命中任何门（逐文件场景常见，非失败）；批量的 rc=4 = 覆盖面为零（失败）。
if [ -z "$paths" ]; then
  printf '{"verdict":"skip","scanned":0,"hits":0,"reason":"payload 为空或无路径"}\n'
  echo "★ 具名跳过: 本次扫描没有任何路径（scanned=0）⇒ 不判、不报绿" >&2
  exit 4
fi
scanned=0; skips=0; skips_named=""; hits=""; judged_ids=""; blocked_ids=""; unmeas_ids=""; timing_ids=""; cache_ids=""
while read -r id; do
  [ -n "$id" ] || continue
  if [ -n "$only_timing" ]; then
    t=$(grep '^timing:' "$DEC_DIR/$id.md" | head -1 | awk '{print $2}')
    # ★ 五类逐门（2026-10-13）：**时序跳过要具名**（不是"没这门"，是"这次不该判它"）
    [ "${t:-post}" = "$only_timing" ] || { timing_ids="$timing_ids $id"; continue; }
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
          SC=$(mktemp /tmp/scan.out.XXXXXX)
          err2=$(F="$p" bash -u -c "$(check_of "$id")" 2>&1 >"$SC"); rc2=$?
          out=$(cat "$SC"); rm -f "$SC"
          if [ "$rc2" = 4 ] && [ -z "$out" ] && printf '%s' "$err2" | grep -q '具名跳过'; then
            skips=$((skips+1)); skips_named="$skips_named|$id"
            break
          fi
          # ★ 只在【真的没跑起来】时判失败：rc 不是可靠信号 ——
          #   很多 check 在【通过】时最后一条命令是失败的 `[ … ]` 测试 ⇒ rc=1（那是正常通过）。
          #   可靠信号是 bash 自己的语法错误。实测（2026-10-09）：用 rc 判会让 63 个文件全被判违规。
          if printf '%s' "$out" | grep -qE 'syntax error|unexpected EOF|unexpected token|command not found'; then
            out="[check 失败] 判据 ${id} 自己没能运行 —— 静默失败=伪证: $(printf '%s' "$out" | head -1)"
            unmeas_ids="$unmeas_ids $id"    # ★ 五类之：unmeasurable（判不了 ≠ 判出违规）
          fi
        fi
        # ★ A-5（2026-10-13）：**逐门判定来源** —— "判过且绿"必须可读（此前它不落任何账 ⇒ 覆盖率只能靠猜）
        if [ -z "$out" ]; then judged_ids="$judged_ids $id"; else blocked_ids="$blocked_ids $id"; fi
        [ -n "$out" ] && hits="$hits|$id:$out"
        break
      fi
    done <<< "$paths"
  done < <(grep '^applies-to:' "$DEC_DIR/$id.md" | sed 's/.*\[//;s/\]//' | tr -d '"' | tr ',' '\n')
done < <(gates)

n_hits=$(echo "$hits"|tr '|' '\n'|grep -c .); first=$(echo "$hits"|sed 's/^|//'|cut -d: -f1)
[ "$skips" -gt 0 ] && echo "具名跳过 $skips 个（缺历史 ⇒ 判据不判，不是绿也不是红）: $skips_named" >&2
if [ "$scanned" = 0 ]; then echo "具名提示: 本次扫描【没有任何路径被 post 闸门覆盖】（scanned=0）—— 绿不代表合规，代表【没有判】" >&2; fi
if [ "$scanned" = 0 ]; then
  printf '{"verdict":"skip","scanned":0,"hits":0,"reason":"有路径但无一门命中"}\n'
  echo "★ 具名跳过: 给了路径但**无一门命中**（scanned=0）⇒ 覆盖面为零，不报绿" >&2
  exit 4
fi
_jid=$(printf '%s' "$judged_ids" | sed 's/^ *//'); _bid=$(printf '%s' "$blocked_ids" | sed 's/^ *//')
_uim=$(printf '%s' "$unmeas_ids" | sed 's/^ *//'); _tim=$(printf '%s' "$timing_ids" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/ *$//')
# ★ 五类之 skipped-by-cache：本引擎**无缓存** ⇒ 显式空串（**含 0**，不许省略）
_cac=""
if [ -z "$hits" ]; then printf '{"verdict":"pass","scanned":%d,"hits":0,"skipped":%d,"judged":"%s","unmeasurable":"%s","skipped_timing":"%s","skipped_cache":"%s"}\n' "$scanned" "$skips" "$_jid" "$_uim" "$_tim" "$_cac"; exit 0; fi
printf '{"verdict":"block","scanned":%d,"hits":%d,"skipped":%d,"rule_id":"%s","judged":"%s","blocked":"%s","unmeasurable":"%s","skipped_timing":"%s","skipped_cache":"%s"}\n' "$scanned" "$n_hits" "$skips" "$first" "$_jid" "$_bid" "$_uim" "$_tim" "$_cac"
echo "违规: $hits" >&2
exit 2