#!/usr/bin/env bash
# ci-matrix.sh —— 六仓 CI 一屏：每个仓的最新一次 run + **它是不是【判据的绿】**。
#
# ★★ 2026-10-10 两次修补（都由本工具自己的病逼出来，故记在这里）：
#  ① **不能把 in-progress 标成 ★红** —— 实测：Tuck 的 run 状态是未完成，而我的第一版标了 ★红，
#     ⇒ **矩阵自己制造了一次"翻转"**，并让一整轮审查去追一个**从未发生的红**
#     （直接取 API：Tuck fe1ba1a 与 ba20bd8 **两次都是 success**）。⇒ 未完成 ⇒ 显式写「运行中」。
#  ② **不再把 python 嵌进 shell 双引号串** —— 那让"注释里的一个引号"就能提前终止字符串、
#     把余下内容当命令执行（实测 `—: command not found`）。⇒ 现在**整段由 heredoc 包住的 python 驱动**，
#     **引号免疫**：文本就是文本，代码就是代码。
#
# 每行回答三件事：① run 的 commit 是不是 HEAD（否 ⇒ ⚠️过期）② workflow 是不是判据（否 ⇒ ⚠️非判据）
# ③ 名字与 SHA 原样打出（**让人自己看得到**，不靠标签）。
# 声明式：PHYT_CI_OWNER · PHYT_CI_REPOS · PHYT_CI_GATE_NAMES
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2
OWNER="${PHYT_CI_OWNER:-Jasonmilk}" \
REPOS="${PHYT_CI_REPOS:-phyt-DNA anaphase-helix Cellrix FlowModus Tuck helix-mind}" \
GATE="${PHYT_CI_GATE_NAMES:-ci|Gate|verify|test}" \
python3 - <<'PY'
import json, os, re, subprocess

owner = os.environ['OWNER']; repos = os.environ['REPOS'].split(); gate = os.environ['GATE']
print('%-16s %-9s %-10s %-10s %-16s %s' % ('仓库', 'run-SHA', '状态', '标记', '工作流', '说明'))

def head_of(r):
    try:
        return subprocess.run(['git', '-C', r, 'rev-parse', '--short=7', 'HEAD'],
                              capture_output=True, text=True, timeout=8).stdout.strip() or '-'
    except Exception:
        return '-'

for r in repos:
    head = head_of(r)
    url = 'https://api.github.com/repos/%s/%s/actions/runs?per_page=1' % (owner, r)
    try:
        # ★ 用 curl（本环境的网络路径）而不是 urllib：实测 urllib 超时而 curl 通。
        raw = subprocess.run(['curl', '-s', '-m', '8', url], capture_output=True, text=True, timeout=12).stdout
        runs = json.loads(raw).get('workflow_runs', [])
    except Exception as e:
        print('%-16s %s' % (r, '★ 取不到（网络/权限）—— 这不是绿: %s' % e)); continue
    if not runs:
        print('%-16s %-9s %-10s %-10s %-16s %s' % (r, '-', '-', '-', '-', '★ 无 CI（真缺口）')); continue
    w = runs[0]; sha = w['head_sha'][:7]; name = w['name'][:16]
    status = w.get('status') or '-'; conc = w.get('conclusion') or '-'
    marks, notes = [], []
    if sha != head: marks.append('⚠️过期'); notes.append('收据≠HEAD(%s)' % head)
    if not re.search(gate, w['name']): marks.append('⚠️非判据'); notes.append('此 workflow 不是判据')
    # ★ 未完成既不是绿也不是红（第一版的假红就是从这里来的）
    if status != 'completed':
        marks.append('⏳运行中')
    elif not [m for m in marks if m.startswith('⚠️')] and conc != 'success':
        marks.append('★红')
    print('%-16s %-9s %-10s %-10s %-16s %s' % (r, sha, status, ' '.join(marks) or '✅', name, ' '.join(notes)))
PY
