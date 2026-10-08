# GROWTH · 年轮
> 只保留最近 3 条。更早的移入 `archive/`（落叶归土，仍可检索）。
> **年轮只记 phyt-DNA 自己的经历**（v2.1 起清空镜像仓库的数字，每条可追溯出处）。

## 年轮 · 2026-W41

```
真实闸门   6 条 hard:true ADR（decisions/，ls 可核）
心跳红测   6/6 RED —— fixtures 注入反例全部被检出（validate.sh --probe）
新增结晶   5 ADR + 1 治理规则
           lesson-must-land-in-artifact · PLAN≤150 · layer1≤280 ·
           GROWTH≤3 · DNA 不可变 + claim-needs-redtest（hard:false）
引擎 bug   2 个红测暴露并修复：decisions/README 被误当闸门（gates 精确匹配）·
           spec-lint 文档示例误伤（gate7 只扫 *.sh）
CI         首红（缺基线）→ 补基线 → GREEN；红测注入违规 → RED → revert → GREEN
真实拦截   2 次（hook 实测：Edit DNA.md exit 2 / 非法 JSON fail-closed exit 2，ledger 可核）
override   0（无真实 override；缺口：破坏性 Bash 命令无闸门覆盖，见债务列）
hits/任务  0/0（本期全部 kind: selftest，无 kind:task 生产任务）
```

**本圈结晶**：v2.1 任务清单 T1–T8 —— 散文约束结晶为 ADR、hook 组装、CI 首跑、自身体证
**本圈死亡**：无（尚无闸门被冷存；首次合规冷存未发生）
**本圈判决**：声称 ≠ 落地 —— T0 声称已修而分支未修；只有"能红"才是判据（G5）

## 年轮格式（三数 + 三分类）

```
hits/任务        —— 内圈是否空转（趋势，非单点）
override_rate    —— 按【原因】分类（探针/追溯/引擎缺陷/真实误拦）
心跳红率 + 新增结晶数 —— 闸门是否还活着
```
