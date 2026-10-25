#!/usr/bin/env bash
# meter.sh —— 【电表】：给已经写好的公式接上输入
#
# ★ 为什么存在（2026-10-25）：
#   `SPEC.md` 早就把公式立好了 ——
#     值：经济门槛 → f（年复发频率，次/年）× C（单次代价）> 年维护成本
#     仪表盘判据：hits/任务 · override_rate 按原因分类 · 心跳红率 + 新增结晶数
#   但 `SPEC.md:139` 自己承认：**`last-hit` 字段存在但无人回写 ⇒ f × C 是
#   「穿公式外衣的定性判断」**；`elapsed_ms` 虽然在 kind:run 行里，却没有读数入口
#   （`d-phyt-denominator` 已降级且逾期）。
#   ⇒ 三处缺口（f / T_gate / 分类可信度）根子是同一个：**仪器没上工**。
#   本文件不是新判据，是**给既有公式接输入**。
#
# ★ 仪器纪律（与 a6-two-chains.sh · expression-band.sh 同规格）：
#   · **只给数，不判读** —— 判读归园丁（守卫不自签：仪器不给自己签发结论）
#   · **样本不足必须具名** —— 读数不成立 ≠ 读数为 0；不虚标，不静默
#   · **两个读者可复现同一张表** —— 输出 JSON（机读）+ 人读表（可核对）
#   · **不留状态** —— 电表只读账本，不写账本（状态仍住 ledger，append-only）
#
# ★ f 的真值源（定死，消除双真源）：
#   `SPEC.md:139` 给了两条路：实现回写 **或** 定 f 真值源 = ledger 事件计数。
#   **本仪器选第二条**：f 真值源 = ledger；ADR 里的 `last-hit` / `hit-count`
#   降为它的**投影**，由 `--writeback` 机械生成（禁手编 —— 与派生视图同源）。
#   ⇒ 否则 last-hit/hit-count 就是"外挂的状态没有真值源，就会死"（DNA 唯一真源）。
#
# 用法：
#   bash tools/meter.sh                 # 出三栏读数（人读表 + JSON）
#   bash tools/meter.sh --json          # 只出 JSON（给 CI / 看板消费）
#   bash tools/meter.sh --writeback     # 把 last-hit / hit-count 投影回 ADR（显式调用，引擎从不自动写真件）
set -uo pipefail
unset BASH_ENV ENV 2>/dev/null || true          # 判据宿主环境隔离（同 validate.sh 那条修复）
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
LED_DIR="${PHYT_LEDGER:-$ROOT/ledger}"
DEC_DIR="${PHYT_DECISIONS:-decisions}"
MODE=report
case "${1:-}" in --json) MODE=json;; --writeback) MODE=writeback;; esac

if [ "$MODE" = writeback ]; then
  # ★ 有意回写（理由：**投影**必须由脚本生成 —— 与 INDEX 重生成同族；目标是 ADR 前言的
  #   白名单元数据键（frozen-body 白名单：status/supersedes/last-hit/hit-count），
  #   故回写**不会**改冻结体指纹。原子替换：先写 .tmp 再 mv。）
  python3 - "$LED_DIR" "$DEC_DIR" <<'PY'
import glob, io, json, os, re, sys
led, dec = sys.argv[1], sys.argv[2]
hits = {}
for f in sorted(glob.glob(os.path.join(led, 'hits-*.jsonl'))):
    for l in io.open(f, encoding='utf-8', errors='replace'):
        try: d = json.loads(l)
        except Exception: continue
        if not isinstance(d, dict): continue
        # 真实命中 = kind:task（生产口径，见 ledger/README.md）且 verdict=block
        if d.get('kind') == 'task' and d.get('verdict') == 'block' and d.get('gate_id'):
            g = d['gate_id']; ts = (d.get('ts') or '')[:10]
            c = hits.setdefault(g, {'n': 0, 'last': ''})
            c['n'] += 1
            if ts > c['last']: c['last'] = ts
changed = []
for p in sorted(glob.glob(os.path.join(dec, 'ADR-*.md'))):
    txt = io.open(p, encoding='utf-8').read()
    gid = ''
    m = re.search(r'(?m)^id:\s*(\S+)', txt)
    if m: gid = m.group(1)
    info = hits.get(gid, {'n': 0, 'last': ''})
    last = info['last'] or 'null'
    new = re.sub(r'(?m)^last-hit:.*$', 'last-hit: %s' % last, txt, count=1)
    new = re.sub(r'(?m)^hit-count:.*$', 'hit-count: %d' % info['n'], new, count=1)
    if new != txt:
        tmp = p + '.tmp'
        io.open(tmp, 'w', encoding='utf-8').write(new)
        os.replace(tmp, p)
        changed.append('%s(命中%d/最近%s)' % (os.path.basename(p), info['n'], last))
