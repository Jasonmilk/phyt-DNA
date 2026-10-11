---
id: ADR-20261011-recopy-must-equal-the-gene-set
seq: 9014
status: accepted
hard: true
applies-to: ["GROWTH.md"]
effective-from: 2026-10-11
timing: post
redtest: "validate --probe ADR-20261011-recopy-must-equal-the-gene-set"
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
origin: "DNA「恒常不靠冻结，靠重抄」+ VISION「GROWTH.md 每圈的末行重抄名目全集，两抄之差，即突变显红处」—— 检测器欠账（队列中最久一笔），本轮立"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  d=$(dirname "$F")
  norm(){ tr -d ' \t' | sed 's/·$//'; }
  genes=$(sed -n '/^## 元基因/,/^## 地盘/p' "$d/DNA.md" | grep -E '^\*\*.+\*\*$' | sed 's/^\*\*//;s/\*\*$//' | tr '\n' '·' | norm)
  # ★ 取【最新一条】重抄（`grep -m1` 会取到最早那条 —— 2026-10-11 由外挂审核发现实现与声明不符）
  recopy=$(grep '名目重抄' "$d/GROWTH.md" | tail -1 | sed 's/.*：//' | norm)
  [ -n "$genes" ] || { echo "判据自失效：从 DNA.md 抽不出名目（元基因/物种基因两段的粗体独占行）"; exit 0; }
  [ -n "$recopy" ] || { echo "GROWTH.md 里找不到「名目重抄」行 —— 重抄是恒常的机制，不是可选项"; exit 0; }
  if [ "$genes" != "$recopy" ]; then
    echo "重抄与 DNA 名目【不一致】—— 两抄之差即突变显红处（要么被那圈的故事解释=走 ADR，要么就是漂移）："
    echo "  DNA   : $genes"
    echo "  最新重抄: $recopy"
  fi
last-hit: null
hit-count: 0
supersedes: null
---

# 重抄必须等于名目全集（两抄之差即突变显红处）

## 判据

`GROWTH.md` 里**最新一条「名目重抄」行**必须与 `DNA.md` 的**名目全集**逐字一致（去空格、去尾分隔符后比对）。
· **不一致 ⇒ 红，并同时打印两侧**（"DNA: …" / "最新重抄: …"）⇒ **差在哪一目了然**。
· **判据自失效也具名**：若从 `DNA.md` 抽不出名目（两段粗体独占行的形状变了）⇒ **打印"判据自失效"而不静默**
  （缺席是信号；判据坏了要自己说，不能装绿）。

## 为什么（这是"恒常"的落地机制）

DNA 说：**名目恒常不靠冻结，靠重抄**；VISION 说：**每圈末行重抄名目全集，相邻两抄之差即突变显红处**。
⇒ 但**差值此前没人算** ⇒ 本 ADR 就是那个算的人：**最新重抄 vs DNA** 一比，**漂移无处藏**。
⇒ "突变"有两种合法解释：① 名目**真被改过**（走 ADR + 园丁批准 ⇒ 重抄自然跟着变）② 重抄**写漏/写错**（那是漂移 ⇒ 必须红）。
**本判据不区分二者——它只报差**；区分由那圈的 GROWTH 故事（走 ADR 的一圈必在年轮里留痕）完成。

## 边界

只管**最新一条**重抄（历史圈的旧重抄允许与今本不同 —— 它们记的是**当时**的名目）。
