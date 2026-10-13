# 测电仪 · 裁决的第二根轴（BACKFLOW P11 · 2026-10-09）

> **一句话**：`pass | block` 是一维的，而一维**区分不了"真绿"与"假绿"、"真红"与"假红"**。
> 测电仪就是**第二根轴**：让每个裁决**自带它是否可信**。

## 一、四种状态（一维分不开的四个东西）

| | **真** | **假** |
|---|---|---|
| **绿** | **真绿**：过，**且能被证明会红**（有夹具，且真的越阈） | **假绿**：过，但**没有夹具** —— 没人证明过它会不会红 |
| **红** | **真红**：红，且**理由可归因**（就是这个判据） | **假红**：红，但**理由不是这个判据**（工具用法错 / 缺前置 / **同一命令两次不同答案**） |

```
verdict:  pass | block
validity: alive | unproven | unattributable | flaky
world:    仓库态 | 注入态        ← ★ 第二根轴之外，还必须说【在哪个世界】
```

**★ 红也要归因（这是"pass 独报不算"的镜像）**：
`pass` 要写成 `pass + alive`；**`block` 要写成 `block + 谁 + 在哪个世界`。**

| 红的两种 | 含义 | 处置 |
|---|---|---|
| **仓库态红** | 仓库现在真的违规 | 修仓库（**若涉及权威卷，先走 ADR/人批准**） |
| **注入态红** | **夹具**造出的违规被检出 ⇒ 证明**闸门活着** | **不是仓库的病**；仓库态那行才是 |

**⇒ 只报注入态**，会把"夹具的功劳"当成"仓库的病"** —— 实测（2026-10-09）：一次 `--probe-all` 的
6 条 RED 全被读成"本仓自身三点不合规"，**差点据此去改 `DNA.md`/`RNA.md`/`SPEC.md`/`PLAN.md`**，
**而实测仓库那三项全是绿的**。
**⇒ 噪音的危害不止"多报"，更重的是它**把真红挡住了**：两世界一对比 ⇒ 5 绿 + 1 真红，
而那条真红恰是先前没被注意的。（本仓那条真红经查是 `check` 自命中 ⇒ 见下。）

## 二、★ 机械围栏（让"报告假绿"写不出来）

> **`pass` 单独不可报告 —— 必须是 `pass + alive`。**
> **"一组 gate 全绿而没有夹具" ⇒ 那不是绿，那是**未测量**。**

这与 `tools/validate.sh` 的**零闸门具名 BLOCK** 是同一条：
**空集合上的"全部通过"是伪证。**

## 三、实现（三件，已在采用者 Cellrix 跑通）

1. **夹具即"能红"的证明**：`fixtures/<gate-id>/inject.sh`（正例）+ `counter.sh`（反例）
   ⇒ 有夹具的 gate 才是 `alive`
2. **`--probe` 写账本**（`kind: probe`，`verdict: pass|block`）
   ⇒ 探针结果**留痕**；不写账本就不算闭环（"我没跑过它"与"我跑过且它红了"无法区分）
3. **`fingerprint` + `validity` 进账本行**：
   ```json
   {"fingerprint":"014136d71751",
    "validity":{"gatesWithFixture":1,"provenWithoutFixture":78,"falseGreenRisk":"PARTIAL"}}
   ```

## 四、时序轴（最阴的一类假红）

**同一命令两次给出不同答案** ⇒ 该裁决**既不是红也不是绿**。

**⇒ `fingerprint`** = 本次裁决的指纹（红名单 + 计数的哈希）；两次运行指纹不同 ⇒ `FLAKY`。
**⇒ 比较**建议只比较**环境相同**的运行（不同环境本来就不可比 —— 见 `ledger/README.md` P6）。

**实测（采用者，2026-10-09）**：
- 同环境 **8 次运行出现 6 种指纹** ⇒ `proven 53..79`、`red 2..10`、`held 1..31`
- **⇒ 该套件此前报告的每一个"79 proven / 3 red"都不是测量**
- 并且：`env` 字段（P6）解释了 `held 31 ↔ 1` 的大跳（`jsdom` 不同），
  **但同环境内仍不一致** ⇒ **P6 必要，不充分；P11 才是补上这一维的那根轴**

## 五、与其它条目一起用

