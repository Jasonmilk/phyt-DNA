# ADR-20261009：危险动作的**形状**必须在 pre 时刻被拦（不只是内容）

---
id: ADR-20261009-dangerous-action-shapes-must-be-blocked
seq: 9008
status: accepted
hard: true
applies-to: ["DNA.md", "VISION.md", "decisions/**"]
effective-from: 2026-10-09
timing: pre
redtest: "bash examples/claude-code/hooks/hook_test.sh"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-09，x 光 K22）：PreToolUse 执行闸自述'三层 fail-closed'，实测对【解析/依赖错误】确实如此，但对【真危险动作】是 fail-open —— `rm -rf` 形状的命令 ⇒ exit 0 · 写 DNA.md ⇒ exit 0。根因：本仓闸门【全是内容型】（PLAN 行数 / DNA 在基线里……），没有一条管【命令形状】；而 hook 把 Bash 的 command 当作 path 送进引擎，'rm -rf /tmp/x' 字符串【不匹配任何 applies-to glob】⇒ 闸门根本不运行。"
risk: high
check: |
  # ★ 只判【权威卷路径】。（第一版曾用 applies-to=["**"] 想连命令形状一起管 —— **那是错的**：
  #   引擎有一条既有且正确的规则"路径不存在 ⇒ fail-closed"，而 `**` 匹配一切 ⇒
  #   **写任何新文件都会被拦**（写文件的常态），且那三类"形状被拦住"其实是那条通用规则干的、
  #   不是本 check 干的 ⇒ 判据是假的、且把门变成了"全拦"。）
  #   ⇒ **命令形状由 hook 自己判**（见 examples/claude-code/hooks/pretooluse-gate.sh 的 L0.5）。
  case "$F" in
    *"rm -rf"*|*"rm -fr"*|*"rm -r -f"*|*"rm --recursive --force"*)
      echo "危险动作形状 · 递归强制删除: $F" ;;
    *"git push --force"*|*"git push -f "*) 
      echo "危险动作形状 · 强推（--force-with-lease 不在此列，它是安全的那一种）: $F" ;;
    DNA.md|./DNA.md|*/DNA.md|VISION.md|./VISION.md|*/VISION.md|decisions/*|./decisions/*|*/decisions/*)
      echo "权威卷路径（改它要过【授权门】—— 见 DNA.md 头注与 AITL 契约）: $F" ;;
  esac
last-hit: null
hit-count: 0
supersedes: null
---

# 危险动作的**形状**必须在 pre 时刻被拦

## 为什么（它是 K22 的修法）

**本仓的闸门全是【内容型】**：它们判断"写完之后文件长什么样"（PLAN 行数、DNA 是否在基线里……）。
**⇒ 于是"动作本身的形状"无人把守**：`rm -rf` 与"写 DNA.md"在 pre 时刻**一路放行**。

**⇒ 而 hook 把 Bash 的 `command` 当成 `path` 送进引擎 ⇒ 一个命令字符串**不匹配任何具体 glob**
⇒ 那条闸门**根本不运行**。**⇒ 所以修法在【匹配】：`applies-to: ["DNA.md", "VISION.md", "decisions/**"]`。**

## 判据（`timing: pre`）

| 形状 | 处置 |
|---|---|
| **权威卷路径**：`DNA.md` · `VISION.md` · `decisions/**` | **本闸门**拦（**改它要过授权门** —— 见 DNA 头注与 AITL 契约） |
| `rm -rf` 系 · `git push --force`（**词界，不含 `--force-with-lease`**） | **由 hook 的 L0.5 拦** —— **glob 模型是路径型，表达不了命令形状**（第一版试图用 `**` 兼管 ⇒ 变成全拦，见上文更正） |

**⇒ 只在这三类形状上输出；其余一律静默放行**（否则会拦住普通写入）。

## ★ 它的**回归判据不是 `--probe`**（这一点必须写明）

`--probe` 的模型是**把 `$F` 解析成一个真实文件路径**（`glob_first` 从 `git ls-files` 取）；
**而本闸门的对象是【任意输入字符串】（命令）** ⇒ **probe 表达不了它**（夹具会报"夹具无效"）。
**⇒ 故本条的回归判据是 `examples/claude-code/hooks/hook_test.sh`**（直接喂输入、断言退出码）。
**⇒ 这也说明：`--probe` 不是万能的"回归判据"格式；一条闸门的回归判据要按它的对象形态选。**
