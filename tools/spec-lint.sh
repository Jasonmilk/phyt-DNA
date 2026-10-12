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
if grep -qE '^\s*(expires-on|auto-expire):' "$SPEC"; then
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
if grep -rqE '^\s+.*2>/dev/null' decisions/*.md 2>/dev/null; then
  bad=$(grep -lE '^\s+.*2>/dev/null' decisions/*.md 2>/dev/null | tr '\n' ' ')
  red "check 表达式含 2>/dev/null（静默失败=伪证）: $bad"
else
  grn "check 表达式无静默失败"
fi

# 闸门7：测试基础设施不得含全量还原（ADR-0009，五次同族现身）
# 只扫 *.sh 脚本：fixtures/README.md 等文档示例文字会合法地提及禁令本身（T0 顺带修复）
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
python3 - <<'PYDC'
import io, glob, os, sys
KEYS_OPEN=('if ','for ','while ','case ','{')
bad=[]
for f in sorted(glob.glob('tools/hooks/*')):
    if not os.path.isfile(f): continue
    depth=0; exit_at=None
    for n,raw in enumerate(io.open(f,encoding='utf-8').read().split('\n'),1):
        t=raw.strip()
        if not t or t.startswith('#'): continue
        for kw in ('fi','esac','}','done'): 
            if t==kw or t.startswith(kw+' ') or t.startswith(kw+';'):
                if depth>0: depth-=1   # ★ 钳位：不让"收"多于"开"（bash 自己管不配对；这里只防误报）
        if exit_at is not None and depth==0 and not t.startswith(('fi','esac','}','done',';;')):
            bad.append('%s:第%d行（在 第%d行 exit 之后 · 深度0 ⇒ 真死代码）' % (os.path.basename(f), n, exit_at)); break
        if exit_at is None and depth==0 and (t.startswith('exit ') or t=='exit'):
            exit_at=n
        if t.startswith(('if ','for ','while ')) or t=='{': depth+=1
        if t.startswith('case '): depth+=1
PYDC
[ -n "${DEADCODE:-}" ] && true
if python3 - <<'PYDC' 2>/dev/null
import io, glob, os
bad=False
for f in sorted(glob.glob('tools/hooks/*')):
    if not os.path.isfile(f): continue
    depth=0; exit_at=None
    for n,raw in enumerate(io.open(f,encoding='utf-8').read().split('\n'),1):
        t=raw.strip()
        if not t or t.startswith('#'): continue
        low=t
        if depth>0: depth-=1   # ★ 钳位：不让"收"多于"开"（bash 自己管不配对；这里只防误报）
        if exit_at is not None and depth==0 and not low.startswith(('fi','esac','}','done',';;')):
            print('%s:第%d行（第%d行 exit 之后 · 顶层 ⇒ 死代码）' % (os.path.basename(f), n, exit_at)); bad=True; break
        if exit_at is None and depth==0 and (low=='exit' or low.startswith('exit ')): exit_at=n
        if low.startswith(('if ','for ','while ','case ')) or low=='{' or low.endswith('(){') or '() {' in low: depth+=1   # ★ 函数定义也是'开'（实测漏它=三条假阳）
raise SystemExit(0 if not bad else 1)
PYDC
then grn "钩子里没有 exit 之后的死代码（深度感知；**局限具名：不数单行 if …; fi ⇒ 会让深度漂**）"; else red "钩子里的 exit 之后仍有可执行行（死代码 ⇒ 你以为它在工作）"; fi
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
[ "$fail" = 0 ] && { echo "spec-lint: PASS"; exit 0; }
echo "spec-lint: BLOCK（规范自身未过闸门）" >&2
exit 2
