# ledger · 三本账之一（append-only）

## 规则
- **只追加，永不改写**。纠正 = 追加一条 `verdict: correction` 的新记录
- `kind` 必填：`task` | `probe` | `scan` | `selftest` | `sim` | `correction`
- **生产指标只算 `kind: task`**（探针/扫描/自检/模拟不计入）

## schema
```json
{"ts":"ISO8601","gate_id":"ADR-xxx","task":"T01","verdict":"block|pass|correction",
 "override":false,"source":"engine|hook|ci|cli","event_id":"唯一","kind":"task","note":"..."}
```

## 独立申诉账
`appeals-<年>.jsonl` —— 破解"运营者自己分类自己"的自证陷阱。
运营者对拦截的申诉**独立记入本账**（`source: user-appeal`），与 override 分账：
`tools/validate.sh --appeal <id> --note "<原因>"` 追加写入。
override 是"运营者放行"，appeal 是"运营者不服"——两者在年轮里分开统计。

---

## BACKFLOW 2026-10-09（P5 · P11）
· 账本行必须**结构化**且**带环境**

### P7 · 计数结构化，不只放 `note`
自由文本的 `note` **无法在两行之间比较** ⇒ 账本记了历史却答不出"变了没有"。
**⇒ 除了给人读的 `note`，必须有机器读的字段：**

```json
{"counts":{"proven":80,"red":6,"held":1,"unregistered":0,"aborted":1,"envMissing":1}}
```

### P6 · 环境由**探测**得到，绝不手写
**手写环境与手写 `note` 同病**：它会照样写 `panel=up` 而面板是关的。
**⇒ 环境字段的值必须来自探测**（与裁决本身用的同一组探测）：

```json
{"env":{"cdp":"up","panel":"up","jsdom":"yes","siblings":{"present":3,"of":3}}}
```

**理由（实测）**：同一 commit，`proven 55 → 77 → 80`、`held 31 → 1`、`red 2 → 8 → 6` ——
**只因为环境从 down 变 up**。**没有环境的计数在跨 commit 时不可比。**

### ★ 但 P6 不够（实测追加）
**环境相同，运行之间仍然不一致**：同环境 8 次运行出现 **6 种指纹**。
⇒ 记账本行还必须带 **`fingerprint`**（本次裁决的指纹）与 **`validity`**（第二根轴）——
**见 `docs/MULTIMETER.md`（P11）。**
