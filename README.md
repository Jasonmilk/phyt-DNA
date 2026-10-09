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
</p>

# phyt-DNA

> Generic self-growing project methodology template and authoritative source.
> All projects adopting this methodology anchor to it, avoiding version drift and ambiguity.
> **Authoritative source: the `v2` branch (default).** The `v1` branch is kept as historical
> archive only — don't anchor to it.


## The second axis: is a verdict *trustworthy*? (BACKFLOW 2026-10-09)

`pass | block` cannot tell these four apart:

| | **true** | **false** |
|---|---|---|
| **green** | passed **and can be shown to fail** (a fixture crosses the threshold) | passed but **no fixture** — nobody ever proved it can go red |
| **red** | failed for a **nameable** reason (the criterion) | failed for **something else** (tool usage error / missing precondition / the same command answering differently) |

> **`pass` alone is NOT reportable — it must be `pass + alive`.**
> **A green set with no fixtures is not green, it is UNMEASURED.**

See **`docs/MULTIMETER.md`**. Measured on the first adopter: 79 "proven" of which 78 had no fixture;
8 runs in one identical environment produced 6 distinct fingerprints (`proven 53..79`, `red 2..10`, `held 1..31`).

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

### What a verdict is worth (backflow 2026-10-09, from the first real adopter)

`pass` alone is **not reportable** — it must be `pass + alive`. A green set with no fixtures is not
green, it is **unmeasured**. And a probe must report **two worlds**: the un-injected baseline
(*is the repo ill?*) and the injected state (*is the gate alive?*) — reporting only the latter makes a
fixture's achievement look like the repo's disease. See `docs/MULTIMETER.md`.

### Evidence-based

Every conclusion in [`docs/PROTECTION.md`](docs/PROTECTION.md) is tagged
**measured (已实测) / research-backed (研究背书) / unverified (待验证)**.
Unverified items must not be written into DNA.

Measured in this repo (2026-10-09): **gates = `ls decisions/ADR-*.md | wc -l` · heartbeats = `bash tools/validate.sh --probe-all` ·
5 ADRs crystallized + 1 governance rule · 2 engine bugs found & fixed by probing ·
CI: first run RED (no baseline) → GREEN → red-test RED → GREEN · 2 self-test interceptions (payload-level).**

---

## Status · current real state (honesty boundary)

| Item | State |
|---|---|
| Gate mechanism | ✅ every gate is **two-way falsifiable** (an `inject.sh` that really crosses the threshold **and** a `counter.sh` that must not trip) · run `bash tools/validate.sh --probe-all` for the current reading · CI all green |
| **Inner-ring rotation** | ⚠️ **0/0 — phyt-DNA itself has zero `kind: task` production tasks** |
| Physical interception | ⚠️ payload-level only, **never observed in a real agent task** |
| `--cull` | ✅ judge in place, but **no defendant yet** (no gate has seen 20 production tasks) |

> Complete machinery ≠ production-verified. This system is all green in its own
> self-checks, and **has never turned once in production**.
> The first real project will produce the real numbers.

---

## Quick start

