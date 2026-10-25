---
id: ADR-20261023-override-must-carry-six-elements
seq: 9025
status: accepted
hard: true
applies-to: ["ledger/hits-*.jsonl"]
effective-from: 2026-10-23
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261023-override-must-carry-six-elements"
revisit-on: 2027-04-23
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-23 沙盒取证 · 吸收 JM-Zen 例外审批六要素时撞见）：CLI 放行通道原实现里 note 的默认值就是「无理由」⇒ 一道门可以被一句话放行，且没有日落、没有签署者、没有补偿、没有回退 ⇒ 护栏从「有出口」退化成「没护栏」；而同一本账里的 WIP 逃生门【已有】 commit/revisit_on/recovery 三要素规格且逾期具名红 ⇒ 同机制两副规格 = 漂移。事件=外挂审查（采用 JM-Zen 例外审批六要素 · 园丁 2026-10-23 裁定吸收）· 证据行=ledger/hits-2026.jsonl:2545 · 提交=6a74e04"
risk: normal
probe: yes
check: |
  # 只审【放行行】（override: true）—— 其余行不归本门。
  # ⚠️ 块内容【必须每行都以空格开头】：check_of 的 awk 遇顶格行即判定"块已结束" ⇒ check 被截断（本仓已三次踩这类写法）。
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  bad=$(python3 -c '
  import datetime, io, json, sys
  p = sys.argv[1]
  today = datetime.date.today().isoformat()
  agent_words = ("agent", "ai", "auto", "bot", "claude", "yuanbao", "copilot", "automation", "system", "llm", "model")
  rows = []
  for line in io.open(p, encoding="utf-8", errors="replace"):
      line = line.strip()
      if not line:
          continue
      try:
          d = json.loads(line)
      except Exception:
          continue
      if isinstance(d, dict) and d.get("override"):
          rows.append(d)
  signers = {}
  for d in rows:
      eid = d.get("event_id") or ""
      if eid:
          signers[eid] = d.get("signer") or ""
  out = []
  for d in rows:
      eid = d.get("event_id") or "?"
      need = ("signer", "revisit_on", "compensation", "recovery", "note")
      miss = [k for k in need if not d.get(k)]
      if miss:
          out.append("放行行缺要素 %s（event_id=%s）" % (",".join(miss), eid))
      sg = (d.get("signer") or "").lower()
      if sg.startswith("agent") or sg in agent_words:
          out.append("签署者是 Agent / 自动化（%s）⇒ Agent 只能提议，不能自批" % d.get("signer"))
      ro = d.get("revisit_on") or ""
      if ro and ro < today:
          out.append("日落已逾期（%s · event_id=%s）⇒ 例外不得无限延长" % (ro, eid))
      ref = d.get("ref_event_id")
      if ref and ref != "null" and ref in signers and signers[ref] == d.get("signer"):
          out.append("扩大覆盖却未换人签署（%s 给自己续期）⇒ 自批延期" % d.get("signer"))
  if out:
      print("；".join(out[:3]))
  ' "$F" 2>&1)
  [ -n "$bad" ] && echo "例外通道不合规（放行必须留六要素 · 日落 · 人类签署者）: ${bad}"
last-hit: null
hit-count: 0
supersedes: null
---

# 放行（override）必须留【完整例外】，不是一句话

## 为什么

护栏经济学有一条：**每道闸门必有留痕出口；没出口的硬门禁会在第一次使用时被绕过。**
出口是必须的——但**出口的规格**从来没人守：

- 放行通道原实现里，`note` 的默认值是 **「无理由」** ⇒ 一道门可以被一句话放行；
- 没有日落 ⇒ 例外没有时限 ⇒ **例外变成永久豁免**；
- 没有签署者 ⇒ 谁放的不知道；没有补偿控制、没有回退条件 ⇒ 放行的代价无人承担。

而**同一本账里**，WIP 逃生门是另一副规格：`commit` / `revisit_on` / `recovery`
缺一即红，逾期具名红并点名 commit。
**同机制两副规格 = 漂移。** 本门把 CLI 放行提到与逃生门同一规格。

## 六要素（缺一即红）

| 要素 | 字段 | 为什么不可省 |
|---|---|---|
| 理由 | `note` | 「无理由」的放行不留痕 |
| 日落 | `revisit_on` | 例外必须有时限，逾期未结 = 永久豁免 |
| 签署者 | `signer` | 谁放的，谁负责 |
| 补偿控制 | `compensation` | 被突破的约束由什么替代措施补偿 |
| 回退命令 | `recovery` | 写明何时、怎么回来 |
| 事件定位 | `commit` | 例外发生在哪个快照上 |

## 两条不对称性（本仓此前没有）

- **签署者必须是人类**：`signer` 为 `agent` / `auto` / `bot` / `claude` / `yuanbao`
  等 ⇒ 红。**Agent 只能提议，不能自批**——与「守卫不自签 / 他证禁自评」同族。
- **收窄可自动，扩大必须换人**：撤销放行（`revoke`）只需留痕，无需六要素；
  续期（`extend`）**必须换一个签署者**，原签署者给自己延期 ⇒ 红。

## 边界与具名局限

- 只审 `override: true` 的行；申诉账（`appeals-*.jsonl`）不归本门。
- **跨年续期不判**：若被续期的原行落在**另一年的账本文件**里，本门读不到它
  ⇒ 不判（判不了 ≠ 判出违规；跨文件关联由引擎层在写入时拒绝，不在本门）。
- 判据只读不写，不修改账本——修正一律追加，不回改旧行。

## 红测

`fixtures/<id>/inject.sh` 追加一行**缺 signer / 日落 / 补偿 / 回退**的放行行 ⇒ 必须红；
`counter.sh` 只 touch ⇒ 必须不红。
