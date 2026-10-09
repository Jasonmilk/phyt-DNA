# ADR-20261009：INDEX 必须与生成器一致（生成物不得漂）

---
id: ADR-20261009-index-must-be-regenerated
seq: 9003
status: accepted
hard: true
applies-to: ["decisions/INDEX.md"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-index-must-be-regenerated"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历：RNA.md §三 早已规定四段漏斗第一段是 INDEX（一行一条），而该文件长期不存在 ⇒ '先查再写'没有落点 ⇒ 采用者两次把已有物当成新发现（端口闸门早已有 port_table_test.js；想/说/做 的通道与门契约与 I7 早已有）。补了生成器之后，新的风险是【生成物会漂】：改了闸门却没重新生成 ⇒ INDEX 变成一份陈旧的手写体。"
risk: normal
check: |
  # 生成物必须与生成器一致 —— 否则它就成了"第二份真相"（A5），而它恰恰是"先查"的落点。
  # 比较从表头那行开始（文件顶部有"勿手改"的注释，那不是表的一部分）。
  gen=$(bash tools/validate.sh --index)
  have=$(sed -n '/^| 闸门 id /,$p' "$F")
  [ "$have" != "$gen" ] && echo "INDEX 与生成器不一致（改了闸门却没重新生成）⇒ 跑：bash tools/validate.sh --index > decisions/INDEX.md"
last-hit: null
hit-count: 0
supersedes: null
---

# INDEX 必须与生成器一致

## 为什么（人类问过：如何避免下次的你又突然发现）

**"记到 ADR/PLAN/GROWTH/README 哪个"这个问法本身是问题** —— 一个事实记四处 ⇒ 能四处漂。
**⇒ 正解不是第五处，是**一个"先查"的落点**。**

`RNA.md §三` 早已规定：四段漏斗第一段 = **INDEX（一行一条，常驻 ≤40 行）**。
**而该文件长期不存在** ⇒ 采用者两次把**已有物**当成新发现。

**⇒ 本 ADR 守的不是"INDEX 存在"，而是"INDEX 不漂"**：
它是**生成物**（`bash tools/validate.sh --index`），而生成物一旦被提交就会**过时**。

## 判据

**把提交的 `decisions/INDEX.md` 与"现场生成的"逐表比对**（从 `| 闸门 id` 那行起）⇒ **不同即红，并给出修复命令。**

**夹具**：`inject.sh` 往 INDEX 里塞一行 ⇒ 必须红；`counter.sh` 只 touch ⇒ 结论不变。
