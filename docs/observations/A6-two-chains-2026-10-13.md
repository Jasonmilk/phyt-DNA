# 观测层收据 · A-6 两条链（2026-10-13）

**命令（可复现）**：夹具与判定器见本目录 `good.jsonl` / `wrongN.jsonl` / `no_cache.jsonl` / `zero_elapsed.jsonl` + `../a6-two-chains.sh`（下同）

## 两条链（不共享逻辑、不共享输入）
| | N 从哪来 | 校验用什么 | 共享 |
|---|---|---|---|
| **链1 = A-6 自身形态** | **脚本内变量**（"我写的那一行"） | `sed -n "${N}p"` + **python** | — |
| **链2 = 独立链** | **`grep -nE '"kind"\s*:\s*"run"' \| tail -1`** 现求 | **awk**（另一语言、另一套字段判据） | **不共享**（N 机制不同、语言不同、字段判据不同） |

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
