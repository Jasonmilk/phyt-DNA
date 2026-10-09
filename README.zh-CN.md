---
id: DOC-README-ZH-v2
owner: "@jasonmilk"
revisit-on: 2027-04-09
effective-from: 2026-10-09
---

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/Jasonmilk/phyt-DNA/actions/workflows/phyt.yml"><img src="https://github.com/Jasonmilk/phyt-DNA/actions/workflows/phyt.yml/badge.svg?branch=v2" alt="CI 状态" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/Jasonmilk/phyt-DNA" alt="Apache-2.0" /></a>
  <a href="https://github.com/Jasonmilk/phyt-DNA/stargazers"><img src="https://img.shields.io/github/stars/Jasonmilk/phyt-DNA?style=flat-square&label=stars" alt="GitHub stars" /></a>
</p>

# phyt-DNA

> 通用自生长项目方法论模板与权威源。
> 所有采用此方法论的项目的锚点，避免版本漂移与歧义。

## 理念

**植物不是被设计的——它从种子生长**：自发、持续、缓慢，依环境条件与内在基因展开。

传统软件方法论把项目当机器——画蓝图、装配零件、调试、运行。但活的项目**不是**这样的。
它们更像植物：从种子（核心愿景）出发，由环境（用户需求、技术约束、生态变化）与
内在基因（不可变原则）驱动生长。

phyt-DNA 借植物隐喻描述这套方法论——**我们不是在讲植物学。**
DNA 是不可变基因（原则与流程），RNA 是装载协议（如何读基因、引导生长），
SPEC 是知识本体（完整叙事），PLAN 是当前生长阶段，GROWTH 是生长记录，
DEPRECATE 是死亡与退役，archive 是历史沉积。

**phyt-DNA 让项目像植物一样生长，而不是像机器一样被制造。**

**保护是生长的扶手，不是围墙。**
方法论保护规范：[`docs/PROTECTION.md`](docs/PROTECTION.md)

---

## V2 新增了什么

V1 只是文档模板。**V2 补上了真正跑起来才证明需要的部分：**
演进走 **diff，不走 rewrite**——下表即演进记录，债务列不许藏。

| 项 | v1 | v2 | 债务（未完成，不许藏） |
|---|---|---|---|
| 闸门 | README 散文（无 id、无 check、不会死） | **`hard: true` 字段的 ADR**（有 id、有 `check:`、有心跳、会死） | — |
| 判定 | 引擎硬编码 | **ADR 自带 `check:`**（引擎零硬编码闸门） | — |
| 时机 | 未区分 | **`timing: pre｜post`**（路径先于内容） | — |
| 验证 | 无 | 三层栈 + 自指边界 | — |
| CI | 无 | 5 步 + 红测（首红 → 补基线 → 绿；注入违规 → RED → revert → 绿） | — |
| hook 物理拦截 | 无 | `.claude/` hook 组装完成，payload 级实测（Edit DNA.md → exit 2） | **未在真实 agent 任务中发生**（T2 缺口，不声称已验证） |
| `--cull` | 法只在对话里 | 法官入位（`validate.sh --cull`，只报告不删） | **执法未落地**：冷存要人批准，尚无真实冷存发生 |
| 年轮格式 | 只有四个总数 | 三数 + 三分类（hits/任务 · override_rate · 心跳红率） | **趋势/分布/override 按原因分类字段**（T8） |
| 60 分钟参数 | 硬编码 | 可校准字段 | **跨年后校准**（revisit-on 2027-04-09） |

### 循证

[`docs/PROTECTION.md`](docs/PROTECTION.md) 中的每条结论都带标签
**已实测 (measured) / 研究背书 (research-backed) / 待验证 (unverified)**。
未验证项不得写入 DNA。

本仓库实测数据（v2.1，2026-10-09）：**6 条 hard:true 闸门 · 心跳 6/6 RED ·
结晶 5 条 ADR + 1 条治理规则 · 探针红测抓出并修复 2 个引擎 bug ·
CI：首红（缺基线）→ 绿 → 红测 RED → 绿 · 2 次自检拦截（payload 级）。**

---

## 快速开始

