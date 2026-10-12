---
id: ADR-20261013-probe-scope-must-be-tagged
seq: 9022
status: accepted
hard: false
applies-to: ["tools/validate.sh", "ledger/*.jsonl"]
timing: post
effective-from: 2026-10-13
revisit-on: 2027-01-13
expires-on: null
owner: "@jasonmilk"
origin: "图纸（hard:false）：2026-10-13 人类裁定定标签语义；**证据尚未产生** —— 实现时才由 touched/full 的台账产生（图纸不补三要素蒙混）"
risk: normal
check: |
  :   # 设计稿：hard:false ⇒ 引擎 gates() 不收它；实现与判据在下一轮（先定语义，再落机器）。
last-hit: null
hit-count: 0
---

# `--probe-touched` 设计稿：**探针的作用域必须被打标签**（2026-10-13）

## 一、它要解决的问题（一句话）

**"我证过了"这句话里缺主语** —— 证过的是**全部**，还是**我碰过的那一块**？
今天全仓只有**一种**探针（`--probe-all`，周期全量）⇒ 一次只改一个门的人，要么跑全部（慢），要么**不跑**（绿是空的）。

## 二、标签语义（**先定语义，后落机器**）

| 标签 | 值 | 含义 |
|---|---|---|
| `scope` | `full` | 本轮跑了**全部**在册门 ⇒ 可以宣称"全池已证" |
| `scope` | `touched` | 本轮只跑**被改动文件所触及**的门 ⇒ **只能宣称"碰过的那块已证"** |
| `reason` | 自由文本（**必须是触发源**，如 `staged: decisions/ADR-x.md`） | 为什么跑这个作用域 |

**铁律（本设计稿的核心）**：**任何"绿"的宣称必须携带 `scope`**。
`touched` 的绿**不得**被当作 `full` 的绿使用（这正是"短路绿必须打标签"的机器化）。

## 三、`touched` 怎么算（派生，不写死）

```
git diff --name-only HEAD            # 改动面（真值源 = git，不是清单）
  ⇒ 对每个在册门：其 applies-to 与改动面相交 ⇒ 该门进 touched 集
  ⇒ 无门触及 ⇒ 报"touched 为空"（**不是绿**：什么都没证）
```

## 四、与周期的关系（**周期全量保留**）

**`--probe-all` 的周期全量一次都不减** —— `touched` 是**按需**补充，不是替代。
理由：`touched` 看不见"没人碰的旧违规"（那正是 `check-pool.sh` 存在的理由）。

## 五、验收（下一轮实现时用）

1. **能红**：构造一个只改 A 门、而 B 门有旧违规的样本 ⇒ `touched` 绿 ⇒ **报告必须显示 `scope=touched`**（否则红）。
2. **能绿**：`--probe-all` ⇒ `scope=full`。
3. **台账**：每条探针记录（`ledger/hits-*.jsonl`）带 `scope` 字段 ⇒ **缺字段即红**（判据在下一轮落）。
4. **不实现**：本设计稿**不带 check**（`hard: false`）—— `:  ` 只是占位；**先定语义，再落机器**。
