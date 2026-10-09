# ADR-20261009：账本每行必须是合法 UTF-8

---
id: ADR-20261009-ledger-must-be-valid-utf8
seq: 9007
status: accepted
hard: true
applies-to: ["ledger/hits-2026.jsonl"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-ledger-must-be-valid-utf8"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-09）：账本第 4 行在偏移 256 处含 \\xbc\\x88 —— 一个三字节汉字丢了首字节。根因已钉死：旧判据里的 `$F（改基因…` 触发第 32 条（bash 把变量名吃掉 F + 全角括号首字节 ⇒ 变量展开为空 ⇒ 剩下的两字节漏进输出）⇒ 经 rec() 写进账本。**账本是我们所有结论的底账；它的一行坏了，读它的人就无法判断那一行说了什么。**"
risk: normal
check: |
  # 账本行必须能被解码（否则读者无法判断它说了什么 —— 证据链断在这里就没有别的地方可查）
  if ! iconv -f UTF-8 -t UTF-8 "$F" >/dev/null 2>&1; then
    bad=$(iconv -f UTF-8 -t UTF-8 "$F" 2>&1 >/dev/null | head -1)
    echo "账本含非法 UTF-8 ⇒ 读者无法解析该行: ${bad}"
  fi
last-hit: null
hit-count: 0
supersedes: null
---

# 账本每行必须是合法 UTF-8

## 为什么（人类 2026-10-09："行而后知"）

**账本是本方法的**底账**：`hits` / `override` / `probe` 全都落在这里。
**⇒ 它的一行坏了，读它的人**就无法判断那一行说了什么** —— 而账本正是"出问题时要去看的地方"。**

**根因（已钉死，见 `origin`）**：旧判据里的 `$F（…` 触发第 32 条，
bash 把 `F` + 全角括号**首字节**当成变量名 ⇒ 展开为空 ⇒ 剩下两字节漏进输出 ⇒ 经 `rec()` 落账。

**⇒ 与 `ADR-…-shell-var-before-cjk-must-brace` 的关系**：那条**本就该拦住它**，但它的 `applies-to` 是 `**/*.sh`，
而那条旧判据住在 `decisions/*.md` 的 `check:` 块里 —— **`check:` 块是 shell 代码，却在 `.md` 文件里** ⇒ 漏扫。
**⇒ 本 ADR 是那张网的第二层**（第一层补在 shell-var 那条的 scope 上，见其 `applies-to`）。
