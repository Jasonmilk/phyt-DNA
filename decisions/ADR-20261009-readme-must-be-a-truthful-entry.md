# ADR-20261009：README 必须带「按需指针」块（否则入口会退化成目录）

---
id: ADR-20261009-readme-must-be-a-truthful-entry
seq: 9021
status: accepted
hard: true
applies-to: ["README.md", "README.zh-CN.md", "VISION.md", "DNA.md", "SPEC.md", "RNA.md", "PLAN.md", "GROWTH.md", "DEPRECATE.md", "position.md", "docs/*.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-readme-must-be-a-truthful-entry"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "2026-10-09：README 是唯一的入口，而入口的价值不在'内容全'，在'能指向唯一的那一份'（按需加载）。全生态六仓已对齐同一形状，故把它钉成闸门而不是只写进规范。 ｜三要素：事件=2026-10-12 人类裁定（中英语言分叉：两条具名红验收） · 证据行=ledger/hits-2026.jsonl:1203· event_id=task-2026-10-12-readme-four-criteria ⇒ 园丁裁定，外部需求） · 提交=3c1a1a5"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  # ── 四判据（2026-10-12 折进门面门 · G）· ★ 作用域分派（2026-10-12 裁定 1）：
  #   ① 按需指针块 与 ④ 版本同源 = **README 专属**（只有 README 带 DOC-README-* id / 指针块）；
  #   ② 可执行 与 ③ 路径真 = **通用**（权威卷 + docs/ 一律适用）。
  skip(){ echo "具名跳过: $1（不判 —— 没有真值源就没有判据）" >&2; exit 4; }
  ROOT=$(git rev-parse --show-toplevel) || skip "非 git 工作区，版本真值源不可得"
  case "$F" in
    *README.zh-CN.md)
      grep -qE '^## ▸ 从这里开始|^## 从这里开始' "$F" || echo "① README.zh-CN.md 缺【从这里开始】段（中文入口会退化成目录）"
      grep -qE '^\| *我要回答的问题 *\|' "$F" || echo "① README.zh-CN.md 缺【问题 → 读这个】表头"
      grep -q 'docs/INDEX.md' "$F" || echo "① README.zh-CN.md 未指向 docs/INDEX.md"
      ;;
    *README.md)
      grep -qE '^## Start here' "$F" || echo "① README.md 缺【Start here】段（入口会退化成目录）"
      grep -qE '^\| *The question you are asking *\|' "$F" || echo "① README.md 缺【question → read this】表头（读者无法按需取用）"
      grep -q 'docs/INDEX.md' "$F" || echo "① README.md 未指向 docs/INDEX.md（按问题索引的唯一入口）"
      if LC_ALL=C grep -qE '^\| *我要回答的问题' "$F"; then echo "① README.md 混入了中文块（应放在 README.zh-CN.md）"; fi
      ;;
  esac
  # ★ 2（2026-10-12 · 第二次踩）：**代码围栏必须配对** —— 半个围栏会把后面的排版整段吃掉（我实测吃掉过一个块边界）。
  NF=$(grep -c '^```' "$F")
  [ $((NF % 2)) = 0 ] || echo "② 代码围栏不配对：${NF} 个 \`\`\`（奇数）⇒ 后面排版会被吃掉"
  PL=$(grep -nE '`bash [^`]*<[^`]*`' "$F" | head -3)
  [ -n "$PL" ] && echo "② bash 命令块含占位符 <…>（照抄跑不通）: $(printf '%s' "$PL" | tr '\n' ' ')"
  PAT_A='(^|[^A-Za-z0-9_./-])(tools|docs|decisions|examples)/[A-Za-z0-9_./-]+([^A-Za-z0-9_./*-]|$)'      # ③a
  PAT_B='(^|[^A-Za-z0-9_./-])(README\.zh-CN|VISION|DNA|SPEC|RNA|PLAN|GROWTH|DEPRECATE|position)\.md([^A-Za-z0-9_./*-]|$)'   # ③b
  for p in $( { grep -oE "$PAT_A" "$F"; grep -oE "$PAT_B" "$F"; } | sed -E -e 's|^[^A-Za-z0-9_./-]||' -e 's|[^A-Za-z0-9_./-]$||' | grep -E '\.(md|sh|py|jsonl|json|sha256|txt|ya?ml)$' | sort -u); do
    [ -n "$p" ] || continue
    case "$p" in tools/todo-ready.sh) continue ;; esac
    [ -e "$ROOT/$p" ] && continue
    # ③ 的两类【正当缺席】（2026-10-12 实测：扩作用域后先抓到的正是这两类，不是断链）：
    #   a) 重定向目标：`cmd > $p` —— 读者【当场创建】的文件，不是"声明必须存在的路径"（复核配方常这么写）；
    #   b) 带删除/历史标记的行：年轮与归档**记录过去**（"已删/已移除/历史"）⇒ 那类路径缺席是事实，不是断链。
    #   豁免必须【具名进观测】（不具名的豁免 = 哑的断链），且路径一律按【固定串】比对（禁止把路径当正则）。
    hitline=$(grep -F -m1 -- "$p" "$F")
    case "$hitline" in
      *"> $p"*|*">$p"*) echo "③【豁免·重定向目标】${F}: ${p}（该行在创建它，不是声明它存在）" >&2; continue ;;
    esac
    if printf '%s' "$hitline" | grep -qE '已删|已移除|已废弃|deleted|removed'; then
      echo "③【豁免·已删除记录】${F}: ${p}（条目行自带删除标记：记录过去，不是断链）" >&2; continue
    fi
    echo "③ ${F} 指向 ${p}：本仓不存在它 ⇒ 要么断链，要么【跨仓引用形状错】—— 跨仓必须写成 <repo>/… 形状"
  done
  case "$F" in *README.md)
    TAG=$(git tag --list 'v[0-9]*' --sort=-creatordate | head -1)
    if [ -n "$TAG" ]; then git merge-base --is-ancestor "$TAG" HEAD || echo "④ 真值源 tag ${TAG} 不是 HEAD 的祖先（陈旧）⇒ 版本判据失真"; fi
    BR="$TAG"
    if [ -z "$BR" ]; then BR=$(git symbolic-ref -q --short refs/remotes/origin/HEAD | sed 's|^origin/||'); fi
    [ -n "$BR" ] || skip "版本次第 tag 与远端默认分支 symref 都取不到 ⇒ 版本真值源不可得"
    case "$BR" in v[0-9]*) ;; *) skip "真值源 ${BR} 非版本次第（vN）形态 ⇒ 不判" ;; esac
    ID=$(grep -m1 '^id: ' "$F" | sed 's/^id: *//')
    [ "$ID" = "DOC-README-${BR}" ] || echo "④ 版本不一致：真值源 ${BR} ⇒ id 应为 DOC-README-${BR}，实为 ${ID}"
    SUP=$(grep -m1 '^supersedes: ' "$F" | sed 's/^supersedes: *//')
    if [ -n "$SUP" ]; then
      grep -q "^status: deprecated" "$ROOT/docs/archive/${SUP}.md" || echo "④ supersedes: ${SUP} 无真源（docs/archive/${SUP}.md 缺失或缺 status: deprecated）⇒ 配对不可执行"
    fi
  ;; esac

