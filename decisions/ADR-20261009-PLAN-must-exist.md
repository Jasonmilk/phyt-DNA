---
id: ADR-20261009-PLAN-must-exist
seq: 0001
status: accepted
hard: true
applies-to: ["PLAN.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-PLAN-must-exist"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历：V2 打包时测试脚本 cp 覆盖 + rm -f 误删了 template/PLAN.md"
risk: normal
check: |
  [ "$(wc -l < "$F")" -lt 3 ] && echo "PLAN.md 内容过少或已被清空（它是 must-read）"
last-hit: null
hit-count: 0
supersedes: null
---

# PLAN.md 必须存在且有内容

## 真实经历（第 6 次同族现身）

打包 V2 时，测试脚本执行了 `cp /tmp/big.md ./PLAN.md` 再 `rm -f PLAN.md`，
**覆盖了 phyt-DNA 自己的 template/PLAN.md 并删除**。

讽刺之处：PLAN.md 是本方法论**唯一 must-read** 的文件（README 明文规定
"a new session must load PLAN first"），而它被自己的作者用测试脚本删掉了。

## 判据

`f × C`：f 中等（模板文件被误操作是常见事故），C = 高（PLAN 丢失 ⇒ 每个新会话
都失去阶段上下文 ⇒ 重复已完成的工作）。**第 1 次发生即结晶。**

## 规则
1. 仓库根 `PLAN.md` 必须存在且 ≥3 行（v2.1：template/* 已升至仓库根，本闸门自托管）
2. 任何测试脚本**不得**以模板文件名做临时文件的名字
3. 测试临时文件一律用 `mktemp` 或 `_probe_*` 前缀
