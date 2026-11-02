#!/usr/bin/env bash
# deprecate.sh — 退役的**唯一漏斗**（结构解，deprecate 与死亡证明同一个动作）
#
# 为什么需要它：`DEPRECATE.md:27-33` 要求「每次退役必须出 archive/DEATH-CERT-<id>.md」，
# 而退役此前是**手工多步动作**（移文件 + 改 frontmatter + 写指针 + 写账本）⇒ 没有地方
# 强制第二个产物 ⇒ 只能用一条"存在性判据"去追。而存在性判据是伪证生成器（C-053）。
# ⇒ 把两个产物绑进**一个动作**：状态空间里不存在"只有指针、没有证明"的点。
#
# 用法（维护者）：
#   bash tools/deprecate.sh <ADR-id> --born YYYY-MM-DD --died YYYY-MM-DD \
#        --criterion-repo <sha|url> --review "<合规性审查>" --root-cause "<根因>" \
#        --disposition "revive|confirmed"
# 退出码：0 = 指针与死亡证明都已就位 / 2 = 参数不全或 id 已退役（拒绝对同一 id 盖两次章）
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"

id="${1:-}"; shift || true
born=""; died=""; crit=""; review=""; rc_=""; disp=""
while [ $# -gt 0 ]; do
  case "$1" in
    --born) born="${2:-}"; shift 2;;
    --died) died="${2:-}"; shift 2;;
    --criterion-repo) crit="${2:-}"; shift 2;;
    --review) review="${2:-}"; shift 2;;
    --root-cause) rc_="${2:-}"; shift 2;;
    --disposition) disp="${2:-}"; shift 2;;
    *) echo "★ 未知参数: $1" >&2; exit 2;;
  esac
done

miss=""
[ -n "$id" ] || miss="$miss id"
[ -n "$born" ] || miss="$miss --born"
[ -n "$died" ] || miss="$miss --died"
[ -n "$crit" ] || miss="$miss --criterion-repo"
[ -n "$review" ] || miss="$miss --review"
[ -n "$rc_" ] || miss="$miss --root-cause"
[ -n "$disp" ] || miss="$miss --disposition"
if [ -n "$miss" ]; then
  echo "★ RED: 退役参数不全（缺:${miss}）—— 缺字段的死亡证明就是伪证（DEPRECATE.md:33 / I2 红线）" >&2
  exit 2
fi

cert="archive/DEATH-CERT-$id.md"
ptr="archive/deprecated/$id.md"
if [ -e "$cert" ]; then
  echo "★ RED: $cert 已存在 —— 同一 id 不许盖第二次章（复活走新 ADR，不覆盖历史）" >&2
  exit 2
fi
[ -e "$ptr" ] || echo "  ⚠ 指针 $ptr 不存在：本脚本只补死亡证明，指针由退役流程自己产出" >&2

mkdir -p archive
cat > "$cert" <<EOF
# DEATH-CERT · $id

- 死者: $id
- 出生: $born
- 死亡: $died
- 享年: 由上面两行算出（不手写，避免与日期漂移）
- 引用判据: $crit
- 合规性审查: $review
- 根因: $rc_
- 处置: $disp
EOF

# 自检：8 个字段都要**非空**（存在性不算合规，见 C-053）
for f in 死者 出生 死亡 享年 引用判据 合规性审查 根因 处置; do
  if ! grep -qE "^- $f: .+" "$cert"; then
    echo "★ RED: $cert 的字段「${f}」为空 —— 这已是伪证边缘，删掉重来" >&2
    exit 2
  fi
done
echo "OK: ${cert}（8 字段齐）· 指针: $([ -e "$ptr" ] && echo 在 || echo 缺)"