| 条目 | 关系 |
|---|---|
| P3（零闸门具名） | 本条的**特例**：无夹具集合上的"绿" |
| P6/P7（账本结构化 + 环境探测） | 本条的**输入**；但**不能替代**本条 |
| P10（gate 的输入必须是产物） | 同族：都在治"判据依赖了不该依赖的东西" |

---

## 账本双轨读数（2026-10-12 立 · YB：只报后者，"82"会从记忆里消失）

**同一个"坏行"有两个数，必须同时报 —— 否则读数会骗人：**

| 读数 | 值 | 语义 | 能否下沉 |
|---|---|---|---|
| **物理不可解析** | **82** | 因为 append-only，**旧行物理不可改** ⇒ 这个数**永不下沉** | ✗ |
| **无旁证** | **0** | 82 行各有 1 条 `verdict: correction` 旁证（`ref_line` 指向它）⇒ 可下沉到 0 | ✓ |

自证命令（1:1 映射，0 孤儿 / 0 重复 / 0 指向非坏行）：
```
python3 -c "import io,json,collections;bad=[];corr=[];[ (corr.append(json.loads(l)['ref_line']) if json.loads(l).get('verdict')=='correction' and 'ref_line' in json.loads(l) else None) if _try(l) else bad.append(i) for i,l in enumerate(io.open('ledger/hits-2026.jsonl',encoding='utf-8'),1)]"
```
（等价形式：坏行=逐行 `json.loads` 失败的行号集合；旁证=带 `ref_line` 的 correction 行的 `ref_line` 集合 ⇒ 两集合相等即为 1:1。）

**⇒ 只报"0"会让人以为账本干净了；只报"82"会让人以为旁证没做。两个都报才是事实。**

## 口径钉死（2026-10-12）

- **人口 = 活 ADR 28 + tools 15（含 `tools/hooks/` 下的文件）** —— 二元组定死，**不许只报其一**；
- 账本 `kind` 分布是**次级读数**（probe 847 · replay 21 · correction 85 · selftest 3 · **task 1**）；
- **`--cull` 冻结 = 硬约束，不是待办**：减法只能由**人类显式下令**执行（不可逆操作走授权三级守则第③级）。
  替代鉴别器（不改行为面）：用**已有的** `dangerous-action-*` 门当减法池首个被告 ——
  INDEX 实测它 `inject=NO · counter=NO`（**三边一条没证**）⇒ 它是唯一"连夹具都没有还活着"的门。

## 归档态读数（2026-10-12 · 园丁裁定 4）

`docs/archive/DOC-README-v1.md` 是**指针档**（只存分支 + commit + 日期，不复制正文）⇒ 归档态**必须由命令读**：

```
cd <phyt-DNA> && git log origin/v1 -1 --format="分支 v1 · tip %h · %ad · %s" --date=short
```

**实测读数（活的，不是陈述）**：分支 v1 · tip d41b7ed · 2026-09-24 · feat(rna): 通用铁律第 9 条「非空转自证」—— 断言的价值在它能红

★ 为什么只写命令不写结论："v1 已归档"这类陈述**会腐烂**（分支会动、人会改主意），而命令每次都给当下的事实。
★ 语料纪律（同轮教训）：**裁定 v1 遗产时语料是 `git ls-tree -r origin/v1` / `git show origin/v1:…`**，
不是 v2 工作区 —— 我用 v2 扫 `400` 得"不存在"，而它在 **`origin/v1:README.md:185`**（人批 2026-09-09）。

## 孤儿测试（2026-10-12 · 观测层 · **不造门**）

**它回答的问题**：本仓是不是**自足**的（把仓单独拿走，还跑得动吗）？

```
git clone . /tmp/orphan && cd /tmp/orphan && git remote remove origin && bash tools/ci-local.sh
```

**只写命令，不写结论** —— 结论会腐烂（依赖会变），命令每次给当下的事实。

## 钩子接线读数（2026-10-12 · 一行命令，不造门）

`tools/hooks/` 里的钩子**不会自动生效** —— `core.hooksPath` 是**每克隆一份**的本地配置：

```
git config --get core.hooksPath || echo '未接线 ⇒ 钩子不跑'
```

**只写命令不写结论。**

## 工具口径（三栏 · 2026-10-12 钉死）

