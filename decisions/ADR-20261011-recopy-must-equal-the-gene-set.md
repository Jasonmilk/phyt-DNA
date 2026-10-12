---
id: ADR-20261011-recopy-must-equal-the-gene-set
seq: 9014
status: accepted
hard: false
applies-to: ["GROWTH.md"]
effective-from: 2026-10-11
timing: post
redtest: "validate --probe ADR-20261011-recopy-must-equal-the-gene-set"
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
origin: "DNA「恒常不靠冻结，靠重抄」+ VISION「GROWTH.md 每圈的末行重抄名目全集，两抄之差，即突变显红处」—— 检测器欠账（队列中最久一笔），本轮立"
origin-amend: "【第 1 轮更正 · 2026-10-12 · 三要素：事件=round-2026-10-11-census · 证据行=607（kind:replay · 行 event_id=census-61009-GROWTH-max-3-entries）· commit=6537339】本事 = GROWTH 数字**实测漂移 12→18（无人报红）**"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  # ★ 判据【与 locale 无关】（2026-10-11 三次实测）：sed/tr/grep 在 C / C.UTF-8 / 默认 三种 locale 下抽取中文与 `·`
  #   结果不同 ⇒ 同一份文件会时而红时而绿（固定 CI locale 只是把差异挪个地方）。⇒ 抽取与比对全交 python（按 UTF-8 读）。
  python3 - "$F" <<'PY'
import io, os, re, sys
f = sys.argv[1]; d = os.path.dirname(f)
# ★ 真源定位要稳健（2026-10-11 实测）：探针的夹具把 $F 复制到临时目录 ⇒ `dirname($F)` 里没有 DNA.md
#   ⇒ 判据会"自失效"（exit 0）⇒ **夹具越不过阈值 ⇒ 闸门看起来腐化**。⇒ 落回仓库根。
if not os.path.exists(os.path.join(d, 'DNA.md')):
    import subprocess
    try: d = subprocess.run(['git','rev-parse','--show-toplevel'],capture_output=True,text=True).stdout.strip() or d
    except Exception: pass
def norm(t): return re.sub(r'[ \t]', '', t).rstrip('·')
def rd(p): return io.open(p, encoding='utf-8', errors='surrogateescape').read().split('\n')
dna = rd(os.path.join(d, 'DNA.md'))
i0 = next((i for i, l in enumerate(dna) if l.startswith('## 元基因')), None)
i1 = next((i for i, l in enumerate(dna) if l.startswith('## 地盘')), None)
names = []
if i0 is not None and i1 is not None:
    for l in dna[i0:i1]:
        m = re.match(r'^\*\*(.+)\*\*$', l)
        if m: names.append(m.group(1))
if not names:
    print('判据自失效：从 DNA.md 抽不出名目（元基因/物种基因两段的粗体独占行）'); sys.exit(0)
g = [l for l in rd(os.path.join(d, 'GROWTH.md')) if '名目重抄' in l]
if not g:
    print('GROWTH.md 里找不到「名目重抄」行 —— 重抄是恒常的机制，不是可选项'); sys.exit(0)
latest = norm(re.split(r'[:：]', g[-1], 1)[-1] if ('：' in g[-1] or ':' in g[-1]) else g[-1])
want = norm('·'.join(names))
if want != latest:
    print('重抄与 DNA 名目【不一致】—— 两抄之差即突变显红处（要么被那圈的故事解释=走 ADR，要么就是漂移）：')
    print('  DNA   : ' + want); print('  最新重抄: ' + latest)
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

---

## 状态降级记录（2026-10-11 · Pi · 诚实收口）

**降为 `hard: false`（图纸），不是闸门。** 原因：**夹具始终无法把它推过阈值**（`probe: 注入后 NOT RED — 闸门已腐化`），
而本仓**出生律**写着"没有夹具的闸门不是 `alive`，是 `unproven`" ⇒ **它现在不满足作为闸门的最低条件**。
⇒ **判据与代码全部保留**（`tools/validate.sh --index` 仍会列它、`--probe` 仍可手跑）；
**缺的是夹具与 `$F`/真源定位之间那条正确的路径**（我连续四次尝试各自引入新问题：locale 敏感 · 回退过头 · 夹具写回编码坑）。
**修复判据（登记在案）**：让夹具能把最新一条重抄改错、且 probe 出 `注入后 RED + 反例守住` ⇒ 那一刻再转回 `hard: true`。
★ **代价如实记**：降级期间**自动检测停止**（重抄行为仍在做，但漂移不再被自动抓）。
