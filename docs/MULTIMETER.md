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

## 现存硬编码清单（2026-10-12 · **观测层：不造门、不派活**）

**它就是下一片工作面的地图** —— 改它只在**真活来时**改（按需驱动），不为清单本身开工。
（生成：各门 `check:` 体里的数字/阈值；命令见本仓 `--index` + 逐门 `check:` 提取。）

| 门 | 常数 |
|---|---|
| `ADR-20261009-DEPRECATE-must-exist` | `-lt 3` |
| `ADR-20261009-DNA-is-immutable` | `字面 29` |
| `ADR-20261009-GROWTH-max-3-entries` | `-gt 3` |
| `ADR-20261009-GROWTH-max-3-entries` | `字面 2026` |
| `ADR-20261009-GROWTH-max-3-entries` | `字面 10` |
| `ADR-20261009-GROWTH-max-3-entries` | `字面 12` |
| `ADR-20261009-PLAN-must-exist` | `-lt 3` |
| `ADR-20261009-PLAN-must-stay-under-150-lines` | `-gt 150` |
| `ADR-20261009-PLAN-must-stay-under-150-lines` | `-gt 0` |
| `ADR-20261009-PLAN-must-stay-under-150-lines` | `字面 150` |
| `ADR-20261009-PLAN-must-stay-under-150-lines` | `字面 2026` |
| `ADR-20261009-PLAN-must-stay-under-150-lines` | `字面 10` |
| `ADR-20261009-PLAN-must-stay-under-150-lines` | `字面 12` |
| `ADR-20261009-README-must-carry-the-one-comma` | `-lt 10` |
| `ADR-20261009-README-must-carry-the-one-comma` | `字面 10` |
| `ADR-20261009-VISION-must-exist-and-be-a-seed` | `-lt 5` |
| `ADR-20261009-docs-must-be-indexed` | `字面 2026` |
| `ADR-20261009-docs-must-be-indexed` | `字面 10` |
| `ADR-20261009-docs-must-be-indexed` | `字面 12` |
| `ADR-20261009-layer1-total-under-280-lines` | `-gt 280` |
| `ADR-20261009-layer1-total-under-280-lines` | `字面 280` |
| `ADR-20261009-lesson-must-be-replayed` | `字面 2026` |
| `ADR-20261009-lesson-must-be-replayed` | `字面 10` |
| `ADR-20261009-readme-must-be-a-truthful-entry` | `字面 2026` |
| `ADR-20261009-readme-must-be-a-truthful-entry` | `字面 10` |
| `ADR-20261009-readme-must-be-a-truthful-entry` | `字面 12` |
| `ADR-20261009-shell-var-before-cjk-must-brace` | `字面 2026` |
| `ADR-20261009-shell-var-before-cjk-must-brace` | `字面 10` |
| `ADR-20261009-shell-var-before-cjk-must-brace` | `字面 09` |
| `ADR-20261011-layer1-budget-is-attention-not-` | `-gt 280` |
| `ADR-20261011-layer1-budget-is-attention-not-` | `字面 280` |
| `ADR-20261011-layer1-threshold-calibrated-by-` | `-gt 320` |
| `ADR-20261011-layer1-threshold-calibrated-by-` | `字面 320` |
| `ADR-20261011-recopy-must-equal-the-gene-set` | `字面 2026` |
| `ADR-20261011-recopy-must-equal-the-gene-set` | `字面 10` |
| `ADR-20261011-recopy-must-equal-the-gene-set` | `字面 11` |
| `ADR-20261011-replay-per-revisit-period` | `字面 2026` |
| `ADR-20261011-replay-per-revisit-period` | `字面 10` |
| `ADR-20261011-replay-per-revisit-period` | `字面 11` |
| `ADR-20261012-ledger-new-lines-parseable-and-` | `字面 2026` |

**H0（元律）判定口径**：能回答"由哪条命令派生" ⇒ 是测量；答不出 ⇒ 禁用或 `exit 4`。
