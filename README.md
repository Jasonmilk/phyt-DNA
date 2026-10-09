---
id: DOC-README-v2
owner: "@jasonmilk"
revisit-on: 2027-04-09
effective-from: 2026-10-09
---

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/Jasonmilk/phyt-DNA/actions/workflows/phyt.yml"><img src="https://github.com/Jasonmilk/phyt-DNA/actions/workflows/phyt.yml/badge.svg?branch=v2" alt="CI status" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/Jasonmilk/phyt-DNA" alt="License: Apache-2.0" /></a>
  <a href="https://github.com/Jasonmilk/phyt-DNA/stargazers"><img src="https://img.shields.io/github/stars/Jasonmilk/phyt-DNA?style=flat-square&label=stars" alt="GitHub stars" /></a>
</p>

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

V1 was a document template. **V2 adds the parts that were proven by actually running it.**
Evolution goes by **diff, not rewrite** — the table below is the evolution record.
The debt column must not hide anything.

| | v1 | v2 | Debt (unfinished — not hidden) |
|---|---|---|---|
| Gates | prose in README (no id, no check, cannot die) | **`hard: true` field on an ADR** (has id, `check:`, a heartbeat, can die) | — |
| Check logic | hardcoded in the engine | **ADR carries its own `check:`** (zero hardcoded gates in the engine) | — |
| Timing | not distinguished | **`timing: pre\|post`** (path before, content after) | — |
| Verification | none | 3-layer stack + self-reference boundary | — |
| CI | none | 5 steps + red-test (first RED → baseline → GREEN; injected violation → RED → revert → GREEN) | — |
| Hook interception | none | `.claude/` hook assembled, payload-level tested (Edit DNA.md → exit 2) | **not observed in a real agent task** (T2 gap — not claimed verified) |
| `--cull` | law only in conversation | judge in place (`validate.sh --cull`, report-only) | **no enforcement yet**: cold-store needs human approval; no real cold-store has happened |
| Growth-ring format | four totals only | three numbers + three categories (hits/task · override_rate · heartbeat rate) | **trend / distribution / override-by-reason fields** (T8) |
| 60-minute parameter | hardcoded | calibratable field | **recalibrate after one year** (revisit-on 2027-04-09) |

### Evidence-based

Every conclusion in [`docs/PROTECTION.md`](docs/PROTECTION.md) is tagged
**measured (已实测) / research-backed (研究背书) / unverified (待验证)**.
Unverified items must not be written into DNA.

Measured in this repo (v2.1, 2026-10-09): **6 hard:true gates · 6/6 heartbeats RED ·
5 ADRs crystallized + 1 governance rule · 2 engine bugs found & fixed by probing ·
CI: first run RED (no baseline) → GREEN → red-test RED → GREEN · 2 self-test interceptions (payload-level).**

---

## Status · current real state (honesty boundary)

| Item | State |
|---|---|
| Gate mechanism | ✅ 6 `hard: true` gates, heartbeats 6/6 RED, CI all green |
| **Inner-ring rotation** | ⚠️ **0/0 — phyt-DNA itself has zero `kind: task` production tasks** |
| Physical interception | ⚠️ payload-level only, **never observed in a real agent task** |
| `--cull` | ✅ judge in place, but **no defendant yet** (no gate has seen 20 production tasks) |

> Complete machinery ≠ production-verified. This system is all green in its own
> self-checks, and **has never turned once in production**.
> The first real project will produce the real numbers.

---

## Quick start

```bash
# 1. Copy the methodology skeleton into your project
#    v2: the repo root IS the template (the former template/ was merged into the root)
git clone git@github.com:Jasonmilk/phyt-DNA.git /tmp/phyt-dna
cp -r /tmp/phyt-dna/{DNA.md,RNA.md,SPEC.md,PLAN.md,GROWTH.md,VISION.md,DEPRECATE.md,decisions,ledger,fixtures,tools} <your-project>/

# 2. Write your first gate as an ADR (no code changes needed)
#    see examples/ADR-EXAMPLE.md, then copy it and fill in your own check:
cp examples/ADR-EXAMPLE.md <your-project>/decisions/ADR-<date>-<your-first-gate>.md

# 3. Turn on CI (the only real gate — pre-commit can be skipped with --no-verify)
cp examples/phyt.yml <your-project>/.github/workflows/
#    the first run will be RED until the asset baseline lands:
cd <your-project> && ./tools/check-baseline.sh --update && git add tools/baseline.sha256 && git commit

# 4. Optional: hook for real-time interception
#    ⚠ not claimed verified: physical interception is payload-level only (Edit DNA.md → exit 2);
#    it has never happened in a real agent task. Run a real task to verify it yourself.
cp examples/pretooluse-gate.sh <your-project>/.claude/hooks/pretooluse-gate.sh
cp examples/.claude-settings.json <your-project>/.claude/settings.json
```

**W0 rule: zero scripts at first.** Do one real task by hand and log it.
Writing scripts before you have real data = guessing which gates deserve to exist.

---

## Adoption · land V2 in your project in three steps

README's promise: *"Every project adopting this methodology lands the zero-cost checklist at its first public milestone."*
V2 makes this sentence **executable for the first time** — formerly manual checkmarks, now `cp -r` plus CI checks automatically:

1. **Copy the skeleton** (Quick start step 1): the 6 root docs + `decisions/ ledger/ fixtures/ tools/` into your project
2. **Write your first ADR** (step 2): crystallize your first prose constraint into an executable gate — with `id`, `check:`, a heartbeat, and the ability to die
3. **Turn on CI** (step 3): `.github/workflows/phyt.yml` five-step gate, checked on every push
   - the first run is **necessarily RED** (missing asset baseline) — land the baseline per step 3 to go green; don't bypass it
   - every push after that: asset integrity / spec-lint / heartbeats / full-repo scan / anti-decoration — all 5 must pass to be green

The hook (step 4) stays **optional**: assembly is verified; physical interception has not happened in a real agent task — don't claim it verified.

---

## Directory

```
Repo root (v2: the root IS the template; the former template/ was merged in)
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