| 栏 | 计数命令 | 现值 |
|---|---|---|
| `.sh`（工具脚本） | `ls tools/*.sh \| wc -l` | 16 |
| `hooks`（钩子） | `ls tools/hooks/* \| wc -l` | 1 |
| 其他（非 .sh 的 tools/ 文件） | `ls tools/* \| grep -v '\.sh$' \| wc -l` | 3 |

**报数必须点名是哪一栏**（"17 个工具"这种合并口径 = 流沙）。

## 止损线读数（2026-10-12 · 园丁裁定 0）

```
人口 = 活 ADR 28 + tools/*.sh 16 + tools/hooks 1 = **45**（基线 43 ⇒ **+2**；止损线 N=3 ⇒ **贴线未破**）
命令：for f in decisions/ADR-*.md; do grep -q '^status: deprecated' "$f" || echo x; done | wc -l   # 28
     ls tools/*.sh | wc -l   # 16 · ls tools/hooks/* | wc -l   # 1
```

**替代鉴别器审查（不改 `regex-census` —— 它有调用者）**：`--index` 查"无夹具的门" ⇒ 唯一被告：
**`ADR-20261009-dangerous-action-shapes-must-be-blocked`**（`inject=NO · counter=NO`）⇒ 它是**减法首候选**
（其 `redtest` 由 `hook_test.sh` 9 例承担 ⇒ 是"面"还是"必要"，须外眼裁定）。

**本次触线的定性**：**合规增长 + 待外眼供给减法源**（内审只能看见自己 ⇒ 减法源必须有外眼）。

## 工具口径（钉死，不再漂移）

| 栏 | 值 |
|---|---|
| `tools/*.sh` | **16** |
| `tools/hooks/*` | **1** |
| 合计（报数时就报这两个数，不再报"17 个工具"） | **16 + 1** |

## 现存硬编码清单（**由命令产出，不在文档里写死** · 2026-10-12 H0 第一应用）

```
bash tools/xray.sh --constants
```

**三类数**：**会过期**（写死的测量 ⇒ 改派生或登记例外）· **不会过期**（政策 ⇒ 真值源 = 各自的 ADR）· **已闭合**（门已 deprecated）。
**H0 例外登记**见 `position.md` 同名栏（**豁免必须具名**）。**改它只在真活来时改**（按需驱动）。


## layer1 余量读数（2026-10-12）

```
bash -c 'wc -l PLAN.md RNA.md | head -2'
```

**实测**：PLAN 58 + RNA 259 = **317 / 320 ⇒ 余量 3**。
**政策**：**`PLAN.md`/`RNA.md` 此后【只出不进】**（新内容走 `PLAN-PAUSED.md` 或 DEBTS）；见底 ⇒ **简化或延后，不是迁移**。

## 人口裁定（2026-10-12）

**人口 45 vs 基线 43（+2）** ⇒ 裁为 **【合规增长 · 待真活供给减法源】**（减法源由外眼经 `OUTWARD.md` 登记供给）。**止损线 N=3 ⇒ 贴线未破。**

## `--constants` 读数的效度（2026-10-12）

**"会过期 0" 标 `unproven`**：清点器只认 `= 数字` 形态；字符串/十六进制/时间型常量未覆盖（见 DEBTS）。


## 止损线触线记录（2026-10-13 · **+3 ⇒ 触线**）

```
人口 = 活 ADR 29 + tools/*.sh 16 + tools/hooks 1 = **46**（基线 43 ⇒ **+3 = 止损线 N=3 ⇒ 触线**）
```

**触线的那一件**：`ADR-20261013-probe-scope-must-be-tagged`（**设计稿 · hard:false** —— 先定标签语义，不实现）。
**替代鉴别器审查（当场做）**：`--index` 查"无夹具的门" ⇒ **唯一被告仍是 `ADR-20261009-dangerous-action-shapes-must-be-blocked`**
（`inject=NO · counter=NO`；其 redtest 由 `hook_test.sh` 9 例承担）。
**裁定**：**合规增长（设计稿不判任何东西、不增加执法面）+ 待真活供给减法源**。
**★ 记录规矩**：**触线不自动"裁掉"任何东西** —— 它触发**审查**；撤销/减法必须由**真活或外眼**供给（内审只能看见自己）。

## 本轮发现：`hard:false` 绕过第 4 边（2026-10-13）

