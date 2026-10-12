---
id: ADR-20261009-GROWTH-max-3-entries
seq: 0005
status: accepted
hard: true
applies-to: ["GROWTH.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-GROWTH-max-3-entries"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "README 硬约束：年轮只保留最近 3 条（GROWTH 头注，v2.1 从散文结晶）"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  # ★ H#1（2026-10-12 折进本门，不生面）：条数 > 3 时，**溢出必须真的归档**。
  #   原判据只数条数 ⇒ "说了要归档"与"归档了"在它眼里一样 —— 那是【纸面纪律】。载体 `archive/growth/` 已在位 ⇒ 判据可落。
  skip(){ echo "具名跳过: $1（不判 —— 没有真值源就没有判据）" >&2; exit 4; }
  ROOT=$(git rev-parse --show-toplevel) || skip "非 git 工作区，归档载体不可定位"
  n=$(grep -c '^## 年轮 ·' "$F")
  if [ "$n" -gt 3 ]; then
    # ★ 0**d（2026-10-13）：**只数【年轮型】归档** —— 原先数"目录里任何文件" ⇒ 我搬进去的 `PLAN-gaps` 文档
    #   被误算成"已归档年轮" ⇒ 注入第 4 条时判据不再红（**腐化**）。口径精度 = 判据的生死。
    a=0
    for g in "$ROOT"/archive/growth/*.md; do [ -e "$g" ] || continue; grep -q '^## 年轮' "$g" && a=$((a+1)); done
    need=$((n - 3))
    if [ "$a" -lt "$need" ]; then
      echo "GROWTH 年轮 ${n} 条 > 3，而 archive/growth/ 只有 ${a} 条 ⇒ 溢出 ${need} 条必须真归档（纸面纪律 → 机器纪律）"
    fi
  fi
last-hit: null
hit-count: 0
supersedes: null
---

# GROWTH 年轮最多保留 3 条

## 出处

README 硬约束（v1 是散文）："GROWTH.md — growth rings (keep last 3)"。
年轮 = `## 年轮 ·` 开头的条目（`## 年轮格式` 说明段不计入）。

## 为什么

只长不落的树是标本（G6）；年轮是生长记录，不是档案柜 —— 更早的落叶归土进 `archive/`。

## 红测

`fixtures/<id>/inject.sh` 追加 3 个年轮条目 ⇒ 4 > 3 ⇒ 心跳报 RED
