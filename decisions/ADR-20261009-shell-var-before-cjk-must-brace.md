# ADR-20261009：`$var` 后紧跟非 ASCII 必须写 `${var}`

---
id: ADR-20261009-shell-var-before-cjk-must-brace
seq: 9002
status: accepted
hard: true
applies-to: ["**/*.sh", "decisions/ADR-*.md"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-shell-var-before-cjk-must-brace"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-09，同一会话内三次）：`echo \"… $L1（上限 280）\"` 与 `echo \"… $miss（最近 …）\"` 与 `echo \"… $out（no counter-fixture）\"` —— 全角括号被 bash 吞进变量名 ⇒ 输出乱码 / unbound variable。而 CI 的 fail-closed hook 里也有一条（`$rc）`）——**它自己的失败消息会失败**。"
risk: normal
check: |
  # 只看【非注释行】：注释里的 `$F（…）` 是说明文字，不是代码（否则假红 ⇒ 装饰品）。
  # LC_ALL=C 下 `[^ -~]` 匹配一切非可打印 ASCII 字节 ⇒ 不依赖 PCRE。
  # ★ scope 含 decisions/ADR-*.md：因为 `check:` 块【就是 shell 代码】，只是住在 .md 里。
  # 少了这一层，本闸门漏掉了唯一真正写坏过账本的那处（2026-10-09 事故，见 ADR-…-ledger-must-be-valid-utf8）。
  #
  # ★★ 但 .md 只扫 `check:` 块，**不扫正文** —— 实测教训（同一次 ci-local 抓到）：
  # 本条自己那份 ADR 的正文【必须】引用这个陷阱（`$L1（` / `$rc）`）才能说明它；
  # 扫整份 .md 会把"文档在展示一个东西"判成"文档在犯那个错"。
  # 与"夹具不得字面包含它要注入的违规"同课：**要禁的是可执行的形状，不是被引用的形状。**
  case "$F" in
    *.md) src=$(awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$F") ;;
    *)    src=$(cat "$F") ;;
  esac
  hits=$(printf '%s\n' "$src" | grep -vE '^[[:space:]]*#' | LC_ALL=C grep -nE '\$[A-Za-z_][A-Za-z0-9_]*[^ -~]')
  [ -n "$hits" ] && echo "变量名后紧跟非 ASCII（必须写 \${var}）: $hits"
last-hit: null
hit-count: 0
supersedes: null
---

# `$var` 后紧跟非 ASCII 必须写 `${var}`

## 真实经历（同一会话内三次）

```sh
echo "… $L1（上限 280）"     # ← bash 把 `（` 读成变量名的一部分 ⇒ $L1（ 未定义
echo "… $miss（最近 10 条…）" # ← 同上 ⇒ 输出乱码，而乱码把原因藏了起来
```

**⇒ 报错信息里的乱码恰好掩盖了病因**（看起来像编码问题，其实是 shell 解析）。

**⇒ 而它不只在临时命令里**：CI 的 fail-closed hook（`examples/claude-code/hooks/pretooluse-gate.sh`）里也有——

```sh
echo "⛔ fail-closed: 引擎异常（exit $rc）—— 不得静默放行"     # ← 修前
```

**⇒ 那条正是"引擎异常"时要说的话 ⇒ 它自己会失败。**（本 ADR 一并修掉。）

## 判据

**非注释行**里出现 `$var` 紧跟非可打印 ASCII（CJK / 全角标点）⇒ 红。

**⇒ 修法**：写成 `${var}`。

## 为什么它值得一条闸门（而不是一条提醒）

**同一会话内我踩了三次，三次都只是"我的命令"而不是产物 ⇒ 靠提醒显然不够**（第 32 / 34 条要求：不许只靠提醒）。
**⇒ 而它的检出成本是一条 grep，收益是"不再有那种乱码"** —— 工具服务硅基与碳基，能省弯路才算好工具。

## 执行方式（本仓既有惯例，不新增机制）

`applies-to: **/*.sh` ⇒ 引擎按首个匹配解析；**CI 第 4 步本来就逐文件扫** ⇒ 全仓 `.sh` 都被覆盖。
