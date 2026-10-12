---
id: DOC-PLAN-PAUSED
owner: "@jasonmilk"
revisit-on: 2027-01-12
effective-from: 2026-10-12
---

# 暂停区（PLAN-PAUSED · **按需拉取，不随 must-read**）

**为什么独立成文**：`PLAN.md` + `RNA.md` 受 **layer1 行数门**约束（实余量见读数）⇒ 暂停项**不该挤占加载路径**。
**四行格式**（**恢复点必须是一条命令**，不是散文）：

```
暂停：<动作，一句话>
恢复点：<一条命令>（不是散文）
恢复条件：<能不能立刻做 / blocked-by: …>
优先级：P0/P1/P2 · 落盘于 <轮次> ⇒ 满 N 轮未恢复自动转 DEBTS
```

**日落**：满 **N=3 轮**未恢复 ⇒ **自动转 `DEBTS.md`**（或销号）。**限量：≤5 条 / ≤12 行**（见底即裁，**不提额**）。

---

暂停：死代码断言覆盖 `tools/*.sh`
恢复点：`bash tools/spec-lint.sh docs/PROTECTION.md`（扩作用域后须全绿且无误报）
恢复条件：blocked-by: 需要 **heredoc 感知**的追踪（引擎在 heredoc 里嵌 python/awk ⇒ 逐行深度追踪必然漂移）；未做
优先级：P2 · 落盘于 2026-10-12 ⇒ 满 3 轮转 DEBTS

暂停：（空位）
恢复点：—
恢复条件：—
优先级：—
