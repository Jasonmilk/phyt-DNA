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
  # ★ locale 无关（2026-10-11 实测教训）：原实现用 sed/tr/grep 处理中文与 `·` ⇒ 在 `LC_ALL=C`（CI 常见）下
  #   抽取结果不同 ⇒ 比不相等 ⇒ **本地绿 / CI 红**。⇒ 改用 python 抽取与比对（UTF-8 文件、locale 无关）。
  python3 - "$F" <<'PY' || exit 0
import io, re, sys, os
f = sys.argv[1]; d = os.path.dirname(f)
def norm(t): return re.sub(r'[ \t]', '', t).rstrip('·')
dna = io.open(os.path.join(d, 'DNA.md'), encoding='utf-8').read().split('\n')
i0 = next((i for i,l in enumerate(dna) if l.startswith('## 元基因')), None)
i1 = next((i for i,l in enumerate(dna) if l.startswith('## 地盘')), None)
genes = '·'.join(m.group(1) for m in (re.match(r'^\*\*(.+)\*\*$', l) for l in dna[i0:i1]) if m) if i0 is not None and i1 else ''
gtxt = io.open(os.path.join(d, 'GROWTH.md'), encoding='utf-8').read().split('\n')
rec = [l for l in gtxt if '名目重抄' in l]
if not genes:
    print('判据自失效：从 DNA.md 抽不出名目（元基因/物种基因两段的粗体独占行）'); sys.exit(0)
if not rec:
    print('GROWTH.md 里找不到「名目重抄」行 —— 重抄是恒常的机制，不是可选项'); sys.exit(0)
latest = norm(rec[-1].split('：', 1)[-1].split(':', 1)[-1])
if norm(genes) != latest:
    print('重抄与 DNA 名目【不一致】—— 两抄之差即突变显红处（要么被那圈的故事解释=走 ADR，要么就是漂移）：')
    print('  DNA   : ' + norm(genes)); print('  最新重抄: ' + latest)
PY
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
