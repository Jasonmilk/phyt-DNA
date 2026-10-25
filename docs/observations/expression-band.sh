#!/usr/bin/env bash
# expression-band.sh —— 【表达带首演校准器】
#
# ★ 为什么存在（SPEC §三 首演排期第一项，原文）：
#     「体检：人肉统计一轮——近 3 轮每基因带差分收据数，即首次表达」
#     表达带 97% / 3–20% 与路径池 2–3 条，SPEC 自己标 **unproven · 设计值 · 零次校准**。
#   ⇒ 本脚本把"零次校准"变成"第一次有数字"：**不猜值，只数证据**。
#
# ★ 判据形态（与 a6-two-chains.sh 同规格）：
#     · 只数【物理事实】：文件里真的出现的那几个字（grep），不数"我觉得它表达了几次"；
#     · 差分收据 = 年轮条目里【提到该基因且该条目在讲一个具体事件】⇒ 用"圈内命中"计数，
#       不区分好坏（那是园丁的判读，不是仪器的读数）；
#     · 输出结构化 JSON（可机读）+ 人读表（可核对）⇒ 两个读者能复现同一张表。
#
# 用法： bash docs/observations/expression-band.sh [年轮文件] [decisions 目录]
set -uo pipefail
unset BASH_ENV ENV 2>/dev/null || true          # 判据宿主环境隔离（同 validate.sh 那条修复）
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; cd "$ROOT"
GROWTH="${1:-GROWTH.md}"
DEC="${2:-decisions}"
python3 - "$GROWTH" "$DEC" <<'PY'
import io, json, os, re, sys, glob, datetime

growth, dec = sys.argv[1], sys.argv[2]
# 十基因名（真源 DNA.md；此处只列【名】，不复制解释——引用挂真值源）
GENES = ["小步可验证", "两轴裁决", "缺席是信号", "守卫不自签", "护栏经济学",
         "确定性归脚本", "物理事实优先", "唯一真源", "解耦", "按需"]

g = io.open(growth, encoding="utf-8", errors="replace").read()
# 分圈：以 "## 年轮 ·" 或 "## 本圈 ·" 为界
parts = re.split(r'(?m)^## (?:年轮|本圈)', g)
rings = [p for p in parts[1:]]
rings_recent = rings[-3:]          # 近 3 圈 = SPEC 定数 N=3 的休眠判据窗口

def count_in(text, name):
    return len(re.findall(re.escape(name), text))

rows = []
for gene in GENES:
    # 带差分收据数 = 近 3 圈里【提到该基因的圈数】（同一圈多次只算一次 —— 圈是收据的单位）
    receipts = sum(1 for r in rings_recent if count_in(r, gene) > 0)
    all_rings = sum(1 for r in rings if count_in(r, gene) > 0)
    # 结晶数 = decisions/ 里 ADR 正文提到该基因的份数（表达进了闸门 = 结晶）
    crystallized = 0
    for f in sorted(glob.glob(os.path.join(dec, "ADR-*.md"))):
        try:
            t = io.open(f, encoding="utf-8", errors="replace").read()
        except Exception:
            continue
        if count_in(t, gene) > 0:
            crystallized += 1
    rows.append({"gene": gene, "receipts_3": receipts, "rings_total": all_rings,
                 "crystallized": crystallized})

# 体检判读（真源 SPEC §三 判读表）：本脚本只给【读数与判读候选】，裁决归园丁
def read_status(r):
    if r["receipts_3"] > 0:
        return "活跃"
    if r["crystallized"] > 0:
        return "内化候选（零收据但已结晶 ⇒ 可能是本能，也可能是装饰）"
    return "休眠候选（零收据 · 未结晶 ⇒ 触发显红诊断）"

for r in rows:
    r["read"] = read_status(r)

active = [r for r in rows if r["receipts_3"] > 0]
dormant = [r for r in rows if r["receipts_3"] == 0]
total_genes = len(rows)
band = round(100.0 * len(active) / total_genes, 1) if total_genes else 0.0

out = {
    "snapshot": {
        "ts": datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S%z"),
        "growth_file": growth, "rings_total": len(rings), "rings_window": len(rings_recent),
        "decisions_dir": dec,
    },
    "expression_band": {
        "design_value": "97% 听名目 / 偏离带 3–20%",
        "measured_active_ratio_pct": band,
        "measured_deviation_pct": round(100.0 - band, 1),
        "note": "本读数=【十基因中近期有带差分收据的比例】；它是 97%/3–20% 的**第一个实测代理量**，"
                "不是同一个量（代理量 ≠ 本体 —— GROWTH 第十圈『代理量替本体』族名的教训：必须具名它是代理）",
    },
    "genes": rows,
    "summary": {
        "active": [r["gene"] for r in active],
        "zero_receipt": [r["gene"] for r in dormant],
        "verdict_pending": "读数成立，裁决归园丁（仪器不判读，只给数）",
    },
}
print(json.dumps(out, ensure_ascii=False, indent=2))
PY