print('last-hit / hit-count 投影已回写：%d 份变更' % len(changed))
for c in changed[:8]: print('  ' + c)
print('  （f 真值源 = ledger；此二字段是投影，禁手编 —— 手编即外挂状态，没有真值源就会死）')
PY
  exit 0
fi

python3 - "$LED_DIR" "$DEC_DIR" "$MODE" <<'PY'
import collections, datetime, glob, io, json, os, re, sys

led, dec, mode = sys.argv[1], sys.argv[2], sys.argv[3]
rows = []
for f in sorted(glob.glob(os.path.join(led, 'hits-*.jsonl'))):
    for l in io.open(f, encoding='utf-8', errors='replace'):
        try: d = json.loads(l)
        except Exception: continue
        if isinstance(d, dict): rows.append(d)

def dateof(d):
    return (d.get('ts') or '')[:10]

# ── 分母（权威 = 活 hard:true 非 deprecated；与 spec-lint 分母自检同源）──────────
gates, deprecated = [], 0
for p in sorted(glob.glob(os.path.join(dec, 'ADR-*.md'))):
    t = io.open(p, encoding='utf-8', errors='replace').read()
    gid = re.search(r'(?m)^id:\s*(\S+)', t)
    gid = gid.group(1) if gid else os.path.basename(p)[:-3]
    if re.search(r'(?m)^status:\s*deprecated', t): deprecated += 1; continue
    if re.search(r'(?m)^hard:\s*true\s*$', t): gates.append(gid)
DENOM = len(gates)

# ── 栏① f：真实命中频率（真值源 = ledger，kind:task 口径）──────────────────────
real = [d for d in rows if d.get('kind') == 'task']
blocks = [d for d in real if d.get('verdict') == 'block']
dates = sorted(set(dateof(d) for d in rows if dateof(d)))
span_days = 0
if len(dates) >= 2:
    try:
        span_days = (datetime.date.fromisoformat(dates[-1]) - datetime.date.fromisoformat(dates[0])).days
    except Exception:
        span_days = 0
span_years = round(span_days / 365.0, 3) if span_days > 0 else 0.0
per_gate_hits = collections.Counter(d.get('gate_id') for d in blocks if d.get('gate_id'))
f_rows = []
for g in gates:
    n = per_gate_hits.get(g, 0)
    f_rows.append({'gate_id': g, 'real_hits': n,
                   'f_per_year': (round(n / span_years, 2) if span_years > 0 else None),
                   'usable_for_fxC': bool(span_years >= 0.25 and n > 0)})
SAMPLE_OK = span_years >= 0.25 and len(real) >= 20

# ── 栏② T_gate：elapsed_ms（来自 kind:run，真值源 = 引擎自己写的那一行）────────
runs = [d for d in rows if d.get('kind') == 'run']
els = sorted(d.get('elapsed_ms') for d in runs if isinstance(d.get('elapsed_ms'), int) and d['elapsed_ms'] > 0)
def pct(v, q):
    return v[min(len(v) - 1, int(len(v) * q))] if v else None
# ★ caller / timing 分组（DEBTS `d-phyt-denominator` 的**本体判据**原文：
#   「电表栏含 elapsed_ms **且标 caller/timing**」）。
#   不分组 ⇒ 快层(ci-local)与诊断(diag)混在一口锅里 ⇒ p50 是【混合分布的统计量】，
#   而 d-phyt-ledger-history-reassess 那条教训写死了：**没有环境的计数在跨 commit 时不可比**。
by_ct = collections.defaultdict(list)
for d in runs:
    e = d.get('elapsed_ms')
    if isinstance(e, int) and e > 0:
        by_ct[(d.get('caller') or 'unknown', d.get('timing') or 'unknown')].append(e)
t_gate = {'run_rows': len(runs), 'elapsed_ms_samples': len(els),
          'p50_ms': pct(els, .50), 'p90_ms': pct(els, .90), 'max_ms': els[-1] if els else None,
          'note': '不分 caller 的总 p50 是混合分布 ⇒ 判读必须看下面分组',
          'by_caller_timing': [{'caller': k[0], 'timing': k[1], 'n': len(v),
                                'p50_ms': pct(sorted(v), .50), 'p90_ms': pct(sorted(v), .90),
                                'max_ms': max(v)} for k, v in sorted(by_ct.items())]}

# ── 栏③ 分类可信度 + override_rate 按原因分类 ──────────────────────────────────
bad_sum = 0
for d in runs:
    pg = d.get('per_gate') or {}
    s = sum(len((pg.get(k) or '').split()) for k in ('judged-green', 'judged-red', 'unmeasurable'))
    if s != d.get('judged_gates', 0): bad_sum += 1
