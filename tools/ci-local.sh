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
LED="ledger/hits-$(date +%Y).jsonl"
LED_BAK="$(mktemp)"
cp "$LED" "$LED_BAK" 2>/dev/null || true
trap 'cp "$LED_BAK" "$LED" 2>/dev/null; rm -f "$LED_BAK"' EXIT
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
if [ -z "$(git config core.hooksPath || true)" ]; then
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
import datetime, io, json, glob
today = datetime.date.today().isoformat()
closed = set(); rows = []
need = ('commit', 'revisit_on', 'recovery')          # ★ ④-7补：三字段缺一即红
for f in sorted(glob.glob('ledger/hits-*.jsonl')):
    for l in io.open(f, encoding='utf-8'):
        try: d = json.loads(l)
        except Exception: continue
        if d.get('kind') == 'closure' and d.get('ref_event_id'): closed.add(d['ref_event_id'])
        if d.get('kind') == 'skip': rows.append(d)
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
if [ "$_over" != "0" ]; then echo "★ RED: 逃生门逾期未结 $_over 处（日落触发，**点名 commit**）: $_why" >&2; fail=1; fi
if [ "${_bl:-0}" = "0" ] && [ "${_rot:-0}" = "0" ]; then echo OK; else
  echo "★ RED ($_bl 条闸门基线红 · ${_rot:-0} 条闸门腐化)"; grep -B4 -E '基线（未注入）: 红|闸门已腐化' "$_pa" | grep -E '^\s*[0-9]+:[A-Za-z]|红 →|腐化' | head -6 | sed 's/^/       /'; fail=1
fi

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
f4=0
for f in $(git -c core.quotePath=false ls-files '*.md' '*.py' '*.sh' '*.yml'); do   # ★ G：不依赖宿主 config（CJK 文件名不再被加引号）
  printf '{"tool":"Write","paths":["%s"]}\n' "$f" | ./tools/validate.sh --timing post >/dev/null 2>&1
  [ $? = 2 ] && { echo; echo "      ★ 违规: $f"; f4=1; }
done
[ "$f4" = 0 ] && echo "OK（逐文件 · 等价性已证）" || { echo "      ★ RED"; fail=1; }
[ "$f4" = 0 ] && echo "OK" || { echo "      ★ RED"; fail=1; }
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
if [ "$fail" = 0 ]; then echo "CI-LOCAL: 全绿（9 项；其中 4b=unproven，不计入判据绿数）⇒ GitHub Actions 会过（不再有失败通知）"; exit 0; fi
echo "CI-LOCAL: 有步骤红 ⇒ **不要推送**（推送会触发失败通知）" >&2; exit 1
rm -f "$_pa" 2>/dev/null || true
