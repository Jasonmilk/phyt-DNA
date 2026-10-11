---
id: ADR-20261011-dna-modification-first-exercise
status: accepted
hard: false
effective-from: 2026-10-11
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
---

# DNA 修改门【首演】：`继承`节例子改为指认真实住址（"用完即焚"在 Tentacle 的 VISION，不在其 DNA）

## 这次修改是什么（DNA 的"门是授权，不是不可能"第一次被真实走一遍）

**改什么**：`DNA.md` 的 `## 继承` 节，把举例
`（如 Tentacle 增"用完即焚"）`
改为
`（如 Tentacle 以其 VISION 的"用完即焚"为株系基因）`。

**为什么改**：审查实测 —— `helix-tentacle/docs/DNA.md` 里"用完即焚"**出现 0 次**；
它在 Tentacle 的 `docs/VISION.md` · `docs/spec/philosophy.md` · 白皮书里。
**引用挂真值源**（D24）：例子必须指向**真实住址**，否则它就是"没有收据的愿望"。

## 门的三个要件（逐条留痕）

| 要件 | 本轮实际 |
|---|---|
| ① 一条 ADR | **本文件**（`decisions/ADR-20261011-dna-modification-first-exercise.md`） |
| ② 园丁的明确批准 | **园丁 2026-10-11 明确答复**："Tentacle：改例子（…）——且这次编辑作为修改门首走：完整 ADR + 人批 + 基线更新" |
| ③ 基线更新 | `bash tools/check-baseline.sh --update`（`DNA.md` 是资产基线 scope 内的文件 ⇒ 不改基线则 `check-baseline` 必红） |

## 为什么它值得作为首演（而不是等事故逼）

DNA 的「守卫不自签」要求：**一条规则的 alive，要由"被它推翻又放行的案例"签发**。
修改门此前只有条文、**没有一次真实的修改案例** ⇒ 本轮恰好有一处**最小、真实、必要**的修改
（一个例子指错了住址）⇒ **用它把门走通**：ADR 在、人批在、基线更新在 ⇒ 门为 `alive`。
**别等事故逼**：等到"不改就会出事"时才第一次用门，那次就会同时承受门的未知与事故的代价。

## 边界（本次不做的事）

· **不改十个基因名**（名目恒常；本次只改"继承"节的一个**例子**）。
· **不迁 Tentacle 的株系基因进它的 DNA**（那是另一件事：**携带项④** 的"子仓 DNA 分区纪律"要先立）。
· **不改退休/判例/派生律住址**（未在本次授权范围内）。
