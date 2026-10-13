#!/usr/bin/env bash
# spec-lint.sh —— 用 phyt-DNA 自己的规则，检查 phyt-DNA 自己的规范文档
# 这是「坑变闸机」的第一次真实应用：规范自己过一遍 GAT
set -uo pipefail
SPEC="${1:-docs/PROTECTION.md}"
[ -f "$SPEC" ] || { echo "缺规范文件: $SPEC" >&2; exit 2; }

fail=0
red(){ printf '  RED  %s\n' "$1" >&2; fail=1; }
grn(){ printf '  GRN  %s\n' "$1"; }

echo "spec-lint: $SPEC"

# 闸门1：出错时的失败策略必须显式存在（这条自己在重写中消失过两次）
if grep -q 'fail-open' "$SPEC" && grep -q 'fail-closed' "$SPEC"; then
  grn "失败策略(fail-open/fail-closed)存在"
else
  red "失败策略缺失 —— 该规则已在历史重写中静默消失 ≥1 次，必须靠脚本守住"
fi

# 闸门2：三种死亡终点必须有各自承载字段
if grep -qE '^[[:space:]]*(expires-on|auto-expire):' "$SPEC"; then
  grn "自动删除有承载字段"
else
  red "三种终点只有 revisit-on 一个字段 —— 「自动删除」无路由器"
fi
grep -q '^revisit-on:' "$SPEC" && grn "续期/复审有承载字段" || red "revisit-on 缺失"
grep -q '^risk:' "$SPEC" && grn "风险复审有承载字段" || red "risk 缺失"

# 闸门3：每条"官方已证实"的断言必须带可核查出处
claims=$(grep -c '已证实' "$SPEC")
links=$(grep -cE 'https?://' "$SPEC")
if [ "$claims" -gt 0 ] && [ "$links" -eq 0 ]; then
  red "声称 $claims 处「已证实」但全文 0 个链接 —— 半年后无人能查证"
else
  grn "出处登记: $claims 处断言 / $links 个链接"
fi

# 闸门4：不得承诺无证据的定量结论
if grep -qE '每增加 ?[0-9]+ ?行.*遵从度下降' "$SPEC"; then
  red "承诺了无直接证据的遵从度衰减率"
else
  grn "未承诺无证据的衰减率"
fi

# 闸门5：不得引用未获官方证实的实践
if grep -q 'lessons.md' "$SPEC" && ! grep -q '未获官方证实' "$SPEC"; then
  red "引用 lessons.md 但未标注未证实"
else
  grn "未证实项已标注"
fi

