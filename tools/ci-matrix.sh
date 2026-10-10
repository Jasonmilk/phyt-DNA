#!/usr/bin/env bash
# ci-matrix.sh —— 六仓 CI 一屏（R4）：每个仓的最新一次 run（状态 · 结论 · SHA）。
#
# 为什么放在引擎层：它是**读数工具**（与 validate/xray/redrate 同类），不产生事实、只呈现读数。
# 为什么需要它：本会话为看 CI 状态**手动 curl 了七八次** ⇒ 那是"去测量"应被机械化的一次实践。
# 声明式：仓库清单可用 PHYT_CI_REPOS 覆盖（空格分隔；owner 用 PHYT_CI_OWNER，默认 Jasonmilk）。
# ⚠️ 需要网络；无网络时**具名报出**（不静默返回空 —— 空与"全绿"不可区分）。
set -uo pipefail
OWNER="${PHYT_CI_OWNER:-Jasonmilk}"
REPOS="${PHYT_CI_REPOS:-phyt-DNA anaphase-helix Cellrix FlowModus Tuck helix-mind}"
printf '%-16s %-9s %-10s %-12s %s\n' 仓库 SHA 状态 结论 备注
for r in $REPOS; do
  out=$(curl -s -m 8 "https://api.github.com/repos/$OWNER/$r/actions/runs?per_page=1" 2>/dev/null)
  [ -n "$out" ] || { printf '%-16s %s\n' "$r" "★ 取不到（网络/权限）—— 这不是'绿'"; continue; }
  printf '%s' "$out" | python3 -c "
import sys,json
r='$r'
try:
    w=json.load(sys.stdin).get('workflow_runs',[])
    if not w: print('%-16s %-9s %-10s %-12s %s' % (r,'—','—','(no runs)','无 CI')); raise SystemExit
    x=w[0]; print('%-16s %-9s %-10s %-12s %s' % (r, x['head_sha'][:7], x['status'], x['conclusion'] or '—', x['name'][:24]))
except Exception as e:
    print('%-16s %s' % (r, '★ 解析失败: %s' % e))
"
done