```bash
# 1. 把方法论骨架拷进你的项目
#    v2：仓库根即模板（原 template/ 已并入根）
git clone git@github.com:Jasonmilk/phyt-DNA.git /tmp/phyt-dna
cp -r /tmp/phyt-dna/{DNA.md,RNA.md,SPEC.md,PLAN.md,GROWTH.md,VISION.md,DEPRECATE.md,decisions,ledger,fixtures,tools} <your-project>/

# 2. 写你的第一条闸门（不需要改代码）
#    参考 examples/ADR-EXAMPLE.md，拷贝并填上你自己的 check：
cp examples/ADR-EXAMPLE.md <your-project>/decisions/ADR-<日期>-<你的第一条闸门>.md

# 3. 开 CI（唯一真门禁——pre-commit 可被 --no-verify 绕过）
cp examples/phyt.yml <your-project>/.github/workflows/
#    首次运行必然 RED，直到资产基线落盘：
cd <your-project> && ./tools/check-baseline.sh --update && git add tools/baseline.sha256 && git commit

# 4. 可选：hook 实时拦截
#    ⚠ 未声称已验证：物理拦截仅 payload 级实测（Edit DNA.md → exit 2），
#    尚未在真实 agent 任务中发生。装上后请先跑一次真实任务自行验证。
cp examples/pretooluse-gate.sh <your-project>/.claude/hooks/pretooluse-gate.sh
cp examples/.claude-settings.json <your-project>/.claude/settings.json
```

**W0 铁律：先零脚本。** 手工跑一个真实任务并记账。
没有真实数据前写脚本 = 在猜哪些闸门值得存在。

---

## 当前真实状态（诚实边界）

| 项 | 状态 |
|---|---|
| 闸门机制 | ✅ 6 条 `hard: true`，心跳 6/6 RED，CI 全绿 |
| **内圈转速** | ⚠️ **0/0 —— phyt-DNA 自身尚无 `kind: task` 生产任务** |
| 物理拦截 | ⚠️ 仅 payload 级实测，**未在真实 agent 任务中发生** |
| `--cull` | ✅ 法官已到位，但**尚无被告**（无闸门经历过 20 个生产任务） |

> 机制完备 ≠ 已被生产验证。这套系统在自检中全绿，
> **在生产中一次没转过**。第一个真实项目才会给出真数据。

---

## 落地 · 三步把 V2 用起来

README 的承诺：*"Every project adopting this methodology lands the zero-cost checklist at its first public milestone."*
V2 让这句话**第一次可执行**——以前是手工打勾，现在是 `cp -r` + CI 自动检查：

1. **拷贝骨架**（快速开始第 1 步）：6 个根文档 + `decisions/ ledger/ fixtures/ tools/` 全部进项目
2. **写第一条 ADR**（第 2 步）：把第一条散文约束结晶成可执行闸门——有 `id`、有 `check:`、有心跳、会死
3. **开 CI**（第 3 步）：`.github/workflows/phyt.yml` 五步门禁，push 即检查
   - 首次运行**必然 RED**（缺资产基线）——按第 3 步补基线即复绿，不要绕开
   - 之后每次 push：资产完整性 / spec-lint / 心跳 / 全仓扫描 / 防装饰，5 步全过才算绿

hook（第 4 步）保持 **optional**：组装已验证，物理拦截未在真实 agent 任务中发生——不要声称已验证。

---

## 目录结构

```
根目录（v2：仓库根即模板，原 template/ 已并入根）
  DNA.md          不可变基因（10 条原生 + 6 条衍生法则）
  RNA.md          装载协议（3 层注意力预算）
  SPEC.md         知识本体
  PLAN.md         当前生长阶段 —— 新会话必读
  GROWTH.md       生长年轮（只留最近 3 条）
  VISION.md       种子
  DEPRECATE.md    死亡与退役（3 种结局）
  decisions/      唯一真相源 —— 闸门都在这里
  ledger/         append-only 账本
  fixtures/       心跳用反例
  tools/          引擎 + 检查器（零硬编码闸门）

docs/PROTECTION.md   完整规范
examples/            即拷即用的 ADR、hook、CI workflow
```

---

## 闭环关键节点

- **总载荷：≤280 行、≤4500 token。** `PLAN.md` 是必读——新会话必须先读 PLAN
  确认当前阶段，避免在已完成阶段上浪费力气。
- **按任务关键词匹配装载量。** 只装载与当前任务相关的卷，永远不要一次全量加载。

每个采用此方法论的项目，都会在第一个公开里程碑把这份零成本清单落地。
