---
id: DOC-PLAN-PAUSED
owner: "@jasonmilk"
revisit-on: 2027-01-12
effective-from: 2026-10-12
---

# 暂停区（PLAN-PAUSED · **按需拉取，不随 must-read**）

**为什么独立成文**：`PLAN.md` + `RNA.md` 受 **layer1 行数门**约束（实余量见读数）⇒ 暂停项**不该挤占加载路径**。
**三行格式**（**恢复点必须是一条命令**）：
```
暂停：<动作·一句话>
恢复点：<一条命令>
恢复条件：<立刻可做 / blocked-by: …> ｜ 优先级 + 落盘轮次 ⇒ 满 N=3 轮未恢复自动转 DEBTS
```
**日落**：满 **N=3 轮**未恢复 ⇒ **自动转 `DEBTS.md`**（或销号）。**限量：总计 ≤12 行 · 每条 ≤3 行**（见底即裁，**不提额**）。

---

**当前：0 条**（"死代码断言覆盖 tools/*.sh"已按裁定 4 转入 DEBTS，标 blocked-by: 真实任务驱动）。

---

## 待办队列（按需拉取 · 不占 layer1）

1. I 闭环最后一边（DEPRECATE/archive/task → DNA 自检，复用 `revisit-on` 当输入）
2. J W0 自举（方法学自身受 task 计数约束）
3. K/L/M（卡模板 author · spec/philosophy 复位 · 认知协议进 RNA）
