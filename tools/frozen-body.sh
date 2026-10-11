#!/usr/bin/env bash
# frozen-body.sh —— 计算/校验 ADR 的【冻结体】指纹（freezing-probe 的引擎侧）。
#
# ★ 为什么存在（reviewer 刺一 · 2026-10-11）：那次违宪【机器全程全绿】—— CI 过 · 心跳过 · probe 过，
#   抓它的是人的一句话。引擎验证"check 是否被满足"，**不验证"check 是否被合法修改"**。
#   ⇒ 本脚本补上那一半：**每份 ADR 首发入库时记下它的"冻结体"指纹；此后正文一改即红。**
#
# 【白名单】（与 decisions/README.md 的条文严格同源 —— 刺五要求"同源"）：
#   · 前言键：status · supersedes · last-hit · hit-count（元数据页可改）
#   · 正文末尾的"取代指针块"：以 `---` 分隔、且含"已由"的那一段（supersede 的落款）
#   · 其余（前言的非白名单键 + 正文主体）⇒ **冻结**，改了就是违宪。
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
body(){ # $1 = ADR 路径 → 打印"冻结体"
  awk '
    BEGIN{fm=0}
    /^---$/{ if(fm==0){fm=1; next} else if(fm==1 && !done){fm=2; done=1; next} }
    { if(fm==0) next                     # 前言之前
      if(fm==1){ if($0 ~ /^(status|supersedes|last-hit|hit-count):/) next; print; next }
      print }
  ' "$1" | awk 'BEGIN{keep=1} {buf[NR]=$0} END{ n=NR; # 去掉【末尾含"已由"的 --- 块】
      cut=0; for(i=n;i>=1;i--){ if(buf[i] ~ /^---$/ && cut==0){ ok=0; for(j=i;j<=n;j++) if(buf[j] ~ /已由/) ok=1; if(ok) cut=i-1 } }
      for(i=1;i<=(cut?cut:n);i++) print buf[i] }'
}
case "${1:-}" in
  --write)
    out="decisions/.frozen-body.sha256"; : > "$out"
    for f in decisions/ADR-*.md; do printf '%s  %s\n' "$(body "$f" | shasum -a 256 | cut -d' ' -f1)" "$(basename "$f")" >> "$out"; done
    echo "已写入 ${out}（$(wc -l < "$out" | tr -d ' ') 个文件）"; exit 0 ;;
  --check-file)
    f="${2:?用法: $0 --check-file <ADR 路径>}"; man="decisions/.frozen-body.sha256"
    [ -f "$man" ] || { echo "缺 $man（先跑 --write）"; exit 0; }
    name="$(basename "$f")"; h=$(grep -E "  ${name}$" "$man" | head -1 | awk '{print $1}')
    [ -n "$h" ] || { echo "该 ADR 不在冻结体清单里（新文件？跑 tools/frozen-body.sh --write）"; exit 0; }
    now=$(body "$f" | shasum -a 256 | cut -d' ' -f1)
    if [ "$now" != "$h" ]; then echo "冻结体被改（违宪）：${name} —— 元数据白名单外的一字一句都不许动（改要走 supersede）"; exit 1; fi
    exit 0 ;;
  --check)
    man="decisions/.frozen-body.sha256"; [ -f "$man" ] || { echo "缺 $man（先跑 --write）"; exit 0; }
    fail=0
    while read -r h name; do
      f="decisions/$name"; [ -f "$f" ] || { echo "冻结体清单里的 $name 已不存在"; fail=1; continue; }
      now=$(body "$f" | shasum -a 256 | cut -d' ' -f1)
      [ "$now" = "$h" ] || { echo "冻结体被改（违宪：正文/前言非白名单键被动过）: $name"; fail=1; }
    done < "$man"
    [ "$fail" = 0 ] && echo "OK: 全部 ADR 的冻结体未被改动（元数据白名单除外）"
    exit $fail ;;
  *) echo "用法: $0 --write | --check" ;;
esac
