# ADR-20261014：可移植性原则（判据只依赖 shell 内建 + git + python3 + 可移植 grep/sed）

---
id: ADR-20261014-portability-principle
seq: 9024
status: accepted
hard: false
applies-to: ["docs/MULTIMETER.md", "decisions/INDEX.md"]
effective-from: 2026-10-14
timing: post
redtest: "（文档型：判据体只查自洽，不造红）"
revisit-on: 2027-04-14
expires-on: null
owner: "@jason"
origin: "2026-10-14：两环境（macOS-BSD 本机 / GitHub Actions GNU-Linux）下判据必须同效；活死模式的子类都源于工具方言未受管。 ｜三要素：事件=task-2026-10-13-protocol-named-files · 证据行=ledger/hits-2026.jsonl:1367 · 提交=06998b3"
risk: normal
check: |
  # 文档型 ADR：正文以**缩进注释**写在判据体内（本仓既有形态）—— 这样"体提取"不会把顶格 markdown 算进来。
  # ── 原则 ──
  # 本仓判据只许依赖：shell 内建 + `git` + `python3` + **可移植**的 grep/sed 基本语法（如 [[:space:]] 类）。
  # ── 为什么（干净测量 · 2026-10-14 · 脚本文件法，避免内联 eval 的引号歧义） ──
  #   构造                      macOS BSD            GNU/Linux CI      判定
  #   grep -E 反斜杠s           **命中**（支持扩展）  命中              两环境都行 ⇒ 非当前故障（但非 POSIX）
  #   [[:space:]]               命中                 命中              ✅ 推荐写法
  #   grep -P（GNU 专属）       **rc=2 不支持**       支持              ❌ 禁用
  #   awk 反斜杠s               **0（真死！）**       命中              ❌ 禁用（且**静默**）
  #   sed 反斜杠竖线            **不生效**            支持              ❌ 禁用（改 sed -E）
  # ── 执行 ──
  # tools/spec-lint.sh 的 C' 门：非 POSIX 扩展未标注 ⇒ 具名红；**常驻自检**：TMP 注入样本必须被命中（否则门是死的）。
  # ── 与 RNA 的关系 ──
  # 本 ADR 独立成立，RNA.md **暂不引用**（常驻阅读层 320 行阈值：硬挤会把 PLAN+RNA 顶到 328 ⇒ 门当场红）。
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  grep -q 'POSIX' "$F" || echo "① 正文缺 POSIX 口径（原则须点名它不是 POSIX 的子集）"
