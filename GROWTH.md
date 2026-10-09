# GROWTH · 年轮
> 只保留最近 3 条。更早的移入 `archive/`（落叶归土，仍可检索）。
> **年轮只记 phyt-DNA 自己的经历**（v2.1 起清空镜像仓库的数字，每条可追溯出处）。

## 年轮 · 2026-W41

```
真实闸门   12 条 hard:true ADR（decisions/ADR-*.md；另有 2 份 hard:false 不计）
           —— 心跳口径见 decisions/INDEX.md（由 validate.sh --index 生成，不手写）
心跳红测   12/12 RED —— fixtures 注入反例全部被检出，且每条都有 counter.sh（双向可证伪）
新增结晶   本圈 +6：lesson-must-be-replayed（G2 第四圈）· shell-var-before-cjk-must-brace ·
           index-must-be-regenerated · VISION-must-exist-and-be-a-seed ·
           README-must-carry-the-one-command · DEPRECATE-must-exist
           lesson-must-land-in-artifact · PLAN≤150 · layer1≤280 ·
           GROWTH≤3 · DNA 不可变 + claim-needs-redtest（hard:false）
引擎 bug   2 个红测暴露并修复：decisions/README 被误当闸门（gates 精确匹配）·
           spec-lint 文档示例误伤（gate7 只扫 *.sh）
CI         首红（缺基线）→ 补基线 → GREEN；红测注入违规 → RED → revert → GREEN
自检拦截   2 次（payload 级实测：Edit DNA.md exit 2 / 非法 JSON fail-closed exit 2，ledger 可核）
override   0（无真实 override；缺口：破坏性 Bash 命令无闸门覆盖，见债务列）
hits/任务  0/0（本期全部 kind: selftest，无 kind:task 生产任务）
```

**本圈结晶**：v2.1 任务清单 T1–T8 —— 散文约束结晶为 ADR、hook 组装、CI 首跑、自身体证
**本圈死亡**：无（尚无闸门被冷存；首次合规冷存未发生）
**本圈判决**：声称 ≠ 落地 —— T0 声称已修而分支未修；只有"能红"才是判据（G5）
**本圈追加判决**：**没被踩过的地方，恰恰是没人看的地方** —— VISION/README/DEPRECATE 长期无闸门，
不是"不需要"，是"没人踩到"。补上它们之后，本仓 12 条闸门才覆盖了全部核心文件。

## 年轮格式（三数 + 三分类 · T8 定版）

```
hits/任务        趋势，非单点 —— 只算 ledger 中 kind:task 命中 / 生产任务数
                 （probe/scan/selftest 不计入），看内圈是否空转
override_rate    按【原因】分类：探针 / 追溯 / 引擎缺陷 / 真实误拦
                 每笔 override 必须带 note（原因）—— 只看比例会误判：
                 60% 可能是 100% 合理用途，必须按原因看分布
心跳红率         心跳 RED 数 / hard:true 闸门数（validate.sh --probe 全量）
新增结晶数       本圈新增 hard:true 闸门 + 治理规则数 —— 闸门是否还活着
独立申诉账       ledger/appeals-<年>.jsonl —— 运营者申诉独立留痕
                 破解"运营者自己分类自己"的自证陷阱（--appeal 写入，与 override 分账）
```
