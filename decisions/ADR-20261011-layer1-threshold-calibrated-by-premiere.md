---
id: ADR-20261011-layer1-threshold-calibrated-by-premiere
seq: 9015
status: accepted
hard: true
applies-to: ["PLAN.md", "RNA.md"]
effective-from: 2026-10-11
timing: post
redtest: "validate --probe ADR-20261011-layer1-threshold-calibrated-by-premiere"
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
origin: "园丁 2026-10-11 裁定：'阈值暂留 280，首演后按实际占用校准（单变量：这次只改对象）' ⇒ 首演实测 288 越线 ⇒ 本 ADR 即那次校准（对象不变、只动阈值）"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  d=$(dirname "$F")
  t=$(( $(wc -l < "$d/PLAN.md") + $(wc -l < "$d/RNA.md") ))
  [ "$t" -gt 320 ] && echo "常驻阅读层（PLAN+RNA）合计 $t 行 > 320（首演校准后的阈值）"
last-hit: null
hit-count: 0
supersedes: ADR-20261011-layer1-budget-is-attention-not-maintenance
---

# 阈值经【首演校准】：280 → 320

## 这次改的只有阈值（对象与判据形状不变）

**对象**仍是 `["PLAN.md","RNA.md"]`（前一条 ADR 已立）；**判据形状**不变；
**唯一变化**：`280 → 320`（留 ≈11% 余量）。
**为什么走新 ADR 而不是原地改**：`decisions/` 是**冻结账本** —— `改 = supersede，不改原文`。
（我第一遍确实原地改了，**违宪**；由外挂审查问"落地路径"当场指出 ⇒ 恢复原文 + 立本 ADR + 老 ADR `status: deprecated`。）

## 校准的依据（可复算）

```
首演实测（2026-10-11）：PLAN.md 59 行 + RNA.md 229 行 = 288 行 > 280 ⇒ 越线
其中 RNA 由 106 → 229 行（人亲笔 v2.1：两截合并 + §八 体检调度 + §九/§十 信使截）
证据链：hook 测试的 `写 PLAN.md ⇒ 期望 exit=0` 因此转红（hook_test 8/9）⇒ 证明该闸门真在拦；
校准后 hook_test 9/9、ci-local 六行全 OK。
新阈值 320 = 288 + 32 行余量（≈11%）⇒ 下一位读者一眼看得出它还留了空间。
```

## 边界

· **不改对象**（改对象是前一条 ADR 的事）；· **不追溯**（历史圈的越线不重判）；
· **再校准**（若下一圈又贴顶）⇒ **仍走 supersede**，不走原地改 —— 本 ADR 存在的意义之一就是把这次教训钉住。
