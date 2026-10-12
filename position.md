---
id: DOC-POSITION
owner: "@jasonmilk"
revisit-on: 2027-01-12
effective-from: 2026-10-12
---

# position.md —— **定位与边界**（被建物的真值源）

> **来源**：v1 `template/spec/position.md`（`git show origin/v1:template/spec/position.md`）。
> **为什么不整层恢复 `spec/`**：v2 删掉了 v1 的 `spec/` 目录层（那一层有目录假设）。
> 按园丁 2026-10-12 裁定：**只恢复最高优先的这一件**；`philosophy` 进权威卷；其余两件写明承载者。
> **v1 空模板节已删**（它只是骨架占位，留着会让本文件"看起来有内容"）。

## 一、自定义原则（采用者自由裁量区）

**本仓允许采用者加自己的原则，但形状有要求**：**引用必须能自我说明归属** ——
本仓路径写 `tools/…`；跨仓路径写 `<repo>/…`（裸 `docs/…` 在别的仓里指向不明）。
⇒ 该形状**已落成判据**（门面门 ③）：裸形状的跨仓引用 ⇒ **具名红**。
⇒ **原则不是口号**：写得出形状、落得成判据、红得起名字 —— 才算本仓认的"原则"。

## 二、本仓定位（三句话 · 写实）

1. **本仓是什么**：Helix 生态的**方法论 + 闸门骨架**（可被 adopt 的模板），**不是产品、不是运行时** —— 仓里没有业务逻辑。
2. **本仓不做什么**：**不含采用者的实现与真理**；采用者的真值在采用者仓，本仓只供**方法**与**可执行的判据**。
3. **本仓的真值源**：`VISION.md` 管方向 · `DNA.md` 管基因 · `SPEC.md` 管规范 · `RNA.md` 管协议 · `PLAN.md` 管待办 · `GROWTH.md` 管年轮 · `DEPRECATE.md` 管终点。

## 三、v1 `spec/` 五件的承载者（裁定 4：**不新建目录层**）

| v1 `spec/` 件 | v2 承载者 |
|---|---|
| `position.md` | **本文件**（最高优先，已恢复） |
| `philosophy.md` | **`VISION.md` 的核心基因（五个名字）+ `DNA.md` 的十条基因**（权威卷 ⇒ 哲学不另立文件） |
| `architecture.md` | `README.md` 的架构段 + `docs/MULTIMETER.md`（两轴）+ `decisions/INDEX.md`（活的闸门图） |
| `contract.md` | `docs/PROTECTION.md`（授权三级 + 通道契约）+ `README.md` 的命令表 |
| `safety.md` | `docs/PROTECTION.md`（危险动作形状 + fail-closed）+ 执行闸（`examples/claude-code/hooks/`） |

## 四、红线是人的尺度，机器只管报数

v1 有一条「**400-line decoupling red line**」（`origin/v1:README.md:185`，**Human-approved 2026-09-09**）。
**本仓不把它造成门**：400 行是**注意力**的边界（人一次读得完多少），不是**机器**能判的对错。
⇒ 机器只提供读数（`wc -l` 排行），**阈值归人**。把人的尺度写成门 = 让机器替人做它做不了的事。
