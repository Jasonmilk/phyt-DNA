# ADR-20261009：结晶出的教训必须被重放（G2 的第四圈）

---
id: ADR-20261009-lesson-must-be-replayed
seq: 9001
status: accepted
hard: true
applies-to: ["ledger/hits-2026.jsonl"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-lesson-must-be-replayed"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历：DNA.md:7-8 定义 G2 = 经历→记账→结晶→重放，并写明'有结晶无重放 = 空转 = 失败'；SPEC.md:27 把重放写作'重放（注入）'。而全仓 grep '重放|replay' 只出现在这两个文件里，tools/ 无任何重放机制，fixtures/ 里也没有一个夹具关于'教训有没有回到下一个任务'。"
risk: normal
replay-window: 10
check: |
  LED="${PHYT_LEDGER:-ledger}/hits-2026.jsonl"
  N=$(grep -h '^replay-window:' decisions/ADR-*.md | head -1 | awk '{print $2}')
  [ -z "$N" ] && N=10
  recent=$(grep -h '"kind"[[:space:]]*:[[:space:]]*"replay"' "$LED" | tail -n "$N")
  miss=""
  for f in decisions/ADR-*.md; do
    grep -q '^hard: true$' "$f" || continue
    grep -q '^status: deprecated' "$f" && continue
    id=$(basename "$f" .md)
    [ "$id" = "ADR-20261009-lesson-must-be-replayed" ] && continue
    printf '%s\n' "$recent" | grep -q "\"gate_id\"[[:space:]]*:[[:space:]]*\"$id\"" || miss="$miss $id"
  done
  [ -n "$miss" ] && echo "未被重放的结晶:${miss}（最近 $N 条 kind:replay 里都没有它们的 gate_id）"
last-hit: null
hit-count: 0
supersedes: null
---

# 结晶出的教训必须被重放（G2 的第四圈）

## 为什么（它自己早就写下了判据）

```
DNA.md:7   ## G2 · 循环转一圈才算活
DNA.md:8   **经历 → 记账 → 结晶 → 重放**。有经历无结晶、有结晶无重放 = 空转 = 失败。
SPEC.md:27 经历 → 记账(ledger) → 结晶(经济门槛+三要件) → 重放(注入) → 下一任务
```

**⇒ 前三圈都有机械**（`ledger/` · `decisions/`），**第四圈只有定义。**
**⇒ 按它自己的判据，循环停在第三圈。**

## 判据

**最近 `replay-window` 条 `kind: replay` 里，每条 `hard: true` 且未 `deprecated` 的结晶都必须出现**
（以 `gate_id` 计）**⇒ 缺任何一条即红，并具名是哪些。**

**窗口 N 来自 ADR 字段 `replay-window:`（非引擎硬编码）** —— 与 `cull-after:` 同一惯例。

## 关于"严度"的声明（避免这条闸门自己变成装饰）

- **记什么算重放**：`kind: replay` 且 `gate_id` = 该结晶的 id。
  **`note` 里应写明"注入到哪里"**，但**判据只看 id 的存在**（`note` 是给人读的）。
- **它不回答"注入有没有生效"** —— 那需要采用者在任务侧提供证据（例如某个判据变红/变绿）。
  **本闸门只回答"这条教训有没有回到任务里"，这是 G2 原话里的那一步。**
- **"本来就红"是允许的**：若本仓还没有任何 `kind: replay` 记录，本闸门**本来就红** ——
  **那是真实发现，不是夹具的功劳。**（`tools/validate.sh` 的反例段比较的是**结论是否改变**，
  故不会被它误报为假阳性。）
