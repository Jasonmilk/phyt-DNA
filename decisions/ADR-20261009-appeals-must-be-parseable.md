# ADR-20261009：申诉账每行必须是可解析的 JSON

---
id: ADR-20261009-appeals-must-be-parseable
seq: 9009
status: accepted
hard: true
applies-to: ["ledger/appeals-2026.jsonl"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-appeals-must-be-parseable"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-09 x 光）：`ledger/appeals-2026.jsonl`（独立申诉账）此前【无任何守卫】—— 而它的全部意义就是'独立留痕、破解运营者自己分类自己的自证陷阱'。它自己坏了，这个承诺就没了。同一天我们还实测到 hits 账出现过非法 UTF-8（一个三字节汉字丢首字节，根因是 第32条 $var（ 陷阱）⇒ 同族风险真实存在。"
risk: normal
probe: yes
check: |
  # 每行必须是合法 JSON（含合法 UTF-8）—— 申诉账的全部意义是"能被独立读到"。
  # ⚠️ 块内容【必须每行都以空格开头】：check_of 的 awk 用 /^[^ ]/ 结束块，
  #    未缩进的行会被当成"块已结束" ⇒ check 被截断（本仓已三次踩这类写法）。
  bad=$(python3 -c '
  import json, sys
  p = sys.argv[1]
  try:
      raw = open(p, "rb").read().decode("utf-8")
  except UnicodeDecodeError as e:
      print("非法 UTF-8（偏移 %d）" % e.start); raise SystemExit(0)
  n = 0
  for i, line in enumerate(raw.splitlines(), 1):
      if not line.strip():
          continue
      try:
          json.loads(line)
      except Exception as e:
          print("第 %d 行不是合法 JSON: %s" % (i, e)); n += 1
          if n >= 3:
              break
  ' "$F" 2>&1)
  [ -n "$bad" ] && echo "申诉账不可解析（独立留痕的承诺落空）: ${bad}"
last-hit: null
hit-count: 0
supersedes: null
---

# 申诉账每行必须是可解析的 JSON

## 为什么它值得一条闸门

`ledger/appeals-2026.jsonl` 的用途写在 `ledger/README.md`：**独立申诉账 —— 破解"运营者自己分类自己"的自证陷阱。**
**⇒ 它的全部价值在于"能被独立读到"。** 一行坏了，那条申诉就等于不存在。

**⇒ 与 `hits` 的 UTF-8 闸门同族**（同日实测：hits 真的出现过非法 UTF-8，根因是 `$var（` 陷阱）。
**⇒ 本闸门是那张网的第二个网眼。**

## 判据（两条，都是"读不出来就红"）

1. 整个文件必须是**合法 UTF-8**（否则任何读者都读不了）
2. 每个非空行必须是**合法 JSON**（jsonl 的契约）

## ★ 本条顺带暴露出两件事（都已处理）

**① 引擎的一个"静默失败"洞（已修）**
第一版 `check` 因写法问题**根本没运行**，而 `probe_one` 把 stderr 丢掉了 ⇒ **报"NOT RED"，
看起来像闸门活着** —— 这正是本仓禁止的"静默失败=伪证"。
**⇒ `tools/validate.sh` 已修：`check` 非零退出且无输出 ⇒ 【具名失败】**（并打印它自己的报错）。
**⇒ 这条修法比本闸门更值钱：它让"判据没跑起来"不再伪装成"判据通过了"。**

**② `check:` 块的写法约束（写成须知）**
`check_of` 用 `awk '/^check: \|/{f=1} f&&/^[^ ]/{f=0}'` ⇒ **块内容必须每行以空格开头**；
未缩进的行会被当成"块已结束"⇒ check 被截断（表现为引号不配对）。
**⇒ 细则：块内每一行都要缩进；不要在本块里嵌 heredoc。**

## 边界

**不检查内容与合法性判断**（那是人的事）—— 只保证"**它还在、还能被读到**"，
与 `VISION`/`README`/`DEPRECATE` 那几条同形：**判据只管"存不存在、读不读得到"，不管"内容好不好"。**
