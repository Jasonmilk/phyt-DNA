---
id: DOC-README-v2
owner: "@jasonmilk"
revisit-on: 2027-04-09
effective-from: 2026-10-09
---

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/Jasonmilk/phyt-DNA/actions/workflows/phyt.yml"><img src="https://github.com/Jasonmilk/phyt-DNA/actions/workflows/phyt.yml/badge.svg?branch=v2" alt="CI 状态" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/Jasonmilk/phyt-DNA" alt="许可证：Apache-2.0" /></a>
</p>

# phyt-DNA

> 通用自生长项目方法论模板与权威源。
> 所有采用本方法论的项目都锚定到它，以避免版本漂移与歧义。
> **权威源：`v2` 分支（默认分支）。** `v1` 分支仅作为历史档案保留 —— 请勿锚定到它。

## 第二根轴：一个判决*可信*吗？（回流 2026-10-09）

`pass | block` 分不清下面这四种：

| | **真** | **假** |
|---|---|---|
| **绿** | 通过**且能被证明会红**（有夹具越过阈值） | 通过但**没有夹具** —— 从未有人证明它会变红 |
| **红** | 因一个**可具名的**原因而失败（判据本身） | 因**别的东西**而失败（工具用法错误 / 前置缺失 / 同一条命令给出不同回答） |

> **单报 `pass` 不可报告 —— 必须是 `pass + alive`。**
> **一个没有夹具的绿色集合不是绿，是未测量（UNMEASURED）。**

见 **`docs/MULTIMETER.md`**。在首个采用者身上实测：79 条 "proven" 中 78 条没有夹具；
在**同一个**环境下跑 8 次，得到 6 个不同的指纹（`proven 53..79`、`red 2..10`、`held 1..31`）。

## 理念

**植物不是被设计出来的 —— 它从一颗种子长出来**，自发地、持续地、缓慢地，
依环境条件与内在基因而长。

传统软件方法论把项目当成机器 —— 画蓝图、装零件、调试、运行。但活的 project
**不是**那样。它们更像植物：从种子（核心愿景）出发，由环境（用户需求、技术约束、
生态变化）与内在基因（不可变原则）驱动，生长出来。

phyt-DNA 借用植物隐喻来描述这套方法论 —— **我们不是在做植物学研究。**
DNA 是不可变基因（原则与流程），RNA 是加载协议（怎么读基因、怎么引导生长），
SPEC 是知识本体（完整叙事），PLAN 是当前生长阶段，GROWTH 是生长记录，
DEPRECATE 是死亡与退休，archive 是历史沉积。

**phyt-DNA 让项目像植物一样生长，而不是像机器一样被建造。**

**保护是生长的护栏，不是墙。**
方法论保护规范：[`docs/PROTECTION.md`](docs/PROTECTION.md)

---

## V2 新增了什么

V1 只是一份文档模板。**V2 加上了那些"真正跑过才被证明"的部分。**
演进走 **diff，不走 rewrite** —— 下表就是演进记录。
债务列不得隐藏任何东西。

| | v1 | v2 | 债务（未完成 —— 不隐藏） |
|---|---|---|---|
| 闸门 | README 里的散文（无 id、无 check、不会死） | **ADR 上的 `hard: true` 字段**（有 id、有 `check:`、有心跳、会死） | — |
| 检查逻辑 | 硬编码在引擎里 | **ADR 自带 `check:`**（引擎内零硬编码闸门） | — |
| 时机 | 不区分 | **`timing: pre\|post`**（路径在前，内容在后） | — |
| 验证 | 无 | 三层栈 + 自引用边界 | — |
| CI | 无 | 5 步 + 红测（首红 → 基线 → 转绿；注入违规 → 红 → revert → 绿） | — |
| 钩子拦截 | 无 | `.claude/` 钩子已装配，载荷级已测（编辑 DNA.md → exit 2） | **未在真实 agent 任务中观测到**（T2 缺口 —— 未声称已验证） |
| `--cull` | 只在对话里的法则 | 判定器就位（`validate.sh --cull`，只报告） | **尚无执行**：冷存需人批准；真实冷存一次都没发生过 |
| 年轮格式 | 只有四个总数 | 三个数 + 三个分类（hits/task · 放行率 · 心跳率） | **趋势 / 分布 / 按原因归类的放行字段**（T8） |
| 60 分钟参数 | 硬编码 | 可标定字段 | **一年后重新标定**（revisit-on 2027-04-09） |

### 循证

[`docs/PROTECTION.md`](docs/PROTECTION.md) 里的每一条结论都打了标签：
**measured（已实测）/ research-backed（研究背书）/ unverified（待验证）**。
未验证条目不得写进 DNA。

本仓库实测（v2.1，2026-10-09）：**6 条 `hard: true` 闸门 · 心跳 6/6 RED ·
5 份 ADR 已结晶 + 1 条治理规则 · 探测发现并修掉 2 个引擎 bug ·
CI：首次 RED（缺基线）→ GREEN → 红测 RED → GREEN · 2 次自测拦截（载荷级）。**