**The one command** (run it after you change anything — this is the repo's signature move):

```bash
bash tools/validate.sh --probe-all     # every gate: baseline / injected / counter
bash tools/validate.sh --index         # the gate INDEX (one line per gate) — run this BEFORE proposing a new gate
bash tools/ci-local.sh                 # replay the CI steps verbatim — run this BEFORE pushing
```

**`--index` is the answer to "how do I avoid re-discovering what already exists":** it prints the
`decisions/INDEX.md` table (one line per gate: id · `applies-to` · has `inject.sh` · has `counter.sh` · timing),
**generated by the engine, not typed by hand**, and **a gate keeps it from drifting**.
**`ci-local.sh` replays `.github/workflows/phyt.yml` step by step** — "locally green" is not "CI green".

Three lines matter, and a reading without all three is incomplete:

| line | what it tells you |
|---|---|
| `基线（未注入）` | **is the repo compliant right now** → red ⇒ the repo is ill |
| `注入后 RED` | **is the gate alive** → this red is **manufactured by the fixture**, *not* the repo's illness |
| `反例守住` | **is the criterion two-way falsifiable** → a content-preserving edit must not change the verdict |


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
#    lives in examples/claude-code/ — optional means optional, copy it in only if you want it
#    ⚠ not claimed verified: physical interception is payload-level only (Edit DNA.md → exit 2);
#    it has never happened in a real agent task. Run a real task to verify it yourself.
cp -r examples/claude-code/ <your-project>/.claude/
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

## Workflow — the order is the point (agents and humans both)

**A description is not guidance.** Follow these four steps **in this order**; each one exists because
skipping it cost someone real time (that is recorded in `decisions/ADR-*.md`'s `origin:` fields).

```
① LOOK FIRST   (before proposing anything)
     bash tools/validate.sh --index        # one line per gate: id · applies-to · inject · counter · timing
     cat PLAN.md                           # the current stage — what is already DONE
   ⇒ If the thing you are about to build is already in that table, you are about to duplicate it.
     (Measured 2026-10-09: an adopter "discovered" that ports needed a gate — a port-table test already
      existed; and "discovered" that think/say/do needed separating — the channels, the gate contract
      and the I7 rule already existed.)

② WRITE        (add a gate = four pieces, never fewer)
     decisions/ADR-<date>-<slug>.md        # H1 first line, then front-matter: id/seq/status/hard/
                                           #   applies-to/redtest/revisit-on/check
     fixtures/<gate-id>/inject.sh          # making the defect → the criterion MUST go red
     fixtures/<gate-id>/counter.sh         # a content-preserving edit → the conclusion MUST NOT change
     bash tools/validate.sh --index > decisions/INDEX.md     # regenerate (the INDEX has its own gate)
   ⇒ A gate without `counter.sh` is `unproven`, not `alive`.

③ VERIFY       (two worlds, three lines)
     bash tools/validate.sh --probe-all
     #   baseline (un-injected)  = is the repo ill?      → red ⇒ the repo is ill
     #   injected RED            = is the gate alive?    → this red is made by the fixture
     #   counter held            = two-way falsifiable?  → a content-preserving edit must not change it

④ PUSH         (replay CI, do not assume)
     bash tools/ci-local.sh                # "locally green" is NOT "CI green"
```

**Anything you cannot run, you cannot claim.** If a step is declared but missing, it is a marked skip
(`exit 4`), never a silent pass.

### Adding a gate, concretely

| step | file | why |
|---|---|---|
| 1 | `decisions/ADR-…md` | gates are an **attribute of an ADR**, not a separate layer (`decisions/README.md`) |
| 2 | `fixtures/<gate-id>/inject.sh` | proves it **can** go red |
| 3 | `fixtures/<gate-id>/counter.sh` | proves it does **not** go red when nothing changed |
| 4 | `bash tools/validate.sh --index > decisions/INDEX.md` | otherwise the INDEX drifts — and a gate catches that |
| 5 | `bash tools/check-baseline.sh --update` | any change under `decisions/` or `tools/` must refresh the asset baseline |

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
  fixtures/       per-gate counter-examples: `inject.sh` (must go RED) + `counter.sh` (must NOT)
  tools/          engine + linters (zero hardcoded gates)
  docs/           MULTIMETER.md (the second axis) · REPLAY-MISSING.md (G2's 4th turn) ·
                  DNA-GATE-DIAGNOSIS.md (how a gate was found to be V=0) · PROTECTION.md
  decisions/INDEX.md   GENERATED by `validate.sh --index` (do not hand-edit; a gate keeps it honest)
  tools/ci-local.sh    replays the CI workflow verbatim (run before pushing)

docs/PROTECTION.md   the full spec
examples/            copy-paste ready ADR, CI workflow, claude-code/ hook package
```

---

## Closed-loop key nodes

- **Total load: ≤280 lines, ≤4500 tokens.** `PLAN.md` is must-read — a new session must
  load PLAN first to confirm the current stage, avoiding wasted effort on completed stages.
- **Match volumes by task keywords.** Load only volumes relevant to the current task;
  never load everything at once.

Every project adopting this methodology lands the zero-cost checklist at its first
public milestone.