**图纸（`hard:false`）不进 `gates()` ⇒ 第 4 边（origin 三要素）根本不审它** —— 实测：我把假 ADR 写成 `hard:false` 时**一路绿灯**。
⇒ **它与"图纸三律"是同一件事的两面**：图纸要**登记 + 并发≤3 + promote-when/日落**，正是为了不让"不审"变成"免审"。

## H0 sweep 重读（2026-10-13 · 用【修好的提取】）

```
awk '/^check: \|/{f=1;next} f&&/^[a-z-]+:/{f=0} f{print}' decisions/ADR-*.md   # ★ 修好的提取（顶格行不终止）
```

**读数**：**功能型 = 0**（确证；`hits-2026`/`appeals-2026` 的残留 **29 处全是散文/注释**）· **扫描总行数 380 = 380**
⇒ **此前盲区（旧提取少看的行数）= 0 现在** —— 它曾经是 **19 行**：`ADR-20261011-recopy-must-equal-the-gene-set` 的判据体
**整段 python heredoc 顶格写** ⇒ 引擎读到第一个顶格行即停 ⇒ **那条判据几乎没被执行过**（已修）。

## 待办：recopy 门的夹具陈旧（**不是违规**）

```
直跑 `--probe ADR-20261011-recopy-must-equal-the-gene-set` ⇒ **腐化**（夹具跨不过阈值）：
夹具的注入点在 `名目重抄` 行，但它改的那处被判据的 `norm()`（去空格/尾 `·`）**归一化掉了** ⇒ 判据看不见。
★ 而 `ci-local` 的**心跳仍报 OK**（33 门）—— **两者不一致**，这本身值得记（心跳的"腐化"判定与单门 probe 不同径）。
恢复点：`bash tools/validate.sh --probe ADR-20261011-recopy-must-equal-the-gene-set`（须恢复 基线绿·注入红·反例守住）

```

## 闸门五分类读数（2026-10-13 · 改名 + 读数来源 · 命令产出）

**总命令**：`bash tools/validate.sh --probe-all > /tmp/pa.out 2>&1`

```
grep -c '基线（未注入）: 红' /tmp/pa.out   # _bl —— 基线红 = 有违规
grep -c '闸门已腐化'        /tmp/pa.out   # _rot —— 注入后不红 = 腐化
grep -B3 -E '基线（未注入）: 红|闸门已腐化' /tmp/pa.out   # 门名（带 [${id}] 前缀）
```

| 类 | 名 | 读数来源 | 本次 |
|---|---|---|---|
| ① | **proven（三态过）** | 每门 `--probe` 三态齐 | **19 门**（名在下方） |
| ② | **腐化（注入后不红 ⇒ 会红未证）** | `_rot` | **0**（>0 时取门名 + 恢复命令） |
| ③ | **基线红（= 有违规）** | `_bl` | **0** |
| ④ | **不在扫描面 · 待夹具** | 无夹具且未声明 probe:none | 门级 **0** + 步骤级 **1**（4b） |
| ⑤ | **另器验证** | 仪器名 + 读数 + 时刻 | hook_test.sh · 9 例 = 必须拦 3 + 放行 4 + fail-closed 2 · 03:3x |

**★ ② 与 ③ 性质相反：不许合并** —— ② 是"门该红却没红"（判据/夹具失效）；③ 是"门红得对"（仓库真有违规）。

**① proven 的 19 门**（恢复命令 = `bash tools/validate.sh --probe ADR-…`）：
DEPRECATE-must-exist · DNA-is-immutable · GROWTH-max-3-entries · PLAN-must-exist · PLAN-must-stay-under-150-lines ·
README-must-carry-the-one-command · VISION-must-exist-and-be-a-seed · appeals-must-be-parseable · docs-must-be-indexed ·
index-must-be-regenerated · ledger-must-be-valid-utf8 · lesson-must-land-in-artifact · readme-must-be-a-truthful-entry ·
shell-var-before-cjk-must-brace · derivation-must-carry-origin · frozen-body-immutable ·
layer1-threshold-calibrated-by-premiere · supersede-must-be-paired · ledger-new-lines-parseable-and-referenced

## c · DNA 门苏醒后的扫描判定（2026-10-13）

