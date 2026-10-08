---
id: ADR-20261009-lesson-must-land-in-artifact
seq: 0002
status: accepted
hard: true
applies-to: ["examples/phyt.yml", ".github/workflows/**"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-lesson-must-land-in-artifact"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历：v4 教训'别用 git diff --exit-code'只写进文档，v2 发布的 phyt.yml 里装饰性检查仍在"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  grep -qE '^\s+git diff --exit-code' "$F" && echo "装饰性检查残留（教训未落地到工件）: $F"
last-hit: null
hit-count: 0
supersedes: null
---

# 教训必须落到工件，不能只落到文档

## 真实经历

方法论迭代（v4）已总结过教训："别用 `git diff --exit-code` 做 CI 装饰性检查"。
但该教训只写进了**文档**——v2 发布的 `examples/phyt.yml` 第 5 步仍是
`git diff --exit-code HEAD -- .claude/`（CI checkout 下恒绿，永不红）。

**文档里的教训 = 没落地的教训。** 闸门必须能红，且必须盯着工件本身。

## 判据

f：高（CI 工件是唯一真门禁，装饰性步骤会让门禁变摆设）；C：高（伪绿 = 伪证）。
**第 1 次发现即结晶。**

## 规则
1. CI 工件（`examples/phyt.yml` / `.github/workflows/**`）不得含装饰性 `git diff --exit-code` 检查
2. 任何教训必须落到**可检查的工件**（ADR + check + fixture），文档提及不算落地
3. 本闸门是 post 型：判定对象是工件内容（缩进的 run 命令行），不是对话记录

## 红测
`fixtures/<id>/inject.sh` 把装饰检查写回工件 ⇒ 心跳必须报 RED
