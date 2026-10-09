# ADR-20261009：VISION 必须存在，且必须还是个种子

---
id: ADR-20261009-VISION-must-exist-and-be-a-seed
seq: 9004
status: accepted
hard: true
applies-to: ["VISION.md"]
effective-from: 2026-10-09
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261009-VISION-must-exist-and-be-a-seed"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-09 系统扫描）：本仓 DNA/RNA/SPEC/PLAN/GROWTH 都有闸门，唯独 VISION.md —— 【种子本身】—— 没有任何闸门。它被清空、被删除、或被写成一堆与种子无关的东西，都不会有人被拦下来。而 RNA.md §一 把注意力预算的第一层定义在常量规则上，VISION 是判断方向性时唯一的依据。"
risk: normal
check: |
  # 种子必须存在，且必须【还是个种子】（不是一片空白，也不是被长文淹没）。
  n=$(wc -l < "$F")
  [ "$n" -lt 5 ] && echo "VISION.md 只有 ${n} 行 —— 种子被清空或丢失（判断方向性时没有依据）"
  grep -q '^# VISION' "$F" || echo "VISION.md 的第一行不是 '# VISION …' —— 它不再是种子，而是别的东西"
last-hit: null
hit-count: 0
supersedes: null
---

# VISION 必须存在，且必须还是个种子

## 为什么它会缺（本仓自己的形状）

**本仓的闸门是**逐个长出来的**：DNA / RNA / SPEC / PLAN / GROWTH 都各自有一条，
因为它们各自被踩过。**而 `VISION.md` 没被踩过 ⇒ 它就没被守。**

**⇒ 这正是「只长不落的树是标本」的反面：**没被踩过的地方，恰恰是没人看的地方**。**
**⇒ 而 VISION 是**判断方向性唯一的依据**（`RNA.md` §二：*"判断方向性时加载"*）——
**它丢了，方向就没了，而**没有任何判据会说**。**

## 判据（两条，都是"缺失必须具名"）

1. **存在且非空白**（`wc -l` ≥ 5）—— 种子不能是空的
2. **第一行是 `# VISION …`** —— 它必须**还是那个东西**（不是被别的内容顶替）

**⇒ 两条都只在"缺"时报红，不约束写法**（种子怎么写是人的事，判据只管它**还活着、还是它**）。

## 边界（这条闸门**不**做什么）

- **不检查内容质量** —— "愿景写得好不好"不是判据能裁决的
- **不检查长度上限** —— 种子的"长"由作者判断（`RNA.md` 的预算管的是**加载**，不是**存在**）
