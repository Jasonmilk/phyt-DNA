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