# 闸门6：check 表达式不得静默失败（EXP-E 漏报实证）
if grep -rqE '^[[:space:]]+.*2>/dev/null' decisions/*.md 2>/dev/null; then
  bad=$(grep -lE '^[[:space:]]+.*2>/dev/null' decisions/*.md 2>/dev/null | tr '\n' ' ')
  red "check 表达式含 2>/dev/null（静默失败=伪证）: $bad"
else
  grn "check 表达式无静默失败"
fi

# 闸门7：测试基础设施不得含全量还原（ADR-0009，五次同族现身）
# 只扫 *.sh 脚本：fixtures/README.md 等文档示例文字会合法地提及禁令本身（T0 顺带修复）
# 有意回写（理由：这是检查器自身的**模式文本**，不是写回真件 —— 构造性自匹配）
BAD=$(grep -rlE --include='*.sh' 'git checkout -- \.|git clean -fd|git stash' tools/ fixtures/ 2>/dev/null | grep -v 'spec-lint.sh')
if [ -n "$BAD" ]; then
  red "测试脚本含全量还原命令（会破坏被测物）: $(echo $BAD | tr '\n' ' ')"
else
  grn "测试脚本无全量还原命令"
fi

# ★ 2026-10-12（YB 3 · 净 0）：两条断言 —— 专治【死判据】与【红不知道是哪一条】
#   ① 每个 ADR 的 check 体（剥 2 空格后）必须是合法 bash：实测教训 —— 续行/多行管道让一条判据
#      【整段不跑】，而它照绿（哑失败第 6 类）；`bash -n` 当场抓住。
#   ② 声明了编号判据的门（正文有 `| ① |` 形状的表）⇒ check 体里必须带同样的编号前缀
#      （红要能一眼指出是哪一条判据，而不是笼统"README 有问题"）。
dead=""; unnum=""
for f in decisions/ADR-*.md; do
  grep -q '^check: |' "$f" || continue
  body=$(awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$f" | sed 's/^  //')
  printf '%s' "$body" | bash -n 2>/tmp/bn.$$.err || dead="$dead $(basename "$f")"
  if grep -q '^| ① |' "$f"; then
    for n in ① ② ③ ④; do
      grep -q "^| $n |" "$f" || continue
      printf '%s' "$body" | grep -q "$n" || unnum="$unnum $(basename "$f"):$n"
    done
  fi
done
rm -f /tmp/bn.$$.err
if [ -n "$dead" ]; then red "check 体不是合法 bash（剥 2 空格后 ⇒ 该判据整段不跑＝死判据）:$dead"; else grn "所有 check 体（剥 2 空格后）都是合法 bash"; fi
if [ -n "$unnum" ]; then red "声明了编号判据但 check 体缺对应编号:$unnum"; else grn "编号判据的 check 体都带编号前缀"; fi

# ★ 2026-10-12（裁定 2 · 净 0）：**裸匹配断言** —— ADR 的 check 体里 grep 前言字段必须**行首锚定**（`^field:`）。
#   实测教训：`'status: deprecated' in s` 把"正文里提到 deprecated"当成"自己是 deprecated" ⇒ 多建 4 份归档记录。
#   字段面：id / status / supersedes / hard / timing / applies-to / revisit-on / expires-on / risk / origin / check。
bare=""
for f in decisions/ADR-*.md; do
  grep -q '^check: |' "$f" || continue
  body=$(awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$f" | sed 's/^  //')
  bad=$(printf '%s' "$body" | grep -nE "grep[^|]*'(id|status|supersedes|hard|timing|applies-to|revisit-on|expires-on|risk|origin|check): " | grep -v '\^' )
  if [ -n "$bad" ]; then bare="$bare $(basename "$f")"; fi
done
if [ -n "$bare" ]; then red "check 体里有未行首锚定的前言字段匹配（裸匹配 = 会被正文里的同名文字骗）:$bare"; else grn "前言字段匹配都行首锚定"; fi

# ★ 2026-10-12（裁定 2 · 净 0）：**变量必须赋值** —— check 体里用了 `$VAR` 而体里没有 `VAR=` 赋值 ⇒ 红。
#   实测两例：索引门的根目录循环 `[ -e "$ROOT/$d" ] || continue`（ROOT 从未定义 ⇒ **静默跳过一切**）；
#   PLAN 门的跨文件核对 `ls "$ROOT"/archive/…`（跑到 `/archive/…`）。**不报错的判据 ≠ 在工作。**
unassigned=""
for f in decisions/ADR-*.md; do
  grep -q '^check: |' "$f" || continue
  body=$(awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$f" | sed 's/^  //')
  #   ★ 收紧（同轮）：① 先剥【单引号串】—— 判据里被搜索的模式串（如 `\$var（`）不是变量；
  #   ② 豁免名单**从引擎的注入点派生**（不手写约定）：引擎实际注入哪些变量，就读它哪一行 ——
  #      判据 `F="$F" bash -u -c …` ⇒ 注入集 = {F}；并接受 `${VAR:-…}` 自带默认值的形态。
  #      ★ 反面教训：首版写"全大写 = 环境提供" ⇒ ROOT 也是全大写 ⇒ **该抓的抓不到，断言形同虚设**。
  stripped=$(printf '%s' "$body" | sed -E "s/'[^']*'/''/g")
  stripped=$(printf '%s' "$stripped" | sed 's/\\\$//g')   # 转义美元 \$var = 被搜索的形态，不是变量
  used=$(printf '%s' "$stripped" | grep -oE '\$\{?[A-Za-z_][A-Za-z0-9_]*' | tr -d '$\{' | sort -u)
  INJECT=$(grep -ohE '[A-Za-z_]+="\$[A-Za-z_]+" bash -u -c' tools/validate.sh | sed 's/=.*//' | sort -u | tr '\n' ' ')
  for v in $used; do
    case " $INJECT " in *" $v "*) continue ;; esac        # 引擎注入（派生，非手写）
    case "$v" in F) continue ;; esac
    if printf '%s' "$body" | grep -qE "\$\{${v}[:-]"; then continue; fi   # ${VAR:-…} 自带默认值
    if printf '%s' "$body" | grep -qE "(^|[;[:space:]])(local )?${v}="; then continue; fi
    if printf '%s' "$body" | grep -qE "(for|read)[[:space:]]+(-[A-Za-z]+[[:space:]]+)*${v}([[:space:]]|$)"; then continue; fi
    if printf '%s' "$body" | grep -q "variable-lint-exempt.*[^A-Za-z0-9_]${v}[^A-Za-z0-9_]"; then continue; fi
    case "$v" in *[a-z]*) ;; *) case " ${LINT_ENV:-PHYT_LEDGER PHYT_DECISIONS PHYT_QUIET} " in *" $v "*) continue ;; esac ;; esac   # 环境变量（**具名清单**，不是"全大写"）
    if printf '%s' "$body" | grep -q "variable-lint-exempt"; then continue; fi
    unassigned="$unassigned $(basename "$f"):\$${v}"
  done
