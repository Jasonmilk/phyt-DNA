# phyt-DNA

> Generic self-growing project methodology template and authoritative source.
> All projects adopting this methodology anchor to it, avoiding version drift and ambiguity.

## Philosophy

**A plant is not designed — it grows from a seed**, spontaneously, continuously, slowly,
according to environmental conditions and intrinsic genes.

Traditional software methodology treats a project as a machine — draw a blueprint,
assemble parts, debug, run. But living projects are **not** like that. They are more like
plants: from a seed (core vision), driven by environment (user needs, technical constraints,
ecosystem change) and intrinsic genes (immutable principles), they grow.

phyt-DNA borrows plant metaphors to describe this methodology — **we are not doing botany.**
DNA is the immutable gene (principles and processes), RNA is the loading protocol
(how to read the gene and guide growth), SPEC is the knowledge ontology (complete narrative),
PLAN is the current growth stage, GROWTH is the growth record, DEPRECATE is death and
retirement, archive is historical sediment.

**phyt-DNA makes projects grow like plants, not get built like machines.**

**Protection is the railing of growth, not a wall.**
Methodology protection spec: [`docs/PROTECTION.md`](docs/PROTECTION.md)

---

## What's new in V2

V1 was a document template. **V2 adds the parts that were proven by actually running it:**

| | V1 | V2 |
|---|---|---|
| Gates | concept in docs | **`hard: true` field on an ADR** — not a separate layer |
| Check logic | hardcoded in engine | **ADR carries its own `check:` field** |
| Timing | not distinguished | **`timing: pre\|post`** — path before, content after |
| Time boundary | none | **`effective-from`** (prevents retroactive false positives) |
| Verification | none | **3-layer stack** + self-reference boundary |
| CI | written but never run | **Running + red-test verified** |
| Cull threshold N | only in conversation | **Landed as an ADR** (unnamed rules can't be cited) |
| Total load | unknown | **278 lines ≤ 280** ✅ |

### Evidence-based

Every conclusion in [`docs/PROTECTION.md`](docs/PROTECTION.md) is tagged
**已实测 (measured) / 研究背书 (research-backed) / 待验证 (unverified)**.
Unverified items must not be written into DNA.

Measured in a real repo: **26 production tasks · 23 real interceptions · 5/5 heartbeats ·
CI red-test passed · 5 engine bugs found and fixed · 1 hypothesis killed by experiment.**

---

## Quick start

```bash
# 1. Copy the methodology skeleton into your project
#    v2: 仓库根即模板（原 template/ 已并入根）
git clone git@github.com:Jasonmilk/phyt-DNA.git /tmp/phyt-dna
cp -r /tmp/phyt-dna/{DNA.md,RNA.md,SPEC.md,PLAN.md,GROWTH.md,VISION.md,DEPRECATE.md,decisions,ledger,fixtures,tools} <your-project>/

# 2. Write your first gate as an ADR (no code changes needed)
#    see examples/ADR-EXAMPLE.md, then copy it and fill in your own check:
cp examples/ADR-EXAMPLE.md <your-project>/decisions/ADR-<date>-<your-first-gate>.md

# 3. Turn on CI (the only real gate — pre-commit can be skipped with --no-verify)
cp examples/phyt.yml <your-project>/.github/workflows/
#    first run will be RED until the asset baseline lands:
cd <your-project> && ./tools/check-baseline.sh --update && git add tools/baseline.sha256 && git commit

# 4. Optional: hook for real-time interception
#    ⚠ 未声称已验证：物理拦截仅 payload 级实测（Edit DNA.md → exit 2），
#    尚未在真实 agent 任务中发生。装上后请先跑一次真实任务自行验证。
cp examples/pretooluse-gate.sh <your-project>/.claude/hooks/pretooluse-gate.sh
cp examples/.claude-settings.json <your-project>/.claude/settings.json
```

**W0 rule: zero scripts at first.** Do one real task by hand and log it.
Writing scripts before you have real data = guessing which gates deserve to exist.

---

## Adoption · 三步把 V2 落地到你的项目

README 承诺：*"Every project adopting this methodology lands the zero-cost checklist at its first public milestone."*
V2 让这句话**第一次可执行**——以前是手工打勾，现在是 `cp -r` + CI 自动检查：

1. **拷贝骨架**（Quick start 第 1 步）：6 个根文档 + `decisions/ ledger/ fixtures/ tools/` 全部进项目
2. **写第一条 ADR**（第 2 步）：把第一条散文约束结晶成可执行闸门——有 `id`、有 `check:`、有心跳、会死
3. **开 CI**（第 3 步）：`.github/workflows/phyt.yml` 五步门禁，push 即检查
   - 首次运行**必然 RED**（缺资产基线）——按第 3 步补基线即复绿，不要绕开
   - 之后每次 push：资产完整性 / spec-lint / 心跳 / 全仓扫描 / 防装饰，5 步全过才算绿

hook（第 4 步）保持 **optional**：组装已验证，物理拦截未在真实 agent 任务中发生——不要声称已验证。

---

## Directory

```
根目录（v2：仓库根即模板，原 template/ 已并入根）
  DNA.md          immutable gene (10 native + 6 derived laws)
  RNA.md          loading protocol (3-layer attention budget)
  SPEC.md         knowledge ontology
  PLAN.md         current growth stage — MUST READ at session start
  GROWTH.md       growth rings (keep last 3)
  VISION.md       the seed
  DEPRECATE.md    death and retirement (3 kinds of ending)
  decisions/      single source of truth — gates live here
  ledger/         append-only accounting
  fixtures/       counter-examples for heartbeats
  tools/          engine + linters (zero hardcoded gates)

docs/PROTECTION.md   the full spec
examples/            copy-paste ready ADR, hook, CI workflow
```

---

## Closed-loop key nodes

- **Total load: ≤280 lines, ≤4500 tokens.** `PLAN.md` is must-read — a new session must
  load PLAN first to confirm the current stage, avoiding wasted effort on completed stages.
- **Match volumes by task keywords.** Load only volumes relevant to the current task;
  never load everything at once.

Every project adopting this methodology lands the zero-cost checklist at its first
public milestone.
