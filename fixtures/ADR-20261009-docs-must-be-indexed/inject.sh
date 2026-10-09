#!/usr/bin/env bash
# inject.sh — 真形状：一份知识被 INDEX 漏掉（它明明存在，却无人入口）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_docsidx_backup
sed -i '' '/DNA-GATE-DIAGNOSIS/d' "$F" 2>/dev/null || sed -i '/DNA-GATE-DIAGNOSIS/d' "$F"
