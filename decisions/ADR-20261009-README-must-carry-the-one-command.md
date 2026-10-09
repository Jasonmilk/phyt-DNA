# README 必须存在，且必须带着那条可执行的命令

---
id: ADR-20261009-README-must-carry-the-one-command
seq: 9005
status: accepted
hard: true
applies-to: ["README.md"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-README-must-carry-the-one-command"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-09 系统扫描）：本仓 DNA/RNA/SPEC/PLAN/GROWTH/VISION 都有闸门，README.md 没有。而 README 是【入口文档】—— 一个不告诉你"怎么验证"的入口，等于把"先查再写"的门关在外面。"
risk: normal
check: |
  n=$(wc -l < "$F")
  [ "$n" -lt 10 ] && echo "README.md 只有 ${n} 行 —— 入口文档被清空（新读者无从下手）"
  grep -q 'validate.sh --probe-all' "$F" || echo "README.md 没有那条可执行的命令（validate.sh --probe-all）—— 入口没告诉人怎么验证"
last-hit: null
hit-count: 0
supersedes: null
---

# README 必须存在，且必须带着那条可执行的命令

## 判据只管"它还在、还是它"

与 `ADR-20261009-VISION-must-exist-and-be-a-seed` 同形：**只断言"存在且没被清空"**（README 再加一条"带着那条命令"），
**不约束文风、不约束长度** —— 那是作者的事。