---

## 现状 · 真实状态（诚实边界）

| 项 | 状态 |
|---|---|
| 闸门机制 | ✅ 6 条 `hard: true` 闸门，心跳 6/6 RED，CI 全绿 |
| **内环转动** | ⚠️ **0/0 —— phyt-DNA 自身零条 `kind: task` 生产任务** |
| 物理拦截 | ⚠️ 仅载荷级，**从未在真实 agent 任务中观测到** |
| `--cull` | ✅ 判定器就位，但**尚无被告**（没有一条闸门见过 20 次生产任务） |

> 机械完整 ≠ 生产验证。这套系统在它自己的自检里全绿，
> 而**它在生产中一次都没转过**。
> 第一个真实项目才会产出真实的数字。

---

## 快速开始

```bash
# 1. 把方法论骨架拷进你的项目
#    v2：仓库根就是模板（原先的 template/ 已并入根目录）
git clone git@github.com:Jasonmilk/phyt-DNA.git /tmp/phyt-dna
cp -r /tmp/phyt-dna/{DNA.md,RNA.md,SPEC.md,PLAN.md,GROWTH.md,VISION.md,DEPRECATE.md,decisions,ledger,fixtures,tools} <your-project>/

# 2. 把你的第一条闸门写成 ADR（不需要改任何代码）
#    见 examples/ADR-EXAMPLE.md，复制后填入你自己的 check：
cp examples/ADR-EXAMPLE.md <your-project>/decisions/ADR-<date>-<your-first-gate>.md

# 3. 打开 CI（唯一的真门禁 —— pre-commit 可以用 --no-verify 跳过）
cp examples/phyt.yml <your-project>/.github/workflows/
#    在资产基线落地之前，首次运行必然是 RED：
cd <your-project> && ./tools/check-baseline.sh --update && git add tools/baseline.sha256 && git commit

# 4. 可选：用于实时拦截的钩子
#    位于 examples/claude-code/ —— 可选就是可选，想要才拷
#    ⚠ 未声称已验证：物理拦截仅载荷级（编辑 DNA.md → exit 2）；
#    它在真实 agent 任务中从未发生过。要验证请自己跑一个真实任务。
cp -r examples/claude-code/ <your-project>/.claude/
```

**W0 规则：一开始零脚本。** 手工做完一个真实任务并记账。
在拿到真实数据之前就写脚本 = 靠猜决定哪些闸门配存在。

---

## 采用 · 三步把 V2 落进你的项目

README 的承诺：*"每个采用本方法论的项目，都在其第一个公开里程碑落地那份零成本清单。"*
V2 第一次让这句话**可执行** —— 以前是手工打勾，现在是 `cp -r` 加 CI 自动检查：

1. **拷骨架**（快速开始第 1 步）：6 份根文档 + `decisions/ ledger/ fixtures/ tools/` 进你的项目
2. **写第一份 ADR**（第 2 步）：把你的第一条散文约束结晶成可执行闸门 —— 带 `id`、`check:`、心跳，且会死
3. **开 CI**（第 3 步）：`.github/workflows/phyt.yml` 五步闸门，每次 push 都查
   - 首次运行**必然 RED**（缺资产基线）—— 按第 3 步落地基线即可转绿；不要绕过它
   - 之后的每次 push：资产完整性 / spec-lint / 心跳 / 全仓扫描 / 反装饰 —— 5 项全过才算绿

钩子（第 4 步）保持**可选**：装配已验证；物理拦截从未在真实 agent 任务中发生过 —— 别声称它已验证。

---

## 目录

```
仓库根（v2：根就是模板；原先的 template/ 已并入）
  DNA.md          不可变基因（10 条原生 + 6 条派生法则）
  RNA.md          加载协议（三层注意力预算）
  SPEC.md         知识本体
  PLAN.md         当前生长阶段 —— 会话开始必读
  GROWTH.md       年轮（保留最近 3 条）
  VISION.md       种子
  DEPRECATE.md    死亡与退休（3 种结局）
  decisions/      唯一真源 —— 闸门住在这里
  ledger/         append-only 账本
  fixtures/       心跳用的反例
  tools/          引擎 + linter（零硬编码闸门）

docs/PROTECTION.md   完整规范
examples/            可直接复制的 ADR、CI workflow、claude-code/ 钩子包
```

---

## 闭环关键节点

- **总负载：≤280 行，≤4500 tokens。** `PLAN.md` 必读 —— 新会话必须先加载 PLAN
  以确认当前阶段，避免把力气花在已完成的阶段上。
- **按任务关键词匹配分卷。** 只加载与当前任务相关的卷；绝不一次全加载。

每个采用本方法论的项目，都在其第一个公开里程碑落地那份零成本清单。
