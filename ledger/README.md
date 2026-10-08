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
