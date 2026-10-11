# decisions/ · 唯一真源

> **闸门不是独立层，是 ADR 的一个属性。**
> 闸门池 = 本目录中所有 `hard: true` 的 ADR。

## 两种形态

| 形态 | 是什么 | 行为 |
|---|---|---|
| `hard: true` | **闸门** | 进 INDEX、注入、拦截、有心跳、会死 |
| `hard: false` | **治理规则 / 失败案例索引** | 不进 INDEX、不注入、不拦截、年成本 ≈0 |

## frontmatter 全字段

```yaml
id: ADR-<日期>-<slug>          # 文件名 = id.md（唯一终身身份）
seq: 0001                       # 仅 hard:true 且 accepted 才分配
status: proposed|accepted|deprecated|superseded
hard: true|false                # proposed 期必 false

# —— 生命 ——
applies-to: ["path/glob/**"]    # 生 · 空间边界
effective-from: YYYY-MM-DD      # 生 · 时间边界（缺它 ⇒ 追溯性误判）
timing: pre|post                # 生 · 时机（见下）
redtest: "validate --probe <id>" # 活 · 双轨心跳
revisit-on: YYYY-MM-DD          # 死 · 续期批准 / 风险复审
expires-on: null                # 死 · 自动删除（与 revisit-on 必填其一）

# —— 治理 ——
owner: "@someone"
origin: "ledger:e-xxx / GROWTH#Wxx"   # 教训谱系（≠ supersedes 的闸门谱系）
risk: normal|high                # high ⇒ 豁免频率冷存
check: |                         # 判定逻辑（数据驱动，引擎零硬编码）
  <shell 表达式，$F = 命中的路径>

last-hit: null                   # 引擎回写，禁手编
hit-count: 0
supersedes: null
```

## timing（实测得出，勿省）

| timing | 判定方式 | 挂载点 |
|---|---|---|
| `pre` | **路径黑名单**（事前读不到未来内容） | PreToolUse |
| `post` | **内容判定**（行数/条目数/git diff） | pre-commit / CI |

> 事后全仓扫描**必须只跑 post 型**，否则 pre 型路径黑名单必然误报。

---

## 元数据白名单（与 `tools/frozen-body.sh` **严格同源** · reviewer 刺五 2026-10-11）

`decisions/` 冻结：**改 = supersede，不改原文**。但 **supersede 落地时必须碰两处** ⇒ 它们**合法**：

| 可改（元数据页） | 不可改（冻结体） |
|---|---|
| 前言键 `status` · `supersedes` · `last-hit` · `hit-count` | 前言**其余键** + **正文主体** |
| 正文末尾的"取代指针块"（以 `---` 分隔、含"已由"） | 其余一切 |

⇒ **白名单只有一处真源**：`tools/frozen-body.sh`；本表与它**同源**（改一处必须改另一处，否则对不上）。
⇒ 执法者：`ADR-20261011-frozen-body-immutable`（**正文一改即红**）—— 它把"问句能抓一次是运气"变成"**probe 抓第二次是制度**"。

### 类规则：**`hard` / `check` 字段的编辑 = 改执法**（reviewer ③ · 2026-10-11）

**`hard` 与 `check` 不是"元数据"，是【执法本身】** ⇒ 编辑它们**比改正文更危险**（拆执法 > 改执法 > 改正文）。
⇒ 因此：**编辑 `hard`/`check` 一律按"改行为面"处理** —— 先呈选项、走正门（新 ADR supersede），
或由园丁**一句追溯批准**并留痕。**不许原地改**（我本周违过一次 `check`、一次 `hard`，都是原地改 ⇒ 两笔都已追溯/正门补齐）。
⇒ 执法者：`ADR-20261011-frozen-body-immutable`（冻结体含 `hard`/`check` ⇒ **它们的改动即红**）+ 本条的**洗白防护**（`--write` 不许静默重记）。
