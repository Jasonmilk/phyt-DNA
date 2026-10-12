#!/usr/bin/env bash
# check-pool.sh —— 【全池一致性】扫描（reviewer ③ 的答案 · 2026-10-11）
#
# ★ 为什么存在（实测）：引擎按【文件】判（timing:post：写谁判谁）⇒
#   **存在于闸门出生之前、或此后无人再写的违规 ⇒ 永远不被判**。
#   实证：配对闸门出生时 pair 已断（lesson=accepted 而新 ADR 已声明 supersedes 它），
#   此后三笔（5208c23 / 7a044c8 / b210819）无人再写那两份文件 ⇒ **三个 commit 静默通过**。
# ⇒ 本步把【全池】一次喂给引擎，补上那个盲区。
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
# ★ 参数化目标目录（reviewer ① · 2026-10-11）：原先硬读 decisions/ ⇒ **隔离夹具根本没被读**（夹具逃逸）。
#   修法：`check-pool.sh [dir]`（默认 decisions）⇒ 夹具目录能被真读 ⇒ 两侧可验。
DIR="${1:-decisions}"
# ★ 路径形态必须与 applies-to 的 glob 一致（2026-10-11 实测教训）：
#   引擎按【路径字符串】匹配 `decisions/ADR-*.md`；传绝对临时路径 ⇒ 永不匹配 ⇒ 闸门不被选中 ⇒ 夹具"腐化"。
#   ⇒ 以 DIR 的父目录为 CWD，用相对路径 `<basename(DIR)>/ADR-x.md` 喂它。
BASE="$(basename "$DIR")"; cd "$(dirname "$DIR")"
files=$(ls "$BASE"/ADR-*.md 2>/dev/null | LC_ALL=C tr '\n' ' ')
n=$(printf '%s' "$files" | wc -w | tr -d ' ')

# ★ 2026-10-12（G）：池扫描原先只喂 ADR ⇒ 受管文档（README 等）的 post 闸门仍落在盲区里（G 的登记）。
extra=""
if [ "$BASE" = decisions ]; then for d in README.md README.zh-CN.md; do [ -f "$d" ] && extra="$extra $d"; done; fi
payload=$(POOL_PATHS="$files $extra" python3 - <<'PY'
import json,os,sys
paths=[p for p in (os.environ.get('POOL_PATHS') or '').split() if p]
print(json.dumps({"tool":"Write","paths":paths}))
PY
)
if [ -z "$files" ]; then echo "OK: 目录 $DIR 下没有 ADR（无可扫）"; exit 0; fi
out=$(PHYT_DECISIONS="$BASE" PHYT_QUIET=1 bash "$ROOT/tools/validate.sh" --timing post 2>&1 <<< "$payload"); rc=$?
# ★ H#3（2026-10-12 · 生长轴结构判据）：**退休要可见于一处** —— 每个 status: deprecated 的 ADR
#   必须在 archive/deprecated/ 留【指针记录】。这是【池形状】判据（对象是整个池，不是某一个文件）
#   ⇒ 按已立纪律住进池扫描（红侧用隔离目录证明，不进"unproven"）。
miss=""
for f in "$BASE"/ADR-*.md; do
  grep -q '^status: deprecated' "$f" || continue
  id=$(basename "$f" .md)
  [ -e "archive/deprecated/$id.md" ] || miss="$miss $id"
done
if [ -n "$miss" ]; then
  echo "★ RED: 已废弃 ADR 未在 archive/deprecated/ 留指针记录:$miss" >&2
  exit 2
fi
# ★ 3'a（2026-10-12 · 净 0）：正则必须有【已知会命中的正样本】—— 复用夹具（夹具就是那个样本）。
#   无样本 ⇒ **unproven**（不当绿）：具名列出，不致命 —— 与 4b 的"unproven · 待夹具"同一形态。
REG_TOT=$(python3 - "$BASE" <<'PY'
import glob, io, os, re, subprocess, sys
base=sys.argv[1]; tot=0; bad=[]
for f in sorted(glob.glob(base+'/ADR-*.md')):
    s=io.open(f,encoding='utf-8').read()
    if 'check: |' not in s: continue
    gid=os.path.basename(f)[:-3]; fx=os.path.join('fixtures',gid)
    if not os.path.isdir(fx): continue
    body=subprocess.run(['bash','-c',"awk '/^check: \\|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' '%s' | sed 's/^  //'" % f],capture_output=True,text=True).stdout
    for pat in set(re.findall(r"(?:grep|sed)[^\n']*?'([^']+)'", body)):
        if not re.search(r'[\\\[\]\(\)\|\*\+\?\^\{\}\$]', pat): continue
        tot+=1
        ok=subprocess.run(['bash','-c','grep -qE -- "$1" "$2"/*', '_', pat, fx]).returncode==0
        if not ok: bad.append(gid)
print('%d %d %s' % (tot, len(bad), ' '.join(sorted(set(bad)))))
PY
)
echo "正则样本：共 ${REG_TOT%% *} 条；其中【未证（无已知命中样本）】$(printf '%s' "$REG_TOT" | cut -d' ' -f2) 条 ⇒ unproven，不当绿"
[ "$(printf '%s' "$REG_TOT" | cut -d' ' -f2)" != "0" ] && echo "  未证正则所在门: $(printf '%s' "$REG_TOT" | cut -d' ' -f3-)" >&2
echo "OK: 全池 $n 份 ADR + 受管文档${extra:-（无）}（目录 ${DIR}）一致 —— 扫描面 = **全部 timing:post 闸门**（不止 pair # 见各 ADR 的 applies-to）"
