---
id: ADR-20261011-frozen-body-immutable
seq: 9016
status: accepted
hard: true
applies-to: ["decisions/ADR-*.md"]
effective-from: 2026-10-11
timing: post
redtest: "validate --probe ADR-20261011-frozen-body-immutable"
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
origin: "reviewer 刺一（2026-10-11）：那次违宪【机器全程全绿】—— CI 过·心跳过·probe 过，抓它的是人的一句话。引擎验证'check 是否被满足'，不验证'check 是否被合法修改' ⇒ 本条补上那一半"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  bash tools/frozen-body.sh --check-file "$F" || true
last-hit: null
hit-count: 0
supersedes: null
---

# 冻结体不可改（freezing-probe · 宪法执法器）

## 它补的是哪一半

引擎的 `gates()` 验证**"check 是否被满足"**；它**不验证"check 是否被合法修改"**。
⇒ 2026-10-11 那次违宪（我原地改了 `ADR-20261011-layer1-…` 的 check）**机器全程全绿**：
CI 过 · 心跳过 · probe 过 —— **抓它的是园丁的一句话**。
⇒ **问句能抓一次是运气；probe 抓第二次才是制度。** 本条就是那台 probe。

## 判据（两条，都不违「守卫不自签」）

1. **首发入库即记指纹**：`tools/frozen-body.sh --write` 把每份 ADR 的**冻结体** sha256 记入
   `decisions/.frozen-body.sha256`（本对象是 `decisions/` 资产，spec-lint/CI 承载，**不是被审层里的 probe**）。
2. **此后正文一改即红**：本闸门对每份 ADR 比对冻结体指纹，不一致 ⇒ **红**，并具名"元数据白名单外的一字一句都不许动"。

## 白名单（**与 `decisions/README.md` 的条文严格同源**）

| 可改（元数据页） | 不可改（冻结体） |
|---|---|
| 前言键：`status` · `supersedes` · `last-hit` · `hit-count` | 前言**其余键** + **正文主体** |
| 正文末的**取代指针块**（以 `---` 分隔、含"已由"） | 其余一切 |

⇒ 于是 `deprecated` + 指针（supersede 落地时**必须**碰冻结文件的那两处）**合法**，
而"悄悄改正文/改 check"**非法且可检**。

## 边界

· **只管"已入库"的 ADR**：新 ADR 在 `--write` 之后才被覆盖（**上线即生效**；清单缺它时打印"不在清单里"而不静默判绿）。
· **不判内容对错**：判据只问"动没动"，不问"改得好不好"（后者是审查环的事）。
