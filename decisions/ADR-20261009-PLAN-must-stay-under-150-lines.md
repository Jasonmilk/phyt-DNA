---
id: ADR-20261009-PLAN-must-stay-under-150-lines
seq: 0003
status: accepted
hard: true
applies-to: ["PLAN.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-PLAN-must-stay-under-150-lines"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "README 硬约束：PLAN ≤150 行（v2.1 从散文结晶为可执行 ADR）"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  [ "$(wc -l < "$F")" -gt 150 ] && echo "$F $(wc -l < "$F") 行 > 150"
  # ★ H#2（2026-10-12 折进本门，不生面）：**计划只放未完成** —— 完成态标记（✅）必须移入 archive/deprecated/。
  #   本门正文写明范围：本门判的是 **PLAN 的形状** = 行数上限 + 只放未完成（名 ⊇ 判据见 body）。
  c=$(grep -cF '✅' "$F")
  [ "$c" -gt 0 ] && echo "$F 里有 ${c} 处完成态标记（✅）⇒ 已完成项必须移入 archive/deprecated/（计划只放未完成）"  # ★ 3（2026-10-12）：**跨文件核对** —— 移出必须留指针，且指针指向的归档必须真在。
  skip(){ echo "具名跳过: $1（不判 —— 没有真值源就没有判据）" >&2; exit 4; }
  ROOT=$(git rev-parse --show-toplevel) || skip "非 git 工作区，归档载体不可定位"
  n_arch=$(ls "$ROOT"/archive/deprecated/PLAN-done-*.md | grep -c .)
  if [ "$n_arch" -gt 0 ]; then
    grep -q 'archive/deprecated/PLAN-done-' "$F" || echo "有归档 ${n_arch} 份，但 $F 里没有指向它的指针（移出必须留指针：移出 ≠ 删除）"
    said=$(grep -oE '移出 [0-9]+ 条' "$F" | head -1 | grep -oE '[0-9]+')
    # ★ H#2b（2026-10-12）：**归档档里的每一条必须自带完成态标记 ✅** —— 不含 ✅ 的行 = 混进了待办（零新字段：用已有表格列）。
    arc=$(ls "$ROOT"/archive/deprecated/PLAN-done-*.md | head -1)
    nook=$(grep '^|' "$arc" | grep -v '^| 条目' | grep -vE '^\|[[:space:]]*-' | grep -vc '✅')
    [ "$nook" -gt 0 ] && echo "归档档 ${arc##*/} 有 ${nook} 条没有 ✅（归档只收已完成；待办应留在 PLAN 或 PLAN-PAUSED）"
    if [ -n "$said" ]; then
      rows=$(grep -c '^|' "$(ls "$ROOT"/archive/deprecated/PLAN-done-*.md | head -1)")
      [ "$rows" -ge "$said" ] || echo "归档档条目数 ${rows} < 声明移出的 ${said} 条 ⇒ 移出没落全（移出 ≠ 删除，但也 ≠ 丢）"
    fi
  fi

last-hit: null
hit-count: 0
supersedes: null
---

# PLAN.md 不得超过 150 行

## 出处

README 硬约束（v1 是散文）："PLAN.md is must-read … Total load ≤280 lines"。
v2.1 把它从**散文**结晶成有 id、有 check、有心跳、会死的 ADR —— V2 的全部价值主张。

## 为什么是 hard:true

- 判定对象是**可枚举的结构化属性**（行数），bash 可精确判定
- PLAN 是唯一 must-read，失控膨胀 = 每个新会话的注意力预算被蚕食（G8）

## 红测

`fixtures/<id>/inject.sh` 追加 151 行 ⇒ 心跳必须报 RED

---

## 本门判的是【PLAN 的形状】（范围声明 · 2026-10-12 H#2）

1. **行数上限 150**（原名所载）；
2. **只放未完成**：出现 `✅` 完成态标记 ⇒ 具名红，条目须移入 `archive/deprecated/`（生长轴：计划是"待办"，不是"日记"）。
⇒ **名是历史的，范围以本节为准**（同门面门的做法）。
