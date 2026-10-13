# ADR-20261013：协议点名的文件必须存在（指名=承诺）

---
id: ADR-20261013-protocol-named-files-must-exist
seq: 9022
status: accepted
hard: true
applies-to: ["RNA.md", "DNA.md", "PLAN.md", "PLAN-PAUSED.md", "docs/MULTIMETER.md"]
effective-from: 2026-10-13
timing: post
redtest: "validate --probe ADR-20261013-protocol-named-files-must-exist"
revisit-on: 2027-04-13
expires-on: null
owner: "@jason"
origin: "2026-10-13：实测 `docs/MULTIMETER.md` 点名 `PLAN-PAUSED.md` 而它**从未存在**；游标类失效（点名却不落地）此前无人查。 ｜三要素：事件=task-2026-10-13-protocol-named-files（账本 kind:task 行） · 证据行=ledger/hits-2026.jsonl:1367 · 提交=4c8d384"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  # ── 具名豁免（★ 豁免必须具名 + 给理由；不许用通配符糊过去）：
  #   PLAN-PAUSED.md = **状态产物**（RNA 的 PAUSE 协议定义：只在该状态下存在），不是"该有而没有"。
  EXEMPT="PLAN-PAUSED.md"
  miss=""
  for tok in $(grep -oE '[A-Za-z0-9_][A-Za-z0-9_./-]*\.(md|sh|yml|jsonl|py)' "$F" | sort -u); do
    case " $EXEMPT " in *" $tok "*) continue ;; esac
    ok=0
    for cand in "$tok" "tools/$tok" "docs/$tok" "decisions/$tok" "ledger/$tok" ".$tok"; do
      [ -e "$cand" ] && { ok=1; break; }
    done
    if [ "$ok" = 0 ]; then
      for cand in fixtures/*/"$tok"; do [ -e "$cand" ] && { ok=1; break; }; done
    fi
    [ "$ok" = 0 ] && miss="$miss $tok"
  done
  [ -n "$miss" ] && echo "① 协议点名的文件不存在:${miss}（**指名=承诺**；"从未存在"比"被删除"更隐蔽）"
  # ② 自守：**门不许活在 INDEX 之外** —— 本门必须能被发现（自己检查自己是否被登记）
  id="ADR-20261013-protocol-named-files-must-exist"
  grep -rqs -- "$id" decisions/INDEX.md docs/INDEX.md || echo "② 自守失败: 本门未出现在 INDEX 里（'没装门'看起来会像'门通过了'）"
