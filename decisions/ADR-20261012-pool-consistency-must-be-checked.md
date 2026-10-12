---
id: ADR-20261012-pool-consistency-must-be-checked
seq: 9019
status: accepted
hard: false
applies-to: ["decisions/ADR-*.md"]
effective-from: 2026-10-12
timing: post
redtest: "validate --probe ADR-20261012-pool-consistency-must-be-checked"
revisit-on: 2027-04-12
expires-on: null
owner: "@jason"
origin: "reviewer ①③（2026-10-11/12）据此提炼：`check-pool.sh` 此前是**独立脚本、不是 ADR** ⇒ 没有夹具机制 ⇒ 只能永远 unproven；且我最初的隔离临时目录实验**模型本身是错的**（不在 git 索引里，引擎用 git ls-files 解析 glob）"
origin-amend: "【第 1 轮更正 · 2026-10-12 · 三要素：event_id=round-2026-10-12-paired-replay · 账本行=ledger/hits-2026.jsonl 普查/重放行 · commit=2cdb6a3】上文将本事写成"reviewer ①③"；本事的物理证据：pair 断**跨三笔**（5208c23/7a044c8/b210819）而配对闸门静默 = 存量违规按文件判永不被判"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  D=$(dirname "$F")
  # ★ 全池一致性（timing:post 的存量盲区补丁）：把【同目录的全部 ADR】交给 check-pool。
  #   关键：**只在它失败时打印**（引擎约定：任何 stdout 都是违规）⇒ 干净时静默。
  out=$(bash tools/check-pool.sh "$D" 2>&1) || printf '%s\n' "$out"
last-hit: null
hit-count: 0
supersedes: null
---

# 全池一致性必须被检查（timing:post 存量盲区的补丁 · 带夹具）

## 为什么它是 ADR 而不是脚本

`tools/check-pool.sh` 原本是**独立脚本** ⇒ 它**没有夹具机制** ⇒ 按出生律**永远停在 unproven**
（"能红"无从证明）。把它写成 ADR 后：`inject.sh` 可在**同一目录**里造一对"半对 supersede"，
`counter.sh` 保证内容不变的改动不改变结论 ⇒ **三边齐**，它才配叫闸门（不再只是"从不说不的 CI 步骤"）。

## 我的第一次实验为什么错（记下来，省下一次）

我用 `mktemp -d` 造隔离目录 ⇒ **没红** ⇒ 真因两条：
① `check-pool.sh` 是脚本，不是 ADR ⇒ **没有夹具驱动**（我手搓的调用不等于夹具模型）；
② **隔离目录不在 git 索引里** ⇒ 引擎的 `glob_first()` 用 `git ls-files` 解析 `applies-to` ⇒ **临时路径永远匹配不上**。
⇒ **教训：夹具必须活在"引擎能看到的世界"里**（走标准 `fixtures/` 机制 + 相对路径）。
★ 这是"**测试必须被证明接触了它测的东西**"的第二课（第一课是"文件名当 id"）。

---

## 状态降级记录（2026-10-12 · 如实 · 按出生律）

**降为 `hard: false`（图纸）**：夹具（标准 `fixtures/` 形态 + 手搓隔离目录两种）**都没能让它红**。
**已排除**：① 传绝对临时路径 ⇒ 已改相对（`<basename(DIR)>/ADR-*.md`）；② 脚本不是 ADR ⇒ 已改成 ADR + 夹具。
**精确待查点（一行实验就能定）**：**harness 复制出来的目录是否字面名为 `decisions`** ——
因为引擎的 `applies-to` glob **按路径字符串**匹配，若复制目录名不是 `decisions`，**任何闸门都选不中**。
实验：在夹具里 `echo "F=$F" >&2`，看 harness 交来的路径形态。
★ **其它闸门的夹具是能红的**（配对闸门三边齐）⇒ 所以差别不在"机制"，而在**嵌套调用所见的世界**。
**转正判据**：夹具能红 ⇒ 转回 `hard: true`（并据此决定 `check-pool.sh` 的最终调用形态）。
