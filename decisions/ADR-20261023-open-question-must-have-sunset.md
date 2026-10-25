---
id: ADR-20261023-open-question-must-have-sunset
seq: 9026
status: accepted
hard: true
applies-to: ["ledger/hits-*.jsonl"]
effective-from: 2026-10-23
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261023-open-question-must-have-sunset"
revisit-on: 2027-04-23
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-23 沙盒取证）：`RNA.md:13` 挂着一句「请园丁确认」—— 2026-10-11 提出，**12 天无人答复，且无任何机制让它在第 N 天报警**；`DEBTS.md` 另有 3 处「待裁定」同病。事件=自生长闭环立项（终局：agent 独立跑完一圈，人只修正歧义与丰满 VISION）· 证据行=ledger/hits-2026.jsonl:2545 · 提交=6b5fdf3"
risk: normal
probe: yes
check: |
  # 只审【问句行】（kind == "question"）—— 其余行不归本门。
  # ⚠️ 块内容【必须每行都以空格开头】：check_of 的 awk 遇顶格行即判定"块已结束" ⇒ check 被截断。
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  bad=$(python3 -c '
  import datetime, io, json, sys
  p = sys.argv[1]
  today = datetime.date.today().isoformat()
  agent_words = ("agent", "ai", "auto", "bot", "claude", "yuanbao", "copilot", "automation", "system", "llm", "model")
  qs, closed = [], set()
  for line in io.open(p, encoding="utf-8", errors="replace"):
      line = line.strip()
      if not line:
          continue
      try:
          d = json.loads(line)
      except Exception:
          continue
      if not isinstance(d, dict):
          continue
      k = d.get("kind")
      if k == "closure" and d.get("ref_event_id"):
          closed.add(d["ref_event_id"])
      elif k == "question":
          qs.append(d)
  out = []
  for d in qs:
      eid = (d.get("event_id") or "?")[:20]
      need = ("topic", "signer", "revisit_on", "compensation", "recovery")
      miss = [x for x in need if not d.get(x)]
      if miss:
          out.append("问句缺要素 %s（%s）⇒ 没有日落的问句 = 永久悬空" % (",".join(miss), eid))
      sg = (d.get("signer") or "").lower()
      if sg.startswith("agent") or sg in agent_words:
          out.append("问句签署者是 Agent（%s）⇒ Agent 只能提问，不能自己答复自己" % d.get("signer"))
      ro = d.get("revisit_on") or ""
      if ro and ro < today and (d.get("event_id") or "") not in closed:
          out.append("问句已逾期未结（%s · topic=%s）⇒ 悬空的歧义不会自己消失" % (ro, d.get("topic")))
  if out:
      print("；".join(out[:3]))
  ' "$F" 2>&1)
  [ -n "$bad" ] && echo "问句账不合规（开口必须有日落 · 人类答复者 · 逾期即红）: ${bad}"
last-hit: null
hit-count: 0
supersedes: null
---

# 问句必须有日落：无人执守时，问了就得有人答

## 为什么

自生长的终局是：**agent 在宿主项目里独立跑完一圈，人只修正歧义与丰满 VISION。**

这个终局**不需要**「起初就问清楚」——那会逼 `VISION.md` 变厚，
而 DNA 写死了「不预写未来的 ADR，不预建未来的闸门——蓝图是建造者的东西」。
**前瞻的正确形态不是预建，是开口会自己叫。**

而实证是：开口现在**不会叫**。

`RNA.md:13` 挂着一句「请园丁确认」，2026-10-11 提出 → 2026-10-23 **仍无人答复**，
且没有任何机制让它在第 N 天报警。`DEBTS.md` 另有 3 处「待裁定」同病。

⇒ 与 override 是**同一族病**：例外开了口没日落 ⇒ 变永久豁免；
问句开了口没日落 ⇒ **变永久悬空**。本门补上后者。

## 六要素（缺一即红）

| 要素 | 字段 | 为什么 |
|---|---|---|
| 歧义在哪 | `topic` | 没有坐标的问句无法被答复，也无法被检索 |
| 为什么它改变决策 | `note` | 按 SPEC §六：答不出"会让哪个未来决策不同" ⇒ 不沉降 |
| 日落 | `revisit_on` | **核心**。例外与问句都必须有时限 |
| 人类答复者 | `signer` | Agent 只能提问，**不能自己答复自己** |
| 答复前的默认动作 | `compensation` | 让"问"不阻塞：无人执守时按名目默认继续 |
| 怎么读回这本账 | `recovery` | `bash tools/validate.sh --ask-list` |

## 判据

1. 六要素缺一 ⇒ 红
2. `signer` 为 `agent` / `auto` / `bot` / `claude` 等 ⇒ 红（**Agent 只提议不自批**的问句版）
3. `revisit_on` 已过期 **且** 无 `kind:closure` 指向它 ⇒ 红

**结案 = 收窄** ⇒ 可自动：追加一行 `closure`（`ref_event_id` 指回问句），
**不改旧行**（append-only 的落地形态）。这与逃生门同一规格。

## 边界与具名局限

- 只审 `kind: question`；逃生门（`skip`）由 `ci-local` ①补 同段审计，**不归本门**。
- **跨文件结案不判**：若 `closure` 行落在**另一年的账本文件**里，本门读不到 ⇒
  不判（判不了 ≠ 判出违规）。跨年问句应在日落前结案，而不是靠跨文件关联。
- 判据只读不写。

## 红测

`fixtures/<id>/inject.sh` 追加一行**缺日落/答复者/默认动作**的问句 ⇒ 必须红；
`counter.sh` 只 touch ⇒ 必须不红。
