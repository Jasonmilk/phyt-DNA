# docs/ · INDEX（**按问题索引**，一行一条 —— 对齐 RNA.md §三 的漏斗第一段）
- [`docs/V1-TRIAGE.md`](V1-TRIAGE.md) — v1 遗产三栏清单（**已批准结案 2026-10-12**）

> **用法**：先在这一段找"我要回答的问题"，**只取那一份**（按需获取，不整目录读）。
> **与 `decisions/INDEX.md` 的分工**：那一份是**闸门**（能红的判据）；本份是**知识**（人读的说明与诊断）。
> **不许漏**：`docs/` 下每个 `*.md` 都必须在下面出现 —— 有闸门守着（`ADR-20261009-docs-must-be-indexed`）。

| 我要回答的问题 | 读这份 |
|---|---|
| **"一个裁决是否可信？真绿/假绿/真红/假红怎么分？"** —— 第二根轴（`verdict` × `validity`）、时序轴、两世界读数 | `docs/MULTIMETER.md` |
| **"本仓的规矩到底是什么？"** —— 可落地规范（闸门是叶子不是墙；有名·能红·会死·有度；三层验证栈） | `docs/PROTECTION.md` |
| **"G2 的第四圈（重放）为什么是空的？"** —— 经历→记账→结晶→重放，最后一圈只有定义没有实现 | `docs/REPLAY-MISSING.md` |
| **"一条闸门怎么会变成恒红装饰品（V=0）？"** —— 真实案例：`check` 只断言文件名 ⇒ 恒真 ⇒ 恒红；以及怎么诊断 | `docs/DNA-GATE-DIAGNOSIS.md` |
| **"账本怎么会读不出来？按行读为什么会读错？"** —— 实测 334 行 / 1069 条记录 ⇒ 不是 JSONL；以及"声明代替检查"长在闸门自己身上（只查编码、不查解析） | `docs/FINDING-2026-10-09-ledger-is-not-jsonl.md` |

## 根目录受管文档（按问题取用 · 索引门要求"存在就必须有人读"）

- [`README.zh-CN.md`](../README.zh-CN.md) — **中文读者从哪里开始读**
- [`VISION.md`](../VISION.md) — **这个生态要往哪走、边界在哪**
- [`DNA.md`](../DNA.md) — **不可删的基因是哪十条**
- [`SPEC.md`](../SPEC.md) — **规范长什么样（采用者照抄什么）**
- [`PLAN.md`](../PLAN.md) — **现在阶段是什么、还剩哪些未完成**
- [`GROWTH.md`](../GROWTH.md) — **它怎么长大的（年轮）**
- [`DEPRECATE.md`](../DEPRECATE.md) — **一个东西怎么死（三种终点）**
- [`position.md`](../position.md) — **本仓在哪里、不做什么**
- [`docs/PLAN-PAUSED.md`](PLAN-PAUSED.md) — **哪些事暂停了、怎么恢复（恢复点是一条命令）**
- [`docs/EXECUTION-DISCIPLINE.md`](EXECUTION-DISCIPLINE.md) — **一件事一次怎么推进（纪律，不占 must-read）**
