#!/usr/bin/env bash
# sync-upstream.sh —— 采纳者同步【引擎】（**SOP 的机械化**，reviewer #二）
#
# 为什么必须与校验机制【同时】落地（不是"以后再说"）：
#   上游每次改引擎，各仓副本 + manifest 都要同步。**同步滞后若成为常态 ⇒ sha 失配成为常态红**
#   ⇒ 团队训练性忽略红灯 ⇒ **真篡改与真漂移会混在"已知失配"里一起被放过**。
#   这正是本仓 `red-lifecycle` 第三条（"不能总是红"）说的警报疲劳。
# ⇒ 故给出**一气呵成**的动作：拉取 → 覆盖引擎 → 重算清单 → 自校验。**不碰 tools/paths.env**（那是本仓自己的布局声明）。
#
# 用法（在【采纳者仓库】根目录跑）：
#   bash <上游路径>/tools/sync-upstream.sh <上游路径>
#   # 例：bash ../phyt-DNA/tools/sync-upstream.sh ../phyt-DNA
set -uo pipefail
UP="${1:?用法: sync-upstream.sh <上游 phyt-DNA 路径>}"; UP="${UP%/}"
[ -d "$UP/tools" ] || { echo "★ 上游路径不含 tools/：$UP"; exit 2; }
# 要同步的引擎文件 = 上游在本仓【已经存在】的那些（本仓用什么就同步什么；manifest 只登记这些）
same=0; list=""
for f in "$UP"/tools/*.sh; do
  b=$(basename "$f")
  [ "$b" = "sync-upstream.sh" ] && continue        # 同步器自身不参与
  [ -f "tools/$b" ] || continue                     # 本仓没有的引擎文件不硬塞
  cp "$f" "tools/$b"; chmod +x "tools/$b"; list="$list tools/$b"; same=$((same+1))
done
[ "$same" -gt 0 ] || { echo "★ 本仓 tools/ 里没有可同步的引擎文件"; exit 2; }
# 清单用【上游的哈希】生成（校验的是"与上游一致"，不是"与本仓一致"）
( cd "$UP" && shasum $list ) > tools/UPSTREAM.sha256
echo "已同步 $same 个引擎文件；清单已重算。"
bash tools/upstream-manifest.sh