```
printf '{"tool":"Write","paths":["decisions/ADR-20261009-DNA-is-immutable.md"]}\n' | ./tools/validate.sh --timing post
```

**三行读数**：**③ 判据体完整执行 ✔** · **④ 三态齐 ✔** · **此刻无违规 ✔**（`{"verdict":"pass","scanned":4,"hits":0}`）。

**`scanned=4` 是哪四个**：shell-var-before-cjk · derivation-must-carry-origin · frozen-body-immutable · supersede-must-be-paired
（凡 `applies-to` 命中 `decisions/ADR-*.md` 者）。**DNA 门 `applies-to = ["tools/check-baseline.sh"]` 不过窄** —— 它的对象就是那件工具。
**为什么绿**：① 判据体现在**完整执行**（顶格行断言 `GRN` 守着）；② 真仓满足它 —— `DNA.md` **确在**资产基线 scope 内
（`bash tools/check-baseline.sh --scope | grep -x DNA.md` ⇒ 命中）。**⇒ 绿是"真绿"，不是沉默。**

## d · README 版本同源：判据自己读的是什么（2026-10-13）

```
grep -n 'symbolic-ref' decisions/ADR-20261009-readme-must-be-a-truthful-entry.md
```

**读数**：判据第 65 行读 **`git symbolic-ref -q --short refs/remotes/origin/HEAD`**（**物理锚点 symref**），
**不是本地 `HEAD`**（`rev-parse --abbrev-ref HEAD` 早已替换）⇒ **读数来自判据自己跑的那条命令** ⇒ **无需改判据**。

## 分母实测（2026-10-13 · **所有"五分类"读数的分母**）

    ls decisions/ADR-*.md | wc -l                     # 总 33
    grep -c '^hard: true$'  decisions/ADR-*.md        # 活 20（∧ ¬deprecated）
    grep -c '^hard: false'   decisions/ADR-*.md        # 图纸 9（∧ ¬deprecated）
    grep -l '^status: deprecated' decisions/ADR-*.md | wc -l   # 4

**总 33 = 活 20 + 图纸 9 + deprecated 4**（自检：不等即具名红）

## ⑥ 图纸单列（9 扇 · **清单 2 的输入**）

| 图纸门 | promote-when | revisit-on | 登记/并发/日落 |
|---|---|---|---|
| claim-needs-redtest | **无** | 2027-04-09 | 未登记 · 9 扇 ⇒ **并发 > 3（违律）** · 无日落 |
| cull-after-20-misses | **无** | 2027-04-09 | 同上（且  已冻结 ⇒ 它只能做蓝图） |
| upstream-manifest-threat-model | **无** | 2027-04-09 | 同上 |
| dna-modification-first-exercise | **无** | 2027-04-11 | 同上 |
| failure-must-be-named-where-machines-can-read | **无** | 2027-04-11 | 同上 |
| recopy-must-equal-the-gene-set | **无** | 2027-04-11 | 同上 |
| replay-per-revisit-period | **无** | 2027-04-11 | 同上 |
| pool-consistency-must-be-checked | **无** | 2027-04-12 | 同上 |
| probe-scope-must-be-tagged | **无** | 2027-01-13 | 同上 |

**★ 一句话**：**9 扇图纸无一处有 ，也无一处登记** ⇒ 图纸三律（登记 · 并发 ≤3 · promote-when + 日落）**全部未落**。

## 真值源链的三级读数（2026-10-13）

| 级 | 真仓读数 | 说明 |
|---|---|---|
| tag `v[0-9]*` | **恒空**（`git tag -l` = 空） | 链靠下面两级 |
| 本地 `refs/remotes/origin/HEAD` | **不存在**（`fatal: … is not a symbolic ref`） | ⇒ **判据此前一直【具名跳过】= 从未真判** |
| **远端 `git ls-remote --symref origin HEAD`** | **读到 `v2`** | ⇒ 正读数（判据真判且一致） |
| 三级都取不到 | **具名 `exit 4`** | 实测（真独立克隆 + 删 origin）：`具名跳过: … 版本真值源不可得` · **stdout 空 ⇒ 非红**（防心跳噪音） |

**④ 三态（改判据后重测）**：基线绿 ✅ · **注入红（`id ⇒ DOC-README-v9` ⇒ `④ 版本不一致：真值源 v2 ⇒ id 应为 DOC-README-v2，实为 DOC-README-v9`）** ✅ · 反例守住（`[]`）✅