ov = [d for d in rows if d.get('override')]
ov_reason = collections.Counter((d.get('note') or '未给理由')[:24] for d in ov)
probe = [d for d in rows if d.get('kind') == 'probe']
pr_block = sum(1 for d in probe if d.get('verdict') == 'block')
pr_pass = sum(1 for d in probe if d.get('verdict') == 'pass')

out = {
    'meter': 'v1',
    'ts': datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S%z'),
    'truth_source': {'f': 'ledger（kind:task 口径）', 'T_gate': 'ledger（kind:run 的 elapsed_ms）',
                     'denominator': 'decisions/ 活 hard:true 非 deprecated'},
    'denominator': {'live_hard_gates': DENOM, 'deprecated': deprecated},
    'f': {'observation_span_years': span_years, 'real_task_rows': len(real), 'real_block_rows': len(blocks),
          'sample_sufficient': SAMPLE_OK,
          'note': '样本不足时 f 只作参考，**不得**用于 f×C 门槛（读数不成立 ≠ 读数为 0）',
          'gates': f_rows},
    'T_gate': t_gate,
    'classification': {'run_rows': len(runs), 'rows_with_broken_sum': bad_sum,
                       'note': 'judged_gates 必须 == judged-green + judged-red + unmeasurable'},
    'override_rate': {'count': len(ov), 'by_reason': dict(ov_reason)},
    'heartbeat_red_rate': {'probe_block': pr_block, 'probe_pass': pr_pass,
                           'note': '只统计具名归因的红（SPEC §二）'},
    'verdict_pending': '仪器不判读，只给数 —— 判读归园丁',
}
if mode == 'json':
    print(json.dumps(out, ensure_ascii=False))
else:
    print('══ 电表 · %s' % out['ts'])
    print('分母：活门 %d · deprecated %d' % (DENOM, deprecated))
    print('── 栏① f（年复发频率）· 真值源=ledger')
    print('   观测跨度 %.3f 年 · kind:task %d 行 · 其中 block %d 行 ⇒ 样本%s' % (
        span_years, len(real), len(blocks), '充足' if SAMPLE_OK else '不足（不得用于 f×C 门槛）'))
    # ★ 不虚标：样本不足时 f 打印为 `?`，**不打印 0.0** —— "读数为 0"与"读数不成立"
    #   是两件事，而 f=0 会被直接拿去算 f×C ⇒ 把"没测过"伪装成"不值得守"（装饰品的又一种形态）。
    if not SAMPLE_OK:
        nonzero = [r for r in f_rows if r['real_hits'] > 0]
        print('   ★ 样本不足 ⇒ **逐门 f 不打印**（%d 行 f=? 是噪声，不是读数）' % len(f_rows))
        print('     有真实命中的门：%s' % ('、'.join(r['gate_id'] for r in nonzero) or '无'))
        print('     解除条件：观测跨度 ≥0.25 年 ∧ kind:task ≥20 行 ⇒ 那时才逐门出 f')
        print('     ★ 宿命具名：**母仓天然无生产样本** —— ledger/README 定「生产指标只算 kind:task」')
        print('       而母仓自己不跑业务 ⇒ f 的读数**只能来自宿主**（VISION 第九节：读数在宿主先成立，')
        print('       反哺才回母仓）⇒ 这里的 f=? 是【母仓无样本】，**不是 f=0**；')
        print('       把"没测过"读成"不值得守"，是把装饰品伪装成证据。')
    else:
        for r in f_rows:
            if r['real_hits'] or r['f_per_year'] is not None:
                print('   %-58s 命中 %d · f=%s' % (r['gate_id'][:58], r['real_hits'], r['f_per_year']))
    print('── 栏② T_gate（elapsed_ms）· 标 caller/timing')
    print('   合计：run 行 %d · 有效样本 %d · p50=%s p90=%s max=%s (ms) —— %s' % (
        t_gate['run_rows'], t_gate['elapsed_ms_samples'], t_gate['p50_ms'], t_gate['p90_ms'],
        t_gate['max_ms'], t_gate['note']))
    for g in t_gate['by_caller_timing']:
        print('   · caller=%-9s timing=%-5s n=%-3d p50=%-7s p90=%-7s max=%s' % (
            g['caller'], g['timing'], g['n'], g['p50_ms'], g['p90_ms'], g['max_ms']))
    print('── 栏③ 分类可信度 / override_rate / 心跳红率')
    print('   总额不自洽的 run 行：%d / %d' % (bad_sum, len(runs)))
    print('   override %d 次，按原因：%s' % (len(ov), dict(ov_reason) or '无'))
    print('   心跳：probe block %d · pass %d' % (pr_block, pr_pass))
    print('── ' + out['verdict_pending'])
PY
