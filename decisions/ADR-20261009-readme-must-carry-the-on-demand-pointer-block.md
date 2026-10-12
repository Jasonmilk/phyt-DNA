# ADR-20261009：README 必须带「按需指针」块（否则入口会退化成目录）

---
id: ADR-20261009-readme-must-carry-the-on-demand-pointer-block
seq: 9010
status: accepted
hard: true
applies-to: ["README.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-readme-must-carry-the-on-demand-pointer-block"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "2026-10-09：README 是唯一的入口，而入口的价值不在'内容全'，在'能指向唯一的那一份'（按需加载）。全生态六仓已对齐同一形状，故把它钉成闸门而不是只写进规范。"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  # ── 四判据（2026-10-12 折进门面门 · G）：指针块 · 可执行 · 路径真 · 版本同源 ──
  # 为什么折进【已存在】的门而不是新立：出生律"不许凭空长面"。这道门本来就是"README 的入口质量"，判据变多而已。
  skip(){ echo "具名跳过: $1（不判 —— 没有真值源就没有判据）" >&2; exit 4; }
  ROOT=$(git rev-parse --show-toplevel) || skip "非 git 工作区，版本真值源不可得"
  # ① 按需指针块（与工件真实形态一致：README.md 是英文，中文块在 README.zh-CN.md）
  grep -qE '^## Start here' "$F" || echo "README.md 缺【Start here】段（入口会退化成目录）"
  grep -qE '^\| *The question you are asking *\|' "$F" || echo "README.md 缺【question → read this】表头（读者无法按需取用）"
  grep -q 'docs/INDEX.md' "$F" || echo "README.md 未指向 docs/INDEX.md（按问题索引的唯一入口）"
  if LC_ALL=C grep -qE '^\| *我要回答的问题' "$F"; then echo "README.md 混入了中文块（应放在 README.zh-CN.md）"; fi
  # ② 可执行：bash 命令块里不许有 <…> 占位符（读者会照抄 ⇒ 跑不通）
  PL=$(grep -nE '`bash [^`]*<[^`]*`' "$F" | head -3)
  [ -n "$PL" ] && echo "bash 命令块含占位符 <…>（照抄跑不通）: $(printf '%s' "$PL" | tr '\n' ' ')"
  # ③ 路径真：声明过的仓内路径必须存在（跨仓的报告头具名豁免）
  while read -r p; do
    [ -n "$p" ] || continue
    case "$p" in tools/todo-ready.sh) continue ;; esac   # 具名豁免：生态仓的报告头（README 以文字指代）
    [ -e "$ROOT/$p" ] || echo "README 指向 ${p}，但该路径不存在（声明的路径必须是真路径）"
  #   ★ 只认【本仓】路径：形如 `helix-mind/docs/…` 的跨仓引用不得被当成本仓路径（实测假阳一次）。
  done < <(grep -oE '(^|[^A-Za-z0-9_./-])(tools/[A-Za-z0-9_.-]+\.(sh|py)|docs/[A-Za-z0-9_./-]+\.md|decisions/INDEX\.md)' "$F" \
           | sed -E 's/^[^A-Za-z0-9_./-]//' | sort -u)
  # ④ 版本真值源 = 分支（**不存版本号**：分支是物理事实，存下来的数过期时从不响）
  BR=$(git rev-parse --abbrev-ref HEAD)
  case "$BR" in v[0-9]*) ;; *) echo "（版本检查跳过：分支 ${BR} 非版本次第分支）" >&2; BR="" ;; esac
  if [ -n "$BR" ]; then
    ID=$(grep -m1 '^id: ' "$F" | sed 's/^id: *//')
    [ "$ID" = "DOC-README-${BR}" ] || echo "版本不一致：分支 ${BR} ⇒ id 应为 DOC-README-${BR}，实为 ${ID}"
    SUP=$(grep -m1 '^supersedes: ' "$F" | sed 's/^supersedes: *//')
    if [ -n "$SUP" ]; then
      grep -q "^status: deprecated" "$ROOT/docs/archive/${SUP}.md" || echo "supersedes: ${SUP} 无真源（docs/archive/${SUP}.md 缺失或缺 status: deprecated）⇒ 配对不可执行"
    fi
  fi
last-hit: null
hit-count: 0
supersedes: null
---

# README 必须带「按需指针」块

## 出处

2026-10-09 人类裁定：*"README.md 确实是一个重要的入口，且自带指针能力！只要做好按需指针，
工作就会很清晰，下次你不会忘记我们的成就和工作进度！"*
⇒ 全生态六仓 README 已**对齐同一形状**（表头统一为"我要回答的问题 | 读这份"）。

## 为什么

**入口的价值不在"内容全"，在"能指向唯一的那一份"** —— 复制会漂，指针不会（`HANDOFF.md` 的同一条理由）。
若 README 只是目录，读者会被一次打满注意力，且**没有任何东西保证"该指向的那一份"还在**。

## 红测

`fixtures/<id>/inject.sh` 把块标识删掉 ⇒ 心跳报 RED。
`fixtures/<id>/counter.sh` 做**内容保持**的改动（只改 mtime）⇒ 结论不得改变。
