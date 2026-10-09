# DEPRECATE 必须存在（会死的才算活）

---
id: ADR-20261009-DEPRECATE-must-exist
seq: 9005
status: accepted
hard: true
applies-to: ["DEPRECATE.md"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-DEPRECATE-must-exist"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-09 系统扫描）：本仓 DEPRECATE.md 无闸门。而它自己的第一行写着"会死的才算活。只长不落的树是标本。" —— 一个【机制】文档没有闸门，等于机制可以静默消失。"
risk: normal
check: |
  n=$(wc -l < "$F")
  [ "$n" -lt 3 ] && echo "DEPRECATE.md 只有 ${n} 行 —— 退休机制被清空或丢失（只剩会长、不会落）"
last-hit: null
hit-count: 0
supersedes: null
---

# DEPRECATE 必须存在（会死的才算活）

## 判据只管"它还在、还是它"

与 `ADR-20261009-VISION-must-exist-and-be-a-seed` 同形：**只断言"存在且没被清空"**（README 再加一条"带着那条命令"），
**不约束文风、不约束长度** —— 那是作者的事。
