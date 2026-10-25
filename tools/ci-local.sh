#!/usr/bin/env bash
# ci-local.sh — 逐字复现 .github/workflows/phyt.yml 的每一步（第三十五条的机械落地）。
#
# 为什么存在：2026-10-09 我因为「本地绿」就推送，而 CI 的 step 2/5（spec-lint）与 step 4（全仓扫描）
# 都是红的 ⇒ 每次 push 都触发一次失败通知。根因不是那两处代码，是【我从没在本地复现 CI】：
#   · 我跑的是【自己的工具】（--probe-all），CI 跑的是【它自己的工作流】——两者不等价
#   · spec-lint 禁止 check: 里出现 `2>/dev/null`（静默失败=伪证），我在三处写了
#   · 我自己的夹具【字面包含】了它要注入的违规，于是被 step 4 扫到
# ⇒ 判据：推送前跑它；五步全 0 才算"本地绿"。
#
# Usage: bash tools/ci-local.sh
set -uo pipefail
# ★ 复现【不应改动仓库】：探针会写 kind:probe 账本。
# ⚠️ 第一版我改成 PHYT_LEDGER=<临时目录> —— 那是错的：**判据读临时账本，而夹具仍写 ${F}（真实账本）**
# ⇒ **注入目标 ≠ 检测目标**（第 29 条 / P5 —— 我一直在拿这条管别人）。实测它让 replay 闸门假红。
# ⇒ 正确做法与本仓夹具的惯例一致：**备份 + 还原**，不改读取路径。
# ★ 起点一次算好账本绝对路径并**导出**：引擎（validate.sh）会读 `PHYT_LEDGER`，
#   否则它**每次调用**都要 `git rev-parse`（144 次）+ 还会打"非约定布局"提示（实测：快层 90s → 140s）。
ROOT_DIR="$(git rev-parse --show-toplevel)"
export PHYT_LEDGER="${PHYT_LEDGER:-$ROOT_DIR/ledger}"
LED="$PHYT_LEDGER/hits-$(date +%Y).jsonl"
# ★ 守卫修（2026-10-13 · 阻断项 1 的根因）：**删掉"退出时回写账本"的 trap** ——
#   原设计想的是"本地跑一遍别把账本弄脏"，但它**把本次运行的所有行（含 run 摘要！）在退出时整个擦掉**：
#   实测脚本内 `wc -l=1539 · 末行 source="ci-local"`，出脚本后 `1538 · sha1 改了 · 末行 source=空`。
#   ⇒ 账本是**追加型**：**单一写入点 + 原子追加（`>>`）+ 绝不读改写**。
#   要"本地不脏账本"请显式改路径（`PHYT_LEDGER=/tmp/x bash tools/ci-local.sh`），而不是悄悄回写。
fail=0
# ★ 定义必须先于调用（2026-10-11 实测）：`step` 原定义在第 37 行、第 32 行就被调用 ⇒
#   `step: command not found` ⇒ 第一行输出缺失 ⇒ 且**掩盖了 step 0 的真实红灯**（引擎清单过期）。
step(){ printf '  %-42s ' "$1"; }

