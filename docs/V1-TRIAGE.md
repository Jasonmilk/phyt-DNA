---
id: DOC-V1-TRIAGE
owner: "@jasonmilk"
revisit-on: 2027-01-12
effective-from: 2026-10-12
status: approved
---

# v1 遗产三栏清单（**园丁一次性批准 2026-10-12** ⇒ v1 归档结案）

> **结案声明**：本表经园丁**一次性批准**，**v1 归档结案，"不再回头"生效** —— 此后不再以"v1 有 v2 没有"为由开工。
> **执行记录**：`spec/` **不新建目录层**（避免带回 v1 的目录假设）；
> `position.md` ⇒ **已恢复为根目录 `position.md`**（最高优先，含五件的承载者声明表）；
> `philosophy` ⇒ **进权威卷**（`VISION.md` 核心基因五名 + `DNA.md` 十条基因），不另立文件；
> `architecture`/`contract`/`safety` ⇒ **写明承载者**（见 `position.md` 的表），不新建。
> `archive/growth` · `archive/deprecated` 载体已在位（H 的前置）。

**语料 = `git ls-tree -r origin/v1`（21 件）** —— 不是 v2 工作区（我为此错过一次：`400` 在 `origin/v1:README.md:185`，人批 2026-09-09）。
**门槛排序**：0 **真实调用者**「没有它，有人会痛吗？」· 1 **可机械化**（否则 ⇒ RNA 软指令）· 2 **`--index` 查冗余**。
**① 哲学自洽 / ② 逻辑闭环 = 【补回之后】的验收项**，不作补回理由。**不接受"v1 有 v2 没有"当理由。**
**代际**：v2 = 唯一活版本；代际性质 = 纸面纪律 → 机器纪律。

## A. 首个候选（裁定 0 指定：`spec/` 载体 + `archive/` 载体）

**对表结果（实测，非印象）**：v1 有 `template/spec/` **五件**，v2 **整层没有** ——

| v1 件 | v2 现状 | 三栏 | 门槛 0 谁痛 | 门槛 1 可机械化 | 门槛 2 冗余 |
|---|---|---|---|---|---|
| `template/spec/architecture.md` | 无 | **补回（载体 + 真值源）** | 采用者：架构真值源缺位 | 载体先建 `spec/`；判据 = 被 `docs/INDEX.md` 列出 | 与 `docs/`（方法）不冗余 |
| `template/spec/contract.md` | 无 | **补回** | 同上（契约=被建物的接口） | 同上 | 同上 |
| `template/spec/philosophy.md` | 无 | **补回** ← 与既有 P2 项同源 | 哲学真值源缺位（旧记：`ls docs/spec/` 无） | 同上 | 同上 |
| `template/spec/position.md` | 无 | **补回** | 定位/边界真值源 | 同上 | 同上 |
| `template/spec/safety.md` | 无 | **补回** | 安全边界真值源 | 同上 | 同上 |
| `archive/growth/` · `archive/deprecated/`（v2 新造） | **已建（`.gitkeep`）** | 已在位 | 生长轴归档无处落 | 载体可判 | 与 `docs/archive/`（文档谱系）不冗余 |

## B. 其余 v2 缺失件

| v1 件 | v2 现状 | 三栏 | 理由 |
|---|---|---|---|
| `template/decisions/ADR-0001-template.md` | **已迁移但换了路径**：`examples/ADR-EXAMPLE.md` | **写明承载者（不补）** | 门槛 0 无新痛源（采用者照样有模板）；只欠一句承载声明 ⇒ 属"写明承载者"栏 |

## C. 已迁移（不列）：其余 15 件

`README.md` · `README.zh-CN.md` · `docs/PROTECTION.md` · `template/{DNA,RNA,SPEC,VISION,PLAN,GROWTH,DEPRECATE}.md`（v2 已并入根目录）

## D. 观测项（**不造门** · 裁定 0）

| v1 件 | 处置 |
|---|---|
| `origin/v1:README.md:185`「**400-line decoupling red line**（Any single file > 400 lines，tests excluded，Human-approved 2026-09-09）」 | **只进观测层读数**：`bash -c 'wc -l $(git ls-files "*.md") \| sort -rn \| head -5'`。**不造门** —— 红线是**人**的尺度（注意力），机器只管报数；造门会与文档注意力打架。 |

---

## E. 结案后的观测项（唯一允许的回头方式）

| 项 | 读数命令 |
|---|---|
| 400 行红线（v1 遗产，**不造门**） | `wc -l $(git ls-files "*.md") | sort -rn | head -5` |
| v1 归档态 | `git log origin/v1 -1 --format="%h %ad %s" --date=short` |
