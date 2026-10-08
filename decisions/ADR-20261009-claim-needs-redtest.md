---
id: ADR-20261009-claim-needs-redtest
status: accepted
hard: false
effective-from: 2026-10-09
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历：v2.1 任务清单声称 T0 三缺陷已修，分支实际未落地 —— 声称必须能红验证才可信"
risk: normal
---

# 验收性声称必须附红测证据

## 真实经历

v2.1 任务清单（2026-10-09）声明"T0 · 已完成，无需执行"，声称三个缺陷已修
（hook 三层 fail-closed / CI step5 改 spec-lint / PROTECTION frontmatter + 演算示例）。

**核验分支现状：三条全部未落地** —— hook 还是 grep 旧版、CI 仍是永绿装饰、
PROTECTION 无 frontmatter，lesson ADR 也不存在。声称发生在对话里，修复在分支上缺席。

## 规则（治理层，hard: false）

1. 任何"已修复 / 已完成 / 已验证"的声称，必须能在**工件**上核验（CI 绿、心跳红、diff 为空）
2. 声称本身不是证据；**能红才是判据**（G5）—— 不能红的声称按"未验证"处理
3. 任务清单里的"已完成"标记不得先于工件落地（本 ADR 即由该违规结晶）