# ── 引擎清单必须与工作区一致（改了引擎却没重算 ⇒ 采纳者会拿到过期指纹）──────────
# ★ 两条教训都写在这里：
#  ① **必须放在 `fail=0` 之后** —— 我第一版把它插在前面 ⇒ 它报了 ★ RED 而总结仍说"五步全绿"：
#     **检查跑在它要影响的状态初始化之前 ⇒ 裁决被静默丢弃**。这比"仪器静音"更隐蔽：
#     输出看得见，影响不作数（"看得见但不作数"）。
#  ② **路径风格必须与 `--write` 一致**（带 `tools/` 前缀）—— 第一版用 `cd tools && shasum *.sh`
#     ⇒ 生成的是不带前缀的路径 ⇒ 与清单**必然不同** ⇒ **一个永远红的检查**（最坏的一种）。
tmp=$(mktemp)
shasum $(ls tools/*.sh | grep -vE '^tools/(upstream-manifest)\.sh$') > "$tmp"
step "0 · 引擎清单是最新的"
if diff -q "$tmp" tools/UPSTREAM.sha256 >/dev/null 2>&1; then echo "OK"; else
  echo "★ RED  ⇒ 跑：bash tools/upstream-manifest.sh --write"; fail=1
fi
rm -f "$tmp"

step "1 · 资产完整性"
if ./tools/check-baseline.sh >/tmp/phyt_baseline.log 2>&1; then
  echo "OK"
else
  echo "★ RED"
  # ★ 鸡生蛋要【写成指令】，不是留给记忆：改动 tools/ 或 decisions/ 之后，基线必然先红一次
  # （那个被改的文件还没登记）。本会话两次踩在这里（第二次还推了）。⇒ 与其提示"别忘了"，
  # 不如把下一步印出来：跑 --update，然后【再跑一次本脚本】。
  if grep -q '资产未登记' /tmp/phyt_baseline.log; then
    echo "      ⇒ 这是预期内的：你改了 tools/ 或 decisions/，那个文件还没登记进基线。"
    echo "      ⇒ 下一步：bash tools/check-baseline.sh --update && bash tools/ci-local.sh"
  fi
  fail=1
fi
step "2 · spec-lint";  if ./tools/spec-lint.sh docs/PROTECTION.md >/dev/null 2>&1; then echo OK; else echo "★ RED"; fail=1; fi

# ★ 基线红必须作数（reviewer ② 2026-10-11）：心跳只验"夹具能否红"，**不验"仓库现在红不红"** ⇒
#   实测后果：一条【数学上不可满足】的闸门（replay-window 10 < 硬闸门 22）长红，而**没有任何检查会失败**。
#   ⇒ 这里把"基线红"变成**会失败的检查**（并把红的闸门具名列出）。
# ── ⑤ 门禁降本（2026-10-13）：快/慢分层 ───────────────────────────────────────
#   慢层（**具名**）：`3 · 心跳（--probe-all · 夹具能红）` · `5 · spec-lint 必须真实可红` · `5a · hook_test`
#     触发点：**pre-push 钩子（tools/hooks/pre-push）** · **CI（.github/workflows/phyt.yml 逐步同款）** · **手动 `bash tools/ci-local.sh`**
#   快层（每次提交）：`0/1 清单与基线` · `2 spec-lint` · `3b 快照与逃生门账` · **`4 全仓违规扫描（必跑！内容违规最后一道）`**
#   ★ 第四条硬约束（人类 2026-10-13）：**改动落在 tools/ · .github/ · examples/ · fixtures/ ⇒ 快层放大为全量**
#     （改引擎只跑一个门 = 第八次红推同族：漏重基线/漏跑全仓 ⇒ 降本在此点收益为负）。
# ★ ⑪（2026-10-13）：**核心钩子未启用 ⇒ 具名提示**（不静默、不失败 —— CI 里本来就没有钩子）
_hp="$(git config core.hooksPath 2>/dev/null || true)"
if [ -n "$_hp" ] && [ "$(cd "$_hp" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || echo '')" != "$(git rev-parse --show-toplevel)" ]; then
  echo "  ★ 具名警告: core.hooksPath=$_hp **指向别的仓** ⇒ 本仓钩子（pre-commit/pre-push）不会跑 ⇒ 覆盖：git config --local core.hooksPath tools/hooks"
fi
if [ -z "$_hp" ]; then
  echo "  ★ 具名提示: 核心钩子未启用（本克隆无 pre-commit / pre-push）⇒ 启用：git config core.hooksPath tools/hooks"
fi
FAST_MODE=0
[ "${1:-}" = "--fast" ] && FAST_MODE=1
if [ "$FAST_MODE" = 1 ]; then
  _chg=$(git diff --cached --name-only 2>/dev/null)
  case "$_chg" in
    *tools/*|*.github/*|*examples/*|*fixtures/*)
      echo "  注：改动含引擎/夹具面（tools/ .github/ examples/ fixtures/）⇒ **快层放大为全量**（第四条硬约束）"
      FAST_MODE=0
      ;;
  esac
  if [ "$FAST_MODE" = 1 ]; then
    echo "  慢层（本次跳过，具名）: 3 心跳 · 5 spec-lint-可红 · 5a hook_test"
    echo "  触发点: pre-push 钩子 · CI workflow · 手动 \`bash tools/ci-local.sh\`（全量）"
  fi
fi
step "3b · 基线红必须作数（红要具名）"
_pa=$(mktemp)
if [ "$FAST_MODE" = 1 ]; then
  : > "$_pa"
  _bl=0; _rot=0; _pa_rc=0
  echo "OK（快层：心跳略；逃生门账仍查）"
else
  bash tools/validate.sh --probe-all > "$_pa" 2>&1
  _pa_rc=$?
  _bl=$(grep -c '基线（未注入）: 红' "$_pa")
  _rot=$(grep -c '闸门已腐化' "$_pa")
fi
# ★ 0*（2026-10-13）：**"腐化"也算红** —— 此前只数"基线红" ⇒ **夹具跨不过阈值的死门对本步隐形**
#   （实测：recopy 门 probe 报「腐化」，而本步报 OK）。死门 = 门不在工作 ⇒ 与基线红同等严重。

# ★ ①补（2026-10-13）：**逃生门逾期未结 ⇒ 具名红** —— 落账三项里的 sunset 由这里执行。
#   结案方式：追加一行 kind=closure（ref_event_id 指向那行逃生门的 event_id）；append-only，不改旧行。
_esc=$(python3 - <<'PY'
import datetime, io, json, glob, os, subprocess
# ★ 2026-10-24 修【空转 · 同族于 BASH_ENV 那次】：原为 `glob.glob('ledger/hits-*.jsonl')`
#   —— **相对路径硬编码**。而本文件头部明确建议 `PHYT_LEDGER=/tmp/x bash tools/ci-local.sh`
#   （本地跑别弄脏账本）⇒ 一旦改了 PHYT_LEDGER，本段扫的是【cwd 下的 ./ledger】，扫空 ⇒
#   **报「0 处逾期」并放行** ⇒ 日落审计静默空转（读不到 ≠ 没有；缺席是信号，不是空白）。
#   ⇒ 与 validate.sh 的 LED_DIR 同源：`PHYT_LEDGER` 优先，否则 git rev-parse 锚定（cwd 无关）。
led = os.environ.get('PHYT_LEDGER')
if not led:
    try:
        root = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'],
                                       stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        root = '.'
    led = os.path.join(root, 'ledger')
today = datetime.date.today().isoformat()
closed = set(); rows = []
need = ('commit', 'revisit_on', 'recovery')          # ★ ④-7补：三字段缺一即红
for f in sorted(glob.glob(os.path.join(led, 'hits-*.jsonl'))):
    for l in io.open(f, encoding='utf-8'):
        try: d = json.loads(l)
        except Exception: continue
        if d.get('kind') == 'closure' and d.get('ref_event_id'): closed.add(d['ref_event_id'])
        # ★ 2026-10-23：问句账并入同一段日落审计 —— 开口没有日落 = 永久悬空
        #   （实证：RNA.md:13「请园丁确认」自 2026-10-11 悬空 12 天，无任何机制报警）
        #   单一真源：不写第二份扫描，问句与逃生门共用同一段代码 ⇒ 不可能只修一边。
        if d.get('kind') in ('skip', 'question'): rows.append(d)
missing = [r for r in rows if any(not r.get(k) for k in need)]
open_ = [r for r in rows if r.get('event_id') not in closed]
overdue = [r for r in open_ if (r.get('revisit_on') or '9999') < today]
def fmt(r):
    return '%s（commit=%s · 限期%s · 恢复命令:%s）' % (r.get('event_id'), (r.get('commit') or '缺')[:12], r.get('revisit_on'), (r.get('recovery') or '缺')[:46])
print(len(missing), len(overdue), '|'.join(fmt(r) for r in (missing + overdue)[:3]))
PY
)
_miss=${_esc%% *}; _rest=${_esc#* }; _over=${_rest%% *}; _why=${_rest#* }
if [ "$_miss" != "0" ]; then echo "★ RED: skip 账缺字段（commit/revisit_on/recovery）$_miss 处: $_why" >&2; fail=1; fi
if [ "$_over" != "0" ]; then echo "★ RED: 逃生门/问句逾期未结 $_over 处（日落触发，**点名 commit**）: $_why" >&2; fail=1; fi
if [ "${_bl:-0}" = "0" ] && [ "${_rot:-0}" = "0" ]; then echo OK; else
  echo "★ RED ($_bl 条闸门基线红 · ${_rot:-0} 条闸门腐化)"; grep -B4 -E '基线（未注入）: 红|闸门已腐化' "$_pa" | grep -E '^[[:space:]]*[0-9]+:[A-Za-z]|红 →|腐化' | head -6 | sed 's/^/       /'; fail=1
fi

# ★ 2026-10-25（自维护闭环最后一环）：**DEBTS 本身的日落审计** —— 此前 ci-local 只审 ledger 里的
#   kind:skip / kind:question，**不读 DEBTS 表** ⇒ 本仓 5 条逾期 5 天无人知（宿主侧同病）。
#   判据（本体）：DEBTS 里「revisit-on < 今天 且 状态不是 ✅」的行数必须为 0；缺 revisit-on 的行**报数不判红**
#   （历史行多为散文式，硬判会砸门）；本条只读，不改任何账。
step "3c · DEBTS 日落审计（账本之外的债）"
_debt=$(python3 - <<'PY'
import datetime, io, re
today = datetime.date.today()
over, nofield = [], 0
for l in io.open('DEBTS.md', encoding='utf-8', errors='replace'):
    if not l.startswith('| '):
        continue
    m = re.search(r'revisit-on[: ]*(\d{4}-\d{2}-\d{2})', l)
    if not m:
        nofield += 1
        continue
    if datetime.date.fromisoformat(m.group(1)) < today and '✅' not in l:
        name = re.sub(r'[*`]', '', l.split('|')[1])[:46].strip()
        over.append('%s(日落%s)' % (name, m.group(1)))
print('逾期未销 %d 条%s' % (len(over), ('：' + '；'.join(over[:4])) if over else ''))
print('缺 revisit-on 的行（报数不判红）%d 条' % nofield)
if over:
    raise SystemExit(2)
PY
) ; _drc=$?
echo "$_debt" | sed 's/^/      /'
if [ "$_drc" = 0 ]; then echo "OK"; else echo "★ RED: DEBTS 有逾期未销的债"; fail=1; fi

step "3 · 全部闸门能力心跳"
# ★ 与 CI 同一步【同一条命令】—— 这里曾经把 CI 的 for 循环抄了一遍（第二份清单，A5）。
# 现在它与 .github/workflows/phyt.yml 的第 3 步调用同一个入口 ⇒ 那一步不会两边漂。
if [ "$FAST_MODE" = 1 ]; then
  echo "跳过（快层 · 慢层下次在 pre-push/CI 跑）"
elif [ "$_pa_rc" = 0 ]; then
  echo "OK（$(ls decisions/ADR-*.md | wc -l | tr -d ' ') 个 ADR · probe-all 只跑了一次）"
else
  echo "★ RED"; fail=1
fi

step "4 · 全仓违规扫描（timing:post）"
f4=0
# ★ ⑫（2026-10-13 · **回退**）：批量调用**不等价** —— 实测 `paths` 数组一大，引擎返回 `{"scanned":0,"hits":0}`
#   （20 文件 681 字节即 `scanned:0`；3 文件才是 `scanned:4`）⇒ **批量版会"一个门都不扫"**，
#   而它看起来只是"变快了"（**幽灵降本**）。**正确优先** ⇒ 回退为**逐文件**（原版）。
#   批量价等价性未证 ⇒ 已登 DEBTS（带证据 + revisit-on）。
# ★ F-b（2026-10-13）：**四码必须区分**（rc 契约见 ADR-20261011-failure-must-be-named…）
#   0=判过 · 2=判出违规 ⇒ 红 · 4=本次无门可判（逐文件常见，不计）· **其他非零=引擎异常 ⇒ 红**（此前一律忽略 ⇒ 引擎坏了会静默通过）
f4=0; f4v=""; judged=0; bad=0
# ★ 五类逐门（2026-10-13）：**不用 eval、不做逐文件 python** —— 引擎 JSON 收进临时文件，结尾**一次**解析。
_jf=$(mktemp); _nfiles=0; _t0=$(date +%s)
for f in $(git -c core.quotePath=false ls-files '*.md' '*.py' '*.sh' '*.yml'); do
  _nfiles=$((_nfiles+1))
  printf '{"tool":"Write","paths":["%s"]}\n' "$f" | ./tools/validate.sh --timing post 2>/dev/null >> "$_jf"
  rc=$?
  case "$rc" in
    0) judged=$((judged+1)) ;;
    2) f4=1; f4v="$f4v $f" ;;
    4) : ;;
    *) bad=$((bad+1)); echo "      ★ 引擎异常 rc=${rc}（非 0/2/4）于 ${f}"; f4=1 ;;
  esac
done
_elapsed=$(( $(date +%s) - _t0 ))
# ★ 一次解析出五类（含显式 0）—— **不用 eval**（eval 上一次直接把变量没设上 ⇒ line 190 unbound）
_cf=$(mktemp)
python3 - "$_jf" > "$_cf" <<'PY'
import sys, json
cls = ["judged", "blocked", "unmeasurable", "skipped_timing", "skipped_cache"]
sets = {k: set() for k in cls}
for line in open(sys.argv[1], encoding='utf-8', errors='replace'):
    line = line.strip()
    if not line.startswith('{'): continue
    try: d = json.loads(line)
    except Exception: continue
    for k in cls:
        for g in (d.get(k) or '').split(): sets[k].add(g)
for k in cls:                      # 前 5 行 = 各类的 id 列表（空 ⇒ 显式空行）
    print(' '.join(sorted(sets[k])))
for k in cls:                      # 后 5 行 = 各类的个数（含 0）
    print(len(sets[k]))
PY
_uj=$(sed -n 1p "$_cf"); _ub=$(sed -n 2p "$_cf"); _uu=$(sed -n 3p "$_cf"); _ut=$(sed -n 4p "$_cf"); _uc=$(sed -n 5p "$_cf")
_nj=$(sed -n 6p "$_cf"); _nb=$(sed -n 7p "$_cf"); _nu=$(sed -n 8p "$_cf"); _nt=$(sed -n 9p "$_cf"); _nc=$(sed -n 10p "$_cf")
_tot=$(( _nj + _nb + _nu + _nt + _nc ))
rm -f "$_cf" "$_jf"
_led="${PHYT_LEDGER:-$(git rev-parse --show-toplevel)/ledger}/hits-$(date +%Y).jsonl"
# ★ ①（2026-10-13 修）：**可写性要真测** —— 之前 `wc -l | tr` 的**管道退出码恒成功**（被 tr 吃掉）⇒ 守卫不响（实测：
#   `PHYT_LEDGER=/tmp/ro-ledger` 时它照样"读到 0 行"）。改为**真追加一次**（`: >>`），失败即具名红。
if ! : >> "$_led" 2>/dev/null; then
  echo "      ★ RED: 账本不可写（${_led}）⇒ **读数无出处**（PHYT_LEDGER 指向只读或不存在的目录）"; fail=1
fi
_led0=$(wc -l < "$_led" 2>/dev/null | tr -d ' '); _led0=${_led0:-0}
# ★ A（2026-10-14 · DS 二①）：**不变量机检** —— judged_gates == len(judged-green) ∧ 各分类计数 == 列表长度
#   成立 ⇒ valid=true；否则 valid=false（**该行自动视为不可量**，消费端必须校验 valid；schema_v1，见 DEBTS d-phyt-invariant-schema-version）
_valid=true
[ "$_nj" = "$(printf '%s' "$_uj" | wc -w | tr -d ' ')" ] || _valid=false
[ "$_nb" = "$(printf '%s' "$_ub" | wc -w | tr -d ' ')" ] || _valid=false
[ "$_nu" = "$(printf '%s' "$_uu" | wc -w | tr -d ' ')" ] || _valid=false
[ "$_nt" = "$(printf '%s' "$_ut" | wc -w | tr -d ' ')" ] || _valid=false
[ "$_nc" = "$(printf '%s' "$_uc" | wc -w | tr -d ' ')" ] || _valid=false
printf '{"kind":"run","ts":"%s","source":"ci-local","caller":"ci-local","timing":"post","elapsed_ms":%d,"files":%d,"judged_gates":%d,"valid":"%s","invariant_schema":"v1","judged_ids":"%s","per_gate":{"judged-green":"%s","judged-red":"%s","unmeasurable":"%s","skipped-by-timing":"%s","skipped-by-cache":"%s"},"verdicts":{"pass":%d,"block":%d,"other":%d},"fail_closed_note":"坏 payload 的 rc=2 属 fail-closed，与 blocked 分开记"}\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$(( _elapsed * 1000 ))" "$_nfiles" "$_nj" "$_valid" "$_uj" "$_uj" "$_ub" "$_uu" "$_ut" "$_uc" "$judged" "$f4" "$bad" >> "$_led"
_led1=$(wc -l < "$_led" | tr -d ' ')
echo "  读数来源: stdout（本行以上）+ 账本 ${_led}（追加 $(( _led1 - _led0 )) 行 run 摘要 · 第 ${_led1} 行）"
[ $(( _led1 - _led0 )) -eq 1 ] || { echo "      ★ RED: run 摘要未落地（期望 +1 行，实得 +$(( _led1 - _led0 ))）⇒ 读数无出处"; fail=1; }
# ★ ①（2026-10-13）：A-6 不只"键在"，还要**值有意义**：
#   五类键**齐**（含显式 0）· 每类计数 == 该类 id 列表的字数 · `elapsed_ms > 0` · `files > 0` · `verdicts` 三个计数 ≥ 0。
if ! sed -n "${_led1}p" "$_led" | python3 -c '
import sys, json
d = json.load(sys.stdin)
assert d.get("kind") == "run", "不是 run 行"
assert d.get("valid") == "true", "valid != true ⇒ per_gate 错位 ⇒ 该行自动视为不可量"
assert int(d.get("elapsed_ms", 0)) > 0, "elapsed_ms 必须 > 0"
assert int(d.get("files", 0)) > 0, "files 必须 > 0"
pg = d.get("per_gate") or {}
cls = ["judged-green", "judged-red", "unmeasurable", "skipped-by-timing", "skipped-by-cache"]
for k in cls:
    assert k in pg, "缺类键: " + k            # 含显式 0 的类也必须在
for k in cls:
    ids = (pg.get(k) or "").split()
    n = d.get("counts", {}).get(k) if isinstance(d.get("counts"), dict) else None
for v in (d.get("verdicts") or {}).values():
    assert int(v) >= 0, "verdicts 计数必须 >= 0"
' 2>/dev/null; then
  echo "      ★ RED: run 摘要的本体判据不成立（末行非 run / 缺 per_gate / 缺 elapsed_ms / 缺 skipped-by-cache 显式 0）"; fail=1
fi
_d_all=$(ls decisions/ADR-*.md | wc -l | tr -d ' ')
echo "  总数校验: 五类之和=${_tot}（绿 ${_nj} · 红 ${_nb} · 不可量 ${_nu} · 时序跳 ${_nt} · 缓存跳 ${_nc}）"
echo "  口径并列（**不统一 · 待裁定**）: ADR 总数=${_d_all} · 本次扫到 ${judged}/${_nfiles} 文件 · 差 = 不在扫描面（applies-to 命中 .jsonl 等非扫描扩展名）"
if [ "$judged" = 0 ]; then
  echo "      ★ RED: **覆盖面为零** —— 逐文件扫完但无一门命中（judged=0）⇒ 不报绿"; f4=1
fi
[ "$f4" = 0 ] && echo "OK（逐文件 · 判过 $judged · 无门可判 $(( _nfiles - judged )) · 逐门五类已入账 绿${_nj}/红${_nb}/不可量${_nu}/时序跳${_nt}/缓存跳${_nc} · elapsed ${_elapsed}s）" \
  || { for x in $f4v; do echo "      ★ 违规: $x"; done; echo "      ★ RED"; fail=1; }

# ★ F-b 机器判据：**ADR 声明的码 == 引擎实际返回的码**（声明与行为不许分家）
_adr="decisions/ADR-20261011-failure-must-be-named-where-machines-can-read.md"   # ★ F-b 修：此处 DEC_DIR 未定义（set -u 下整脚本崩）⇒ 用具名相对路径
_decl=$(grep -oE '^\| `[0-9]+`' "$_adr" | grep -oE '[0-9]+' | sort -n | paste -sd, -)
_eng=""
printf '{"tool":"Write","paths":["README.md"]}\n' | ./tools/validate.sh --timing post >/dev/null 2>&1; _eng="$_eng $?"
printf '{"tool":"Write","paths":["a" "b"]}\n'   | ./tools/validate.sh --timing post >/dev/null 2>&1; _eng="$_eng $?"
printf '{"tool":"Write","paths":[]}\n'          | ./tools/validate.sh --timing post >/dev/null 2>&1; _eng="$_eng $?"
# ★ rc=2 的**数据样本**：`DNA.md`（权威卷门会判违规）—— **只读不写**，物件不动，无需夹具
#   ★ 注意口径：权威卷门是 **pre** 时段 ⇒ 必须用 --timing pre 取（用 post 会得 rc=4，判据就会"分家"）
printf '{"tool":"Write","paths":["DNA.md"]}\n'  | ./tools/validate.sh --timing pre  >/dev/null 2>&1; _eng="$_eng $?"
_eng=$(echo $_eng | tr ' ' '\n' | sort -n | uniq | paste -sd, -)
if [ "${_decl:-?}" = "${_eng:-?}" ]; then echo "OK（rc 契约：ADR 声明 {$_decl} == 引擎实返 {$_eng}）"
else echo "      ★ RED: rc 契约分家 —— ADR 声明 {${_decl:-空}} != 引擎实返 {${_eng:-空}}"; fail=1; fi
[ "$f4" = 0 ] && echo "OK" || { echo "      ★ RED"; fail=1; }
# ★ 节律（2026-10-25）：**电表上工** —— 仪器只给数，不判红（判读归园丁；样本不足会自己具名）
#   为什么放进 ci-local：仪表盘若没有 caller，它就是装饰品（本轮之前 meter.sh 零调用方）。
step "6 · 电表（f / T_gate / 分类可信度）· 只给数"
_meter_line=$(bash tools/meter.sh --json 2>/dev/null | python3 -c '
import json, sys
try: d = json.load(sys.stdin)
except Exception: sys.exit(3)
f, t, c, den = d["f"], d["T_gate"], d["classification"], d["denominator"]
print("f: 样本%s（task %d · block %d）· T_gate p50=%sms(p90=%sms,n=%d) · 分类不自洽 %d/%d · 分母 活%d/dep%d" % (
    "充足" if f["sample_sufficient"] else "不足",
    f["real_task_rows"], f["real_block_rows"],
    t["p50_ms"], t["p90_ms"], t["elapsed_ms_samples"],
    c["rows_with_broken_sum"], c["run_rows"],
    den["live_hard_gates"], den["deprecated"]))
' 2>/dev/null)
if [ -n "$_meter_line" ]; then echo "OK"; echo "      ${_meter_line}"
else echo "★ 具名跳过：电表读数不可得（meter.sh 失败或输出非 JSON）⇒ 不判红、不报绿"; fi

step "4b · 全池一致性（按文件判会漏的那些）"
if bash tools/check-pool.sh >/dev/null 2>&1; then echo "OK（unproven · 待夹具：能红未证）"; else echo "★ RED"; bash tools/check-pool.sh 2>&1 | head -4 | sed 's/^/       /'; fail=1; fi

# ★ 第 5 步之前：跑那些【CI 里没有、但必须被行使】的测试。
# 为什么在这里：`examples/claude-code/hooks/` 与 `examples/fixtures/` 不在 CI 的四步里，
# 而"存在但没人跑"与"不存在"是同一种病（x 光 2026-10-09 的 G6-①）。⇒ 本地自证入口负责行使它们。
if [ "$FAST_MODE" = 1 ]; then
  step "5a · PreToolUse 执行闸的测试"; echo "跳过（快层 · 慢层下次在 pre-push/CI 跑）"
else
  step "5a · PreToolUse 执行闸的测试"
if bash examples/claude-code/hooks/hook_test.sh >/tmp/phyt_hook_test.log 2>&1; then
  echo "OK  ($(tail -1 /tmp/phyt_hook_test.log))"
else
  echo "★ RED（详见 /tmp/phyt_hook_test.log）"; fail=1
fi

fi
if [ "$FAST_MODE" = 1 ]; then
  step "5 · spec-lint（必须真实可红）"; echo "跳过（快层 · 慢层下次在 pre-push/CI 跑）"
else
  step "5 · spec-lint（必须真实可红）"; if ./tools/spec-lint.sh docs/PROTECTION.md >/dev/null 2>&1; then echo OK; else echo "★ RED"; fail=1; fi
fi

echo
if [ "$fail" = 0 ]; then echo "CI-LOCAL: 全绿（11 项；其中 4b=unproven，不计入判据绿数）⇒ GitHub Actions 会过（不再有失败通知）"; exit 0; fi
echo "CI-LOCAL: 有步骤红 ⇒ **不要推送**（推送会触发失败通知）" >&2; exit 1
rm -f "$_pa" 2>/dev/null || true
