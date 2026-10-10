# ADR-20261009：README 必须带「按需指针」块（否则入口会退化成目录）

---
id: ADR-20261009-readme-must-carry-the-on-demand-pointer-block
seq: 9010
status: accepted
hard: true
applies-to: ["README.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-readme-must-carry-the-on-demand-pointer-block"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "2026-10-09：README 是唯一的入口，而入口的价值不在'内容全'，在'能指向唯一的那一份'（按需加载）。全生态六仓已对齐同一形状，故把它钉成闸门而不是只写进规范。"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  # 按需指针块的两个必需特征：一个可检索的块标识 + 一张"问题 → 读这份"的表。
  grep -q '按需指针' "$F" || echo "README 缺【按需指针】块标识（入口会退化成目录）"
  grep -qE '^\| *我要回答的问题 *\|' "$F" || echo "README 缺【问题 → 读这份】表头（读者无法按需取用）"
  grep -q 'docs/INDEX.md' "$F" || echo "README 未指向 docs/INDEX.md（按问题索引的唯一入口）"
last-hit: null
hit-count: 0
supersedes: null
---

# README 必须带「按需指针」块

## 出处

2026-10-09 人类裁定：*"README.md 确实是一个重要的入口，且自带指针能力！只要做好按需指针，
工作就会很清晰，下次你不会忘记我们的成就和工作进度！"*
⇒ 全生态六仓 README 已**对齐同一形状**（表头统一为"我要回答的问题 | 读这份"）。

## 为什么

**入口的价值不在"内容全"，在"能指向唯一的那一份"** —— 复制会漂，指针不会（`HANDOFF.md` 的同一条理由）。
若 README 只是目录，读者会被一次打满注意力，且**没有任何东西保证"该指向的那一份"还在**。

## 红测

`fixtures/<id>/inject.sh` 把块标识删掉 ⇒ 心跳报 RED。
`fixtures/<id>/counter.sh` 做**内容保持**的改动（只改 mtime）⇒ 结论不得改变。
