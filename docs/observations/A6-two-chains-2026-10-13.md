# 观测层收据 · A-6 两条链（2026-10-13）

**命令（可复现）**：夹具与判定器见本目录 `good.jsonl` / `wrongN.jsonl` / `no_cache.jsonl` / `zero_elapsed.jsonl` + `../a6-two-chains.sh`（下同）

## 两条链（不共享逻辑、不共享输入）
| | N 从哪来 | 校验用什么 | 共享 |
|---|---|---|---|
| **链1 = A-6 自身形态** | **脚本内变量**（"我写的那一行"） | `sed -n "${N}p"` + **python** | — |
| **链2 = 独立链** | **`grep -nE '"kind"[[:space:]]*:[[:space:]]*"run"' \| tail -1`** 现求 | **awk**（另一语言、另一套字段判据） | **不共享**（N 机制不同、语言不同、字段判据不同） |

## 结果（实测输出）
```
good.jsonl           N=1  链1: PASS                          链2: PASS
badjson.jsonl        N=2  链1: RED 坏JSON/空行              链2: RED elapsed_ms<=0 files<=0 缺judged-green 缺judged-red 缺unmeasurable 缺skipped-by-timing 缺skipped-by-cache
empty_pg.jsonl       N=1  链1: RED 缺judged-green,…（五类全缺） 链2: RED 缺五类
no_cache.jsonl       N=1  链1: RED 缺skipped-by-cache        链2: RED 缺skipped-by-cache
zero_elapsed.jsonl   N=1  链1: RED elapsed_ms<=0             链2: RED elapsed_ms<=0
wrongN.jsonl         N=2  链1: RED 非run行,elapsed_ms<=0,…   链2: PASS
```
**判定语义**：`PASS` = 不通过的反面；**`RED` = False = 不通过**（两条链都用同一语义，输出可机读）。
**错指非 run 行**：链1 被外部给的 N 带偏 ⇒ **红**；链2 自己求 N ⇒ 找到真 run 行 ⇒ **PASS** —— 两链**互为对照**，证明它们不是同一套逻辑的复制品。

## 两条链的**保真度教训**（本次实测踩到）
夹具最初用 `json.dumps` 生成（`"kind": "run"` **带空格**），而**生产格式是紧贴的** `"kind":"run"` ⇒ 链2 用精确串 `grep` ⇒ **找不到行**（假红）。
⇒ 修两侧：① 夹具**贴生产格式** ② 链2 用**空白容忍**正则 ⇒ 重测全绿/全红符合预期。
**⇒ 规则：夹具格式必须与生产格式同源，否则"判据红了"可能只是"夹具不像真的"。**

## A') 去 GNU 化后的矩阵（2026-10-14 · 6 故障 × 2 链）

| 夹具 | N | 链1（A-6 形态） | 链2（独立链） |
|---|---|---|---|
| good | 1 | **PASS** | **PASS** |
| badjson | 2 | RED 坏JSON/空行 | RED 该行不是合法 JSON |
| empty_pg | 1 | RED 坏JSON/空行 | RED 该行不是合法 JSON |
| no_cache | 1 | RED 缺skipped-by-cache | RED 缺skipped-by-cache |
| zero_elapsed | 1 | RED elapsed_ms<=0 | RED elapsed_ms 非正整数 |
| **wrongN（错指非 run 行）** | 2 | **RED** 非run行,… | **PASS**（自求 N ⇒ 找到真 run 行） |
| 真账本（不给 N） | 自动 | RED 坏JSON/空行 | PASS |

**两链措辞不同 ⇒ 逻辑确实不同**（"坏JSON/空行" vs "该行不是合法 JSON"；"elapsed_ms<=0" vs "elapsed_ms 非正整数"）。
**共享环境依赖 = `python3`**（可移植所需，**非共享逻辑**）。
**GNU CI 列 = unmeasurable（rc=4）**：本机 **无 GNU 工具**（`gsed`/`gawk`/`ggrep` 全无）⇒ **不填 0**；可移植性由"只用 `[[:space:]]` 类可移植写法"保证。  <!-- GNU 专属（理由：此处只是在列举"被检查的工具名"，不是使用它们） -->

## B') 审计：自洽表 + 应有表（命令派生）

```
自洽：1908 = 合法 1826 + 非法 82 ✅
应有（命令派生）：task=3（doubao 1 + 园丁裁定 2）✅ · correction=86 ✅ · selftest=3 ✅
不可派生 ⇒ **rc=4（unmeasurable，不许填 0）**：replay（无设计判据）· probe（取决于跑过多少次 + trap 期被擦）· run（**只能下界**）
verdict 口径：{pass:1612, block:89, correction:85, unmeasurable:8, skip:1} = 1795；不带 verdict 字段 31 行 ⇒ 1795+31=1826 ✅
差 = 被擦（trap 期）∪ 不可量 ⇒ 不填 0
```

## C) GNU / Linux CI 列 = 未证（2026-10-14）

**本机无 GNU 工具**（`gsed`/`gawk`/`ggrep` 全无）⇒ **GNU 列不可执行 ⇒ 记未证，不填 0**。 <!-- GNU 专属（理由：此处是**文档列举被检查的方言/工具名**，非使用它们） -->
**可移植性不靠"两列都跑过"支撑，而靠写法规避**：只用 shell 内建 + `git` + `python3` + 可移植 grep/sed 基本语法（`[[:space:]]` 类）。
**已知平台方言（真问题，非推测）**：`grep -P` 在 BSD **rc=2** · `awk` 的反斜杠-s 在 BSD **真死** · `sed` 的反斜杠-竖线 在 BSD **不生效**。 <!-- GNU 专属（理由：此处是**文档列举被检查的方言/工具名**，非使用它们） -->
**已撤回**：`grep -E` 的反斜杠-s"在 BSD 是死模式" —— 干净测量证明 BSD grep **支持**它（**不是**死模式）⇒ 该断言作废，**不许重跑**。
**若 adopt 宿主为 Linux**：GNU 列实跑（CI）为 **M1 开门前提**。