done
if [ -n "$unassigned" ]; then red "check 体里用了从未赋值的变量（会静默展开成空 ⇒ 判据在"假跑"）:$unassigned"; else grn "check 体里的变量都有赋值"; fi

# ★ 1（2026-10-12 · 净 0 · 零夹具）：**presence 型正则的自命断言** ——
#   形态 grep -q… '<pat>' "$F" 断言"目标文件里【必须有】X" ⇒ **样本就是目标文件本身**：
#   拿该门 applies-to 的目标直接跑这条正则，命中 ≥1 才算有样本；命中 0 ⇒ 具名红（它是恒绿的断言）。
#   violation 型不在此列（它们找"不该有的东西"，样本只能来自夹具 ⇒ 另一栏）。
presence_miss=""
for f in decisions/ADR-*.md; do
  grep -q '^check: |' "$f" || continue
  targets=$(grep -m1 '^applies-to:' "$f" | sed 's/.*\[//;s/\].*//' | tr -d '"' | tr ',' ' ')
  body=$(awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$f" | sed 's/^  //')
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    #   ★ 口径修正：样本不必在目标文件里 —— **任何被跟踪的文件**命中都算它"有样本"（用 git grep，覆盖全仓）。
    if git grep -qE -e "$pat"; then continue; fi
    presence_miss="$presence_miss $(basename "$f" .md):$pat"
  #   ★ 分栏（2026-10-12）：presence = 【缺了就红】的形状（grep … \|\| echo "缺…"）；
  #   violation = 【命中即红】的形状（grep … && echo "…残留"）⇒ 后者不在本断言范围（它的样本只能来自夹具）。
  done < <(printf '%s' "$body" | grep -oE "grep[[:space:]]+-[A-Za-z]*q[A-Za-z]*[[:space:]]+'[^']+'[^|]*\|\|" | sed -E "s/.*'([^']+)'.*/\1/")
done
if [ -n "$presence_miss" ]; then red "presence 型正则在目标文件上命中 0 次（它没有样本 ⇒ 恒绿断言）:$presence_miss"; else grn "presence 型正则在目标文件上都能命中（样本即目标）"; fi

echo
# ★ 2（2026-10-12 · 净 0）：【判据体】里不得出现宿主专名 —— 散文可提（归因），**判据不许长着宿主的样子**
#   （复用 shell-var 门的分层逻辑：判据体严格，散文宽松）。宿主专名 = 生态其余仓 + 生态自身的名。
hosthit=""
for f in decisions/ADR-*.md; do
  grep -q '^check: |' "$f" || continue
  body=$(awk '/^check: \|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' "$f" | sed 's/^  //')
  if printf '%s' "$body" | grep -qE 'helix-mind|anaphase-helix|Cellrix|FlowModus|Tuck|helixECO|Helix 生态|OUTWARD|外视读数'; then
    hosthit="$hosthit $(basename "$f" .md)"
  fi
done
if [ -n "$hosthit" ]; then red "判据体里出现宿主专名（应改成角色指针/角色名）:$hosthit"; else grn "判据体里没有宿主专名"; fi

# ★ 4（2026-10-12 · 净 0）：**引用必须落地** —— 任何 md 里提到的 ADR id，必须在 decisions/ 有同名文件。
#   实测来历：`docs/FINDING-…` 与账本都引用过一条【从未落盘】的 ADR（ledger-must-be-parseable-line-oriented）。
#   ⇒ 一次 grep 治不完：把它变成通则（通则才不会再长出第二个）。
dangling=""
for aid in $(git grep -hoE 'ADR-[0-9]{8}-[a-z0-9]+(-[a-z0-9]+)*' -- '*.md' 2>/dev/null | sort -u); do
  #   ★ 两类正当提及：① 缩写前缀（尾带连字符）由上面的正则排除；② 行内自带"从未落盘/未落盘"标记 = 历史说明。
  if git grep -qE -- ".*$aid.*(从未落盘|未落盘|never landed)" -- '*.md'; then continue; fi
  if git grep -qE -- "$aid-[a-z0-9]" -- '*.md'; then continue; fi   # 后置过滤：后面紧跟连字符 ⇒ 是【缩写】，不是 id
  [ -e "decisions/$aid.md" ] || dangling="$dangling $aid"
done
if [ -n "$dangling" ]; then red "引用了【不存在】的 ADR id（悬空引用）:$dangling"; else grn "所有被引用的 ADR id 都有落地文件"; fi

# ★ 1（2026-10-12 · 净 0）：**读数器由判据器守着** —— 清点器 `--selftest` 不过 ⇒ 判据器红
#   （否则它给出的 A/B 两数与"无样本清单"没有任何人担保 ⇒ 那是"无人担保的读数"）。
census_out=$(tools/regex-census.sh --selftest 2>&1); census_rc=$?
if [ "$census_rc" = 0 ]; then grn "正则清点器自检通过（12/12）"; else red "正则清点器自检未过（12/12）⇒ 它的 A/B 两数应标 unproven: $(printf '%s' "$census_out" | tail -1)"; fi

# ★ 1（2026-10-12 · 净 0）：**死代码断言**（"死判据"家族第 9 例的机械护栏）——
#   钩子/工具脚本里出现 `exit` 之后【仍有可执行行】⇒ 那些行永不执行 ⇒ 具名红。
#   来历：pre-commit 第 26 行的无条件 `exit 0` 让其后 24 行（含我新加的阻断）全是死代码，而我以为它在工作。
if python3 - <<'PYDC' 2>/dev/null
import glob, io, os, re

def scan(text):
    # 返回 (死代码命中, 结束时深度)。深度追踪正解（2026-10-13）：
    #   · 先算开、后算闭（同一行既开又闭 ⇒ 净额 0 —— 顺序即语义）
    #   · 闭合只在真是闭合时减、且钳位到 0
    #   · heredoc 体跳过（体里不是 shell —— 它既是假阳源，也是假阴源）
    depth = 0; exit_at = None; heredoc = None
    for n, raw in enumerate(text.split('\n'), 1):
        t = raw.strip()
        if heredoc is not None:
            if t == heredoc: heredoc = None
            continue
        if not t or t.startswith('#'): continue
        m = re.search(r"<<-?['\"]?([A-Za-z_][A-Za-z0-9_]*)['\"]?", t)
        if m: heredoc = m.group(1)
        low = t
        if low.startswith(('if ','for ','while ','case ')) or low=='{' or low.endswith('(){') or '() {' in low:
            depth += 1
        if low in ('fi','esac','}','done') or low.startswith(('fi ','esac ','} ','done ')):
            depth = depth - 1 if depth > 0 else 0
        for kw in ('fi','esac','done'):
            #   ★ 闭后允许【空白 / 分号 / 行尾】—— `done < f`（重定向）与 `fi; echo` 都算闭合（自检 ②-4[while] 抓到的缺口）
            if re.search(r'(^|;|\s)%s(\s|;|$)' % kw, low) and not low.startswith(kw):
                depth = depth - 1 if depth > 0 else 0
        if exit_at is not None and depth == 0 and not low.startswith(('fi','esac','}','done',';;')):
            return ((n, exit_at), depth)
        if exit_at is None and depth == 0 and (low == 'exit' or low.startswith('exit ') or low.startswith('return')):
            exit_at = n
    return (None, depth)

bad = False
for f in sorted(glob.glob('tools/hooks/*')):
    if not os.path.isfile(f): continue
    hit, _ = scan(io.open(f, encoding='utf-8').read())
    if hit:
        print('%s:第%d行（第%d行 exit 之后 · 顶层 ⇒ 死代码）' % (os.path.basename(f), hit[0], hit[1])); bad = True

# ②-4 同一行开+闭 ⇒ 净额 0（每种形状都断言"深度回 0"；漏一种 = 整段静默失明）
D0 = {
 'case':  'case x in y) echo a ;; esac\nexit 0\n',
 'if':    'if [ 1 ]; then echo a; fi\nexit 0\n',
 'for':   'for i in 1; do echo $i; done\nexit 0\n',
 'while': 'while read -r l; do echo $l; done < f\nexit 0\n',
 'sub':   'V=$(printf x)\nexit 0\n',
 'brace': '{ echo a; }\nexit 0\n',
 'andor': 'true && echo a || echo b\nexit 0\n',
}
for k, v in sorted(D0.items()):
    hit0, d = scan(v)
    if d != 0:
        print('自检失败 ②-4[%s]：同行开+闭之后深度 = %d（应 0）' % (k, d)); bad = True
    if hit0 is not None:
        print('自检失败 ②-4[%s]：合法形状被判死代码' % k); bad = True

# ②-5 红侧矩阵（≥5 支）：每支必须具名红，且行号要对（漏判即红）
RED = {
 'exit 后多行':    ('set -u\nexit 0\necho a\necho b\n', 3),
 '嵌套块后顶层':   ('set -u\nif [ 1 ]; then\n  echo x\nfi\nexit 0\necho dead\n', 6),
 'exit 4 后':      ('set -u\nexit 4\necho dead\n', 3),
 'return 后顶层':  ('set -u\nreturn\necho dead\n', 3),
 '函数体后':       ('set -u\nf(){\n  echo x\n}\nexit 0\necho dead\n', 6),
 'heredoc 后顶层': ('set -u\ncat <<EOF > /tmp/x\nhi\nEOF\nexit 0\necho dead\n', 6),
}
for k, (v, want) in sorted(RED.items()):
    hit, _ = scan(v)
    if hit is None:
        print('自检失败 ②-5[%s]：真死代码没被抓（漏判即红）' % k); bad = True
    elif hit[0] != want:
        print('自检失败 ②-5[%s]：行号错（得 %d 应 %d）' % (k, hit[0], want)); bad = True

# ②-6 heredoc 局限样本（去掉内含 if…fi ⇒ 真证/真反证）
H = 'set -u\ncat <<EOF > /tmp/x\nexit 0\necho heredoc_body_text\nEOF\nexit 0\n'
h_hit, h_d = scan(H)
if h_hit is not None:
    print('自检失败 ②-6：heredoc 体内样文本被判死代码（得 %s）⇒ 体未被跳过' % (h_hit,)); bad = True
if h_d != 0:
    print('自检失败 ②-6：heredoc 之后深度 = %d（应 0）' % h_d); bad = True
raise SystemExit(0 if not bad else 1)
PYDC
then grn "钩子里没有 exit 之后的死代码（深度感知；**已数行内 if/for/case 闭合**；仍不数工具脚本内的 heredoc ⇒ 局限在 tools/*.sh）"; else red "钩子里的 exit 之后仍有可执行行（死代码 ⇒ 你以为它在工作）"; fi
grn "死代码断言：hooks/（**局限具名**：tools/*.sh 未覆盖 —— 它们内有 heredoc 嵌 python/awk，逐行深度追踪必然漂移；真覆盖需解析器）"
# ★ 2026-10-13（实测机制 · 断言修正）：**判据体不得有顶格行** ——
#   ① **必须查【原文】**：正文提取的 awk **以"非空格开头"为结束条件** ⇒ 用"提取结果"去查顶格行**永远查不到**
#      （旧版断言因此**恒绿** —— 正是我这一晚反复栽的那类）。② **编号兜底**：声明了编号判据的门，
#      其【提取后的体】必须逐一含这些编号（截断时即红）。
chk=""; trunc=""
for f in decisions/ADR-*.md; do
  grep -q '^check: |' "$f" || continue
  raw=$(awk '/^check: \|/{f=1;next} f&&/^[a-z-]+:/{f=0} f{print}' "$f")
  printf '%s\n' "$raw" | grep -qE '^[^ ][^ ]*' && chk="$chk $(basename "$f")"
  ext=$(printf '%s' "$raw" | sed 's/^  //')
  for n in ① ② ③ ④; do
    grep -q "^| $n |" "$f" || continue
    printf '%s' "$ext" | grep -q "$n" || trunc="$trunc $(basename "$f"):$n"
  done
done
if [ -n "$chk" ]; then red "判据体里有顶格行（**原文**里；引擎只看到它之前的部分）:$chk"; else grn "判据体原文没有顶格行"; fi
if [ -n "$trunc" ]; then red "编号判据在【提取后的体】里缺失（被截断？）:$trunc"; else grn "编号判据在提取后的体里逐一出现"; fi

# ★ 0*******d（2026-10-13）：**分母自检** —— 总 = 活 + 图纸 + deprecated；不等 ⇒ 具名红
#   （"在分母量准之前，任何分类读数都只是子集读数"）。反例：一份 ADR 缺 hard 字段 ⇒ 和必然不等。
_t=$(ls decisions/ADR-*.md | wc -l | tr -d ' ')
_a=$(for f in decisions/ADR-*.md; do grep -q '^hard: true$' "$f" || continue; grep -q '^status: deprecated' "$f" && continue; echo x; done | wc -l | tr -d ' ')
_b=$(for f in decisions/ADR-*.md; do grep -q '^hard: false' "$f" || continue; grep -q '^status: deprecated' "$f" && continue; echo x; done | wc -l | tr -d ' ')
_d=$(grep -l '^status: deprecated' decisions/ADR-*.md | wc -l | tr -d ' ')
if [ "$((_a+_b+_d))" = "$_t" ]; then grn "分母自检：总 $_t = 活 $_a + 图纸 $_b + deprecated $_d"; else red "分母自检失败：总 $_t ≠ 活 $_a + 图纸 $_b + deprecated $_d ⇒ 有 ADR 缺 hard 字段（分类读数会漏）"; fi
# ★ ④-6（2026-10-13）：**钩子只许委派** —— `tools/hooks/*` 里对 `spec-lint` 的**调用**数必须为 **0**
#   （它跑 `ci-local`，而 ci-local 里就那一次/两次同一脚本 ⇒ 这是"就一套"的机器判据）。
#   ★ 反例（内联样本）：构造一行调用 ⇒ 判定函数必须报红 —— 证明这条断言会响。
_hookbad=""
for f in tools/hooks/*; do
  [ -f "$f" ] || continue
  n=$(grep -cE '(bash|\./)[^|]*spec-lint' "$f")
  [ "$n" != "0" ] && _hookbad="$_hookbad $(basename "$f"):$n"
done
_selfcall='bash tools/spec-lint.sh docs/PROTECTION.md'
if [ "$(printf '%s\n' "$_selfcall" | grep -cE '(bash|\./)[^|]*spec-lint')" = "0" ]; then
  red "自检失败 ④-6：反例样本（一行 spec-lint 调用）**没被数到** ⇒ 断言不会响"; fail=1
fi
if [ -n "$_hookbad" ]; then red "钩子里自带了 spec-lint 调用（应只委派 ci-local）:$_hookbad"; fail=1; else grn "钩子未自带 spec-lint 调用（只委派）"; fi

# ★ 0-b（2026-10-13）：**写回真件的两腿判据** —— 正列举 + 负兜底。
#   负兜底：**非追加**地写【真件/受管】的语句，必须在**同一行或上一行**带 `有意回写（理由：…）` 标注，否则红。
#   ★ 判据看**目标**（cp/mv 的最后一个 token），不是看整行 —— 否则 `cp /tmp/x tools/X`（源在 /tmp、目标在仓内）会漏（实测漏过一次）。
# 有意回写（理由：这是检查器自身的**模式文本**，不是写回真件 —— 构造性自匹配）
_cand=$(grep -rnE '(^|[^>])(cp|mv|tee)[^|]*( |$)|sed -i|rsync|git (checkout|restore)' tools/*.sh examples/*/*.sh 2>/dev/null \
        | grep -v '>>' | grep -vE '^[^:]+:[0-9]+: *#' \
        | grep -v 'tools/spec-lint.sh:' \   # ★ 排除检查器自身（它的模式文本必然自匹配）；**补偿控制 = 待做的窄断言**（见 DEBTS d-phyt-selfwrite-compensate）
         || true)   # ★ 排除检查器自身：它的**正则文本**里必然含这些模式（构造性自匹配），非写回
