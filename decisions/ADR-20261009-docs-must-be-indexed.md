# ADR-20261009：`docs/` 的每份知识文档都必须进 INDEX（否则它等于不存在）

---
id: ADR-20261009-docs-must-be-indexed
seq: 9006
status: accepted
hard: true
applies-to: ["docs/INDEX.md"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-docs-must-be-indexed"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-09）：人类指出'每一个脚印都在，只是 agent 如何优雅地按需获取而已'。查后确认：RNA.md §三 的四段漏斗只覆盖【闸门】(decisions/INDEX.md)，而 docs/ 那 4 份知识文档（MULTIMETER / PROTECTION / REPLAY-MISSING / DNA-GATE-DIAGNOSIS）不在加载协议里，README 只按【文件名】列它们 ⇒ 必须先知道名字才找得到，不是按需获取。"
risk: normal
check: |
  # 知识必须先被【按问题】索引，否则等于不存在（与 §二·五「先查再写」同源）。
  # 判据：docs/ 下每个 *.md 都必须在 docs/INDEX.md 里出现；缺一个即红并具名。
  miss=""
  for f in docs/*.md; do
    b=$(basename "$f")
    [ "$b" = "INDEX.md" ] && continue
    grep -q "$b" "$F" || miss="$miss $b"
  done
  skip(){ echo "具名跳过: $1（不判 —— 没有真值源就没有判据）" >&2; exit 4; }
  # ★ 0a 顺手治根因（2026-10-12）：本门 check **一直没有 ROOT 定义** ⇒ 根目录循环的 `[ -e "$ROOT/$d" ] || continue`
  #   静默跳过一切（判据"跑得到却什么都没判"）。**不报错的判据 ≠ 在工作。**
  ROOT=$(git rev-parse --show-toplevel) || skip "非 git 工作区，受管文档不可定位"
  [ -n "$miss" ] && echo "未被 INDEX 收录的知识文档:${miss} ⇒ 补进 docs/INDEX.md（按【问题】写一行）"  # ★ 0b（2026-10-12 园丁裁定 · 净 0 · 只扩作用域）：索引门原先只管 `docs/*.md` ⇒ **根目录受管文档无人读**
  #   （实测：`position.md` 落盘后没有任何入口指向它）。扩到根目录受管文档 ⇒ "存在但没人读"变成红。
  for d in README.zh-CN.md VISION.md DNA.md SPEC.md RNA.md PLAN.md GROWTH.md DEPRECATE.md position.md; do
    [ -e "$ROOT/$d" ] || continue
    grep -q "$d" "$ROOT/docs/INDEX.md" || echo "根目录受管文档 ${d} 未被 docs/INDEX.md 收录（存在但没人读 = 等于没有）"
    # ★ 0a（净 0）：**第二跳** —— 索引入了还不够，**前门 README.md 必须指向它**（有分类，还得有门牌）。
    grep -q "$d" "$ROOT/README.md" || echo "根目录受管文档 ${d} 在 docs/INDEX.md 里，但 README.md 没指向它（第二跳断）"
  done

last-hit: null
hit-count: 0
supersedes: null
---

# `docs/` 的每份知识文档都必须进 INDEX

## 为什么（人类 2026-10-09）

> *"phyt-DNA 可以让项目自生长，它的方向就是 VISION.md…所以不会迷路，因为每一个脚印都在，
> 只是 **agent 如何优雅地按需获取**而已。"*

**⇒ 本仓的加载协议（`RNA.md` §三 四段漏斗）已经覆盖了【闸门】，但**没覆盖【知识】**。**
**⇒ 后果**：一份写得很好的诊断（如 `DNA-GATE-DIAGNOSIS.md`）**没有任何入口** ——
**除非有人恰好 `ls docs/`**。**⇒ 那就是"脚印在，路没人指"。**

## 判据

**`docs/` 下每个 `*.md`（除本 INDEX 自己）都必须在 `docs/INDEX.md` 出现** ⇒ 缺即红**并具名**。

**⇒ 它守的不是"索引写得好看"，而是"**没有知识是隐形的**"** —— 与「先查再写」同源：
**先查要有地方可查**；查不到，等于没有。

## 边界（**不**做什么）

- **不检查行文质量**（那是作者的事）
- **不要求自动生成**：`docs/INDEX.md` 是【按问题】写的，机器生成不出"这回答什么问题" ⇒ 手写，但**由本条闸门保证不漏**
  （对比：`decisions/INDEX.md` 是**纯结构化**的，故由 `--index` 生成）
