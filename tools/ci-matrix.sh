#!/usr/bin/env bash
# ci-matrix.sh —— 六仓 CI 一屏：每个仓的最新一次 run + **它是不是【判据的绿】**。
#
# ★★ 2026-10-10 修（reviewer D5，血的教训）：第一版只打 `conclusion` ⇒
#   它把 **GitHub 自带的 "Graph Update: pip in /."**（依赖图更新，**与测试无关**）当成了"绿"
#   ⇒ **一个会撒谎的读数工具**。实测：anaphase 与 helix-mind 的"绿"都来自它。
# ⇒ 现在每行必须同时回答三件事：
#   ① run 的 commit **是不是 HEAD**（不是 ⇒ 收据**过期**）
#   ② workflow **是不是判据工作流**（用声明式 allowlist 判；不是 ⇒ **非判据的绿**）
#   ③ 名字与 SHA 原样打出（**让人自己看得到**，不靠我的标签）
# 声明式：PHYT_CI_GATE_NAMES='ci|Gate|verify|test'（默认）。
set -uo pipefail
OWNER="${PHYT_CI_OWNER:-Jasonmilk}"
REPOS="${PHYT_CI_REPOS:-phyt-DNA anaphase-helix Cellrix FlowModus Tuck helix-mind}"
GATE_RE="${PHYT_CI_GATE_NAMES:-ci|Gate|verify|test}"
printf '%-16s %-9s %-10s %-9s %-16s %s\n' 仓库 run-SHA 结论 标记 工作流 说明
for r in $REPOS; do
  head=$(git -C "$(dirname "$0")/../../$r" rev-parse --short=7 HEAD 2>/dev/null || echo '—')
  out=$(curl -s -m 8 "https://api.github.com/repos/$OWNER/$r/actions/runs?per_page=1" 2>/dev/null)
  [ -n "$out" ] || { printf '%-16s %s\n' "$r" "★ 取不到（网络/权限）—— 这不是'绿'"; continue; }
  printf '%s' "$out" | HEAD="$head" GATE="$GATE_RE" REPO="$r" python3 -c "
import sys, json, os, re
r=os.environ['REPO']; head=os.environ['HEAD']; gate=os.environ['GATE']
try:
    w=json.load(sys.stdin).get('workflow_runs',[])
    if not w: print('%-16s %-9s %-10s %-9s %-16s %s' % (r,'—','—','—','—','★ 无 CI（真缺口）')); raise SystemExit
    x=w[0]; sha=x['head_sha'][:7]; name=x['name'][:16]; conc=x['conclusion'] or '—'
    marks=[]
    if sha != head: marks.append('⚠️过期')
    if not re.search(gate, x['name']): marks.append('⚠️非判据')
    # ★★ D12 修补（2026-10-10）：**运行中绝不标 ★红** ——
    #   实测：Tuck 的 run 状态是 `—`（in_progress）而我的第一版把它标成 ★红
    #   ⇒ **矩阵自己制造了一次翻转**（并让一轮审查去追一个没发生的红）。
    #   ⇒ 未完成 ⇒ 显式写「⏳运行中」，**它既不是绿也不是红**。
    if x['status'] != 'completed':
        marks.append('⏳运行中')
    elif not marks and conc != 'success':
        marks.append('★红')
    note = '收据≠HEAD（%s）' % head if sha != head else ''
    if '⚠️非判据' in marks: note = (note+' ' if note else '')+'此 workflow 不是判据（如 Graph Update）'
    print('%-16s %-9s %-10s %-9s %-16s %s' % (r, sha, conc, ' '.join(marks) or '✅', name, note))
except Exception as e:
    print('%-16s %s' % (r, '★ 解析失败: %s' % e))
"
done