last-hit: null
hit-count: 0
supersedes: ADR-20261009-readme-must-carry-the-on-demand-pointer-block
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

---

## 本门的实际职责（名字 ⊇ 四判据 · 2026-10-12 园丁裁定）

**`id` 是终身身份（改名不重编号）**：`…-readme-must-carry-the-on-demand-pointer-block` 是 **v1 时代的名字**，
而这道门今天判的是**四件事** —— 读这道门请以本节为准：

| # | 判据 | 来历 |
|---|---|---|
| ① | **按需指针块**：`## Start here` · `question → read this` 表 · 指向 `docs/INDEX.md` · 不混中文块 | 原职责（v1 遗产） |
| ② | **可执行**：命令块里不得有 `<…>` 占位符（读者会照抄） | 实测 3 处真红灯（`README:60/65/88`） |
| ③ | **路径真**：README 声明的**本仓**路径（`tools/` `docs/` `decisions/` `examples/` + 根目录受管文档）必须存在；跨仓引用（`helix-mind/docs/…`）不误判 | 实测抓到真断链 `tools/baseline.sh` |
| ④ | **版本同源**：`id` = 真值源推出的 `DOC-README-${BR}`（真值源 = **远端默认分支 symref / 版本次第 tag**，不是可移动的 `HEAD`）；`supersedes` 必须在 `docs/archive/` 有 `status: deprecated` 真源 | 实测三处不同步（分支 v2 / id v3 / supersedes v2） |

**⇒ 名字是历史的，职责是活的。** 新增判据一律折进本门（出生律：不许凭空长面）。
