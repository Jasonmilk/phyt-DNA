# fixtures/<gate-id>/ · 心跳的反例

## 唯一文件：`inject.sh`

作用：造一个**真实的违规样例**，供心跳检出。
- 必须**接受环境变量 `$F`**（与 `applies-to` 同源）—— 否则注入目标 ≠ 检测目标
- 必须**注入到隔离文件**，绝不污染真实资产（ADR-0009）

```bash
#!/usr/bin/env bash
# 好：隔离注入
printf '违规内容\n' > tools/_probe_dummy.sh

# 坏：污染真实引擎
printf 'git checkout -- .\n' >> tools/validate.sh   # ← ADR-0009 禁止
```

## 铁律
1. 注入的缺陷必须**真的越过阈值**（否则心跳恒 NOT RED）
2. 注入目标必须与 `applies-to` 展开的路径**一致**
3. **不得**出现 `git checkout -- .` / `git clean -fd` / `git stash`

---

## BACKFLOW 2026-10-09（P5 · P11）
· 反例夹具与目录名

### P5 · 目录名必须是 **gate-id**（由脚本定位，不靠人记）
`--probe <gate-id>` 按 `fixtures/<gate-id>/inject.sh` 找夹具。
**目录名写成别的（例如按主题命名）会得到"[A] 缺 fixture"** —— 这是**具名拒绝**，不是静默跳过。
**⇒ 命名由脚本消费 ⇒ 命名错误当场现形**（别靠 lint 事后报错：确定性归脚本）。

### ★ P11 · 只有正例是不够的：必须还有 **反例** `counter.sh`

**为什么**：`inject.sh` 追加字节**同时改变内容与 mtime** ⇒
**若判据被改回"读时钟"，正例照样变红** ⇒ **闸门发现不了自己的退化**。

> **一个判据在"变了"与"没变"两个世界里都能红 ⇒ 按 Ω 是装饰品。**

**⇒ 每个 gate 应有第二个文件**：

```
fixtures/<gate-id>/inject.sh   正例：注入缺陷 ⇒ 判据【必须】红
fixtures/<gate-id>/counter.sh  反例：只做"内容不变"的改动（如 touch）⇒ 判据【必须】不红
```

**`--probe` 会依次跑两者**；缺 `counter.sh` 时**具名记录** "negative direction unproven"，
**不静默算通过**。