## ★★ 事故与教训：**worktree 不是沙箱**（2026-10-13）

**事故**：我在"模拟 CI"时于 **worktree 里跑了 `git remote remove origin`** ⇒ **worktree 与原仓共享 `.git/config`**
⇒ **真仓的 origin 被删**（连同远端追踪引用）⇒ 推送/读数一度失效（已恢复：`git remote add` + 复用 SSH 通道）。
**实测（顺带成为二级读数的来历）**：删掉 origin 后，④ 的行为 = **具名跳过（exit 4）**，不是红。
**教训（与"夹具不得在可能为真的路径上创建对象"同族）**：**凡"我以为隔离了"的地方，先问一句：它共享什么？**
—— worktree 共享 config · 夹具与真件共享目录 · `/tmp/inj.bak` 共享文件名。

## 阈值类门的读数口径（2026-10-13 · ②-7/②-8）

**★ 阈值类门的红只存在于【违规态】；绿态不构成收据** —— 一条阈值门在绿态只能说"当前没越阈"，
它的**能红**必须由**边界样本**证明（否则等于没证）。

**年轮统一口径（命令 + 当前值）**：

```
live=$(grep -c '^## 年轮 ·' GROWTH.md)                 # 当前
arch=$(grep -l '^## 年轮' archive/growth/*.md | wc -l) # 已归档（年轮型）
阈值 = 3（政策；真值源 = ADR-20261009-GROWTH-max-3-entries）
```

**实测**：live **3** / 阈值 **3** / arch **1** ⇒ 溢出 = max(0, live-3) = **0** ⇒ **判据不启动（绿）**。
**边界双测（合成 $F + 真归档）**：live=4（溢出 1）⇒ **绿**（归档恰好覆盖）；live=5（溢出 2）⇒ **红** ✅
⇒ **阈值差一位已被两侧夹住**。

## 阈值门 · 边界六格（2026-10-13 · ②尾巴收据 · 在真克隆里改归档数测得）

判据 = `年轮 n > 阈值(3) ⇒ 溢出 (n-3) 必须真归档（归档年轮型数 ≥ 溢出）` ⇒ 绿 ⟺ 溢出 ≤ 归档：

| 溢出 | 归档 | 判定 | 实测 |
|---|---|---|---|
| **1** | **0** | **必须红** | ✅ `年轮 4 条 > 3，而 archive/growth/ 只有 0 条 ⇒ 溢出 1 条必须真归档` |
| 2 | 0 | 红 | ✅ 同形 |
| 1 | 1 | 绿（归档恰好覆盖） | ✅ 空输出 |
| 2 | 1 | 红 | ✅ `… 只有 1 条 ⇒ 溢出 2 条必须真归档` |
| 1 | 2 | 绿 | ✅ 空输出 |
| **2** | **2** | **必须绿** | ✅ 空输出 |

**夹逼**：`溢出=归档` 绿、`溢出=归档+1` 红 ⇒ **阈值差一位会被两侧抓出**。
**夹具已派生**：阈值读该门 ADR 的 `-gt N`；注入到 `TH + 归档 + 1` ⇒ **不再写死任何数**（H0）。

## ④ 收据三件（2026-10-13 · 在真克隆里测得）

**④-1「就一套」**：钩子里 `spec-lint` 的**调用**数 = **0**（只委派 `bash tools/ci-local.sh`）；
`ci-local` 里 = **2 次调用同一脚本**（步骤 2 与步骤 5「必须真实可红」）⇒ **不是两套对齐，是就一套**。

**④-2 fail-closed（钩子自身异常 ⇒ 拒）**：把 `tools/upstream-manifest.sh` 改名后提交 ⇒
`⛔ 引擎清单重生失败 ⇒ 拒绝提交: bash: tools/upstream-manifest.sh: No such file or directory` + **HEAD 未动** ✅

**④-3 逃生门正例（门自身坏）**：在钩子里植入真死代码（= **门自身坏**）⇒ `PHYT_WIP=1` 提交 ⇒
`逃生门放行 —— 理由（机器给出）: <失败那一步>` · `已落账（kind=skip）` · **HEAD 前进** ✅（**不卡死**）
