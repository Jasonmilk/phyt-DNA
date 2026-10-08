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
