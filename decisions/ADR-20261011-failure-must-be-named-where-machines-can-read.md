---
id: ADR-20261011-failure-must-be-named-where-machines-can-read
status: accepted
hard: false
effective-from: 2026-10-11
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
---

# 失败必须写在【机器读得到的地方】—— `tools/emit-failures.sh` 作为引擎资产登记（ADR-0004 走正门）

## 背景（实证，不是设想）

读 CI 失败的四条常规通道**依次被堵死**：

| 通道 | 实测结果 |
|---|---|
| `logs`（run 日志 zip） | **403** —— `Must have admin rights to Repository` |
| `artifacts`（上传的日志文件） | **401** —— 需凭据 |
| `job summary` | 网页可读，但 API 的 `check_run.output.summary` **恒为 null** |
| **`annotations`** | **公开可读**（无需凭据、无需 admin） |

⇒ 结论：**要把失败送到 agent 手里，唯一可用的通道是 annotations。**

## 决定

新增引擎资产 **`tools/emit-failures.sh`**：把日志里的失败行（`^test .* FAILED` · `panicked at` ·
`CHECKER ERROR` · `No such file` · `Could not find` …）写成 `::error title=失败具名::<行>`；
**绿时也输出 `::notice title=失败具名::读取 <日志>`** ⇒ 接线是否生效**在绿 run 上就能看见**。

## 判据（能红 · 能绿 · 覆盖面）

· **能绿**：任意 run 的 annotations 里出现 `::notice … 读取 <路径>`（**证明接线生效**，不必等红）。
· **能红**：日志含失败行时，annotations 里出现 `::error title=失败具名::…`（**本地合成日志已自证**）。
· **自动发现**：传入路径缺失 ⇒ 取 `/tmp` 下最新 `*.log` 并**明说读了哪个**（路径写死是该资产的第一个 bug，
  由执行者在 Cellrix 实证 ⇒ **工具自身必须容忍调用方写错路径**）。

## 战功（本资产存在的直接理由）

同一日连中**三次根因**（全部由它给出，且**无一需要人肉粘贴**）：
① helix-mind ⇒ `Could not find protoc`（缺系统依赖）
② anaphase ⇒ `CHECKER ERROR: 3 file(s) … does not know`（计数器把 `ci/__pycache__/*.pyc` 当未知扩展名）
③ anaphase ⇒ `cannot read … helix-mind/tools/install-hooks.sh`（跨仓判据的被检对象未被物化）

## 分层与边界

· **引擎纪律**：脚本**各仓自带一份**（不跨仓取文件 —— 单仓 checkout 下兄弟仓路径不存在，那种写法会静默失效）。
· **上游指纹**：本资产进入 `tools/UPSTREAM.sha256` ⇒ 采纳者用 `shasum -c` 一行查出副本是否漂。
· **不是硬闸门**（`hard: false`）：它**不判红绿**，只**把失败搬运到可读处** —— 判红的仍是各仓自己的判据。