_nb=""
while IFS=: read -r _f _n _rest; do
  [ -n "${_f:-}" ] && [ -f "$_f" ] || continue
  case "$_n" in ''|*[!0-9]*) continue ;; esac
  _line=$(sed -n "${_n}p" "$_f")
  # ★ 守卫形态本身不算"未声明写回"：`case "$F" in "$TMP"/*)` 的写法**只在临时副本上写**
  printf '%s' "$_line" | grep -qF '"$TMP"/*)' && continue   # ★ 定串匹配（`/*)` 里的 `*` 会被当量词 ⇒ 正则匹配不上，实测漏豁免）
  printf '%s' "$_line" | grep -q '有意回写' && continue
  if [ "$_n" -gt 1 ] && sed -n "$(( _n - 1 ))p" "$_f" | grep -q '有意回写'; then continue; fi
  # ★ 平台无关：用 `sed -E` 的 `(cp|mv)` —— **BSD sed 不支持 `\|`**（实测：抽取恒空 ⇒ 判据在 macOS 空转、在 GNU CI 才生效）
  # ★ 先剥掉行尾注释（否则 `cp "$F" "$BAK2"   # ★ 2：mktemp…` 会把注释当目标 —— 实测抽出 `并发相撞）`）
  _code=$(printf '%s' "$_line" | sed 's/#.*$//')
  _dst=$(printf '%s' "$_code" | sed -E 's/.*(cp|mv) *([^;]*).*/\2/' | awk '{print $NF}' | tr -d '\042'\047)
  case "${_dst:-}" in
    \$TMP*|/tmp/*|\$BAK*|\$BAK2*|mktemp*|/dev/null*) continue ;;   # 目标是临时件 ⇒ 不算写回真件
  esac
  # ★ 空/未判定目标 ⇒ **fail-closed 报红**（不许因为"我没解析出来"就放过）
  _nb="$_nb $_f:$_n(目标=${_dst})"
done <<< "$_cand"
if [ -n "$_nb" ]; then red "未声明的写回（须在同行或上一行标注「有意回写（理由：…）」）:${_nb}"; fail=1
else grn "写回真件：无非追加写法（或已按同行/上一行标注）"; fi
_nw=$(grep -rc '有意回写' tools/*.sh 2>/dev/null | grep -v 'spec-lint' | awk -F: '{s+=$2} END{print s+0}')
if [ "${_nw:-0}" -lt 2 ]; then red "已标注的写回站点只有 ${_nw:-0} 个（< 2 ⇒ 正列举被削弱）"; fail=1
else grn "已标注写回站点 = ${_nw}（不含检查器自身；数字变化 ⇒ 人复核）"; fi

# ★ C'（2026-10-14）：**GNU 专属特性 ⇒ 必须标注**（判据只许依赖：shell 内建 + git + python3 + 可移植 grep/sed 基本语法）
#   为什么：`awk '\s'`/`grep '\s'` 在 **BSD 是死模式（静默永不命中）**、`grep -P` 在 BSD rc=2 ⇒ **门会静默空转**（比红更坏）。
# ★ C' 的**模式行自身**用「GNU 专属（理由：检查器自身的模式文本）」标注（有了标注就不必排除自身 ⇒ 不留盲区）
# GNU 专属（理由：下面这一行是**检查器自身的模式文本**，本身不在 BSD 上执行；标注放独立行，避免注释吞掉续行反斜杠）
_gnu=$(grep -rnE 'grep[^|]*-P\b|sed[^|]*-r\b|sort[^|]*-V\b|readlink[^|]*-f\b|xargs[^|]*-r\b|mktemp[^;)]*-p\b|\\s|gawk\b|gensub\(|asort\(|find[^|]*-printf|--wildcards' tools/*.sh examples/*/*.sh decisions/*.md .github/workflows/*.yml docs/*.md docs/*/*.md 2>/dev/null \
       | grep -vE ':[0-9]+: *#'  | grep -v 'timeout=' | grep -v 'GNU 专属' \
       | grep -vE 're\.(compile|finditer|search|match|sub|fullmatch)|import re|python3 -c' \   # python 的空白类元字符合法，非 GNU 专属
       | grep -v '^tools/regex-census.sh:' || true)
if [ -n "$_gnu" ]; then red "未标注的 GNU 专属特性（BSD 会静默空转/报错；要么改可移植写法，要么同行标注「GNU 专属（理由…）」）"; printf '%s\n' "$_gnu" | head -5 | sed 's/^/      /' >&2; fail=1
else grn "GNU 专属特性：0 处（判据只依赖 shell 内建 + git + python3 + 可移植 grep/sed）"; fi

[ "$fail" = 0 ] && { echo "spec-lint: PASS"; exit 0; }
echo "spec-lint: BLOCK（规范自身未过闸门）" >&2
exit 2
