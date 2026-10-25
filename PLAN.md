# PLAN · 当前生长阶段

> ## 一条命令（改完文件就跑它 —— 这是本仓的招牌动作）
>
> ```bash
> bash tools/validate.sh --probe-all
> ```
>
> **读数怎么用**（三行都要看，缺一就不完整）：
> · `基线（未注入）` = **仓库现在合不合规** → 红 ⇒ 仓库有病
> · `注入后 RED` = **闸门活不活着** → 这是**夹具造出来的**红，**不是仓库的病**
> · `反例守住` = **判据双向可证伪** → 内容不变的改动不该改变结论
>
> 细节见 `docs/MULTIMETER.md`；账本落在 `ledger/hits-2026.jsonl`（自动写，不需手抄）。

> ## 当前一件（判据必须机检，并引用它自己的验收命令）
>
> **④ 跨宿主上工 · 首件真活**：拿套件辅助宿主做一件真事（不是挑毛病、不是当考官）。硬前提：`PHYT_LEDGER` 已锚定；
> 首宿主在 Linux 则 GNU 列需 Actions 实跑（现记【未证】）。
> **完成判据（机检）**：① 宿主账本出现 `"source": "ci-local"` 行 ≥1；② `docs/observations/host-first-*.md` 含五个数（被拦/返工/假绿/`elapsed_ms`/调用数）；③ 母仓 `ci-local --fast` 仍全绿 10 项。
> **不是**"把宿主跑绿"——宿主有自己的病，工具只负责让读数可信、让错不沉默。
>
> **上一件（已结清）**：P0-4 收口 —— rc 契约（0/2/4/其他非零）· 四调用方步调 · 采用者启用包 · 幽灵降本立族名。
>   自证命令：`bash tools/ci-local.sh`（全绿 ⇒ 9 项）· `bash examples/claude-code/hooks/hook_test.sh`（9/9）

> **新会话必读本文件**，确认当前阶段，避免重复已完成的工作。
> 本文件是执行载体，**不是待办清单**——任务系统服务计划，不替代计划。

## 当前阶段

**阶段：V2 已发布**（W0 完成，等待 adopt 到真实项目）

## 阶段表

| 波 | 内容 | 状态 |
|---|---|---|
> **已完成的历史条目已按生长轴移出**（W0 与 G1–G4 · 移出 5 条）⇒ `archive/deprecated/PLAN-done-2026-10-12.md`。**计划只放未完成**（判据在 `ADR-…-PLAN-must-stay-under-150-lines` 的正文范围里）。
| **W1** | adopt 到真实项目，挂上 decisions/ledger/tools | ⏳ **当前** |
| W2 | 注入接入（UserPromptSubmit + additionalContext） | 待办 |
| W3 | 任务系统（task-gen / claim / verify / board-gen） | 待办 |
| W4 | 首跑双场景（任务链 + 第一个真实 BLOCKED 闭环） | 待办 |
| W5 | 回流对齐（零分叉确认） | 待办 |
| W6 | 首次生长复核（读年轮三个数，执行冷存） | 待办 |

## 铁律

- **每波超限即停**：降范围 / 拆两刀 / 升预算 / 回退上一格
- **W0 零脚本**：没有真实数据前写脚本 = 在猜哪些闸门值得存在
- **首跑优先于完美**：工具层完成立即首跑，不为验证工具而造工作

---

> 2026-10-09 的缺口扫描已移出加载路径 ⇒ `docs/PLAN-GAPS-2026-10-09.md`（正文照录）。

---

## 活跃区（≤5 行 · 随加载）

**当前一件**：`--probe-touched` 设计稿（写 ADR 定标签语义，**不实现**；周期全量保留）

**待办队列与暂停项在 [`docs/PLAN-PAUSED.md`](docs/PLAN-PAUSED.md)（按需拉取）· 纪律在 [`docs/EXECUTION-DISCIPLINE.md`](docs/EXECUTION-DISCIPLINE.md)（**不占 must-read**）**。
