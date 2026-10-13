---
id: DOC-README-v2
owner: "@jasonmilk"
revisit-on: 2027-01-12
effective-from: 2026-10-12
supersedes: DOC-README-v1
---

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/Jasonmilk/phyt-DNA/actions/workflows/phyt.yml"><img src="https://github.com/Jasonmilk/phyt-DNA/actions/workflows/phyt.yml/badge.svg?branch=v2" alt="CI status" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/Jasonmilk/phyt-DNA" alt="License: Apache-2.0" /></a>
</p>

# phyt-DNA
> **A generic, self-growing project methodology — and the authoritative source for it.**
> Every project that adopts it anchors here, so versions cannot drift apart.
> **Authoritative: the `v2` branch (default).** `v1` is kept as historical archive only.

**phyt-DNA makes projects grow like plants, not get built like machines.**

A plant is not designed — it grows from a seed, driven by environment and intrinsic genes.
A machine is blueprinted, assembled, debugged. Living projects behave like the former:
they start from a seed (core vision) and grow under pressure from the environment (user needs,
technical constraints, ecosystem change) and from genes that do not change (principles).

### The seven volumes
| Volume | What it is |
|------|------|
| `DNA.md` | the immutable gene — principles and process |
| `RNA.md` | the loading protocol — how the gene is read (budgeted, calibrated) |
| `SPEC.md` | the knowledge ontology — the complete narrative |
| `PLAN.md` | the current growth stage — **must-read at session start** |
| `GROWTH.md` | the growth record — rings, kept to the last three |
| `VISION.md` | the seed |
| `DEPRECATE.md` | death and retirement — and how a death is *verified* |

*We are borrowing the metaphor, not doing botany.*

**Protection is the railing of growth, not a wall** — [`docs/PROTECTION.md`](docs/PROTECTION.md).

---

## State is measured here, never stored

This repo holds **the rules themselves** — how a gate is designed, when a verdict may be
believed — so this file points at **methods first, assets second**. Every count below is a
**dated snapshot** and will rot; the commands will not. Where an earlier README printed
numbers, this one prints the command that replaces them:

| What you want to know | Run this command |
|-----------------------|------------------|
| the gate list (id · applies-to · inject · counter · timing) | `bash tools/validate.sh --index` |
| gate counts — total / hard / retired / active | `bash tools/validate.sh --index` (per-gate) · `bash tools/check-pool.sh` (pool-wide) |
| gate heartbeats — three lines per gate | `bash tools/validate.sh --probe-all` |
| full-pool consistency | `bash tools/check-pool.sh` |
| budget · usage · countdown · debts · replay coverage | the ecosystem repo's `tools/todo-ready.sh` (the report head is ecosystem-scoped — see the note below) |
| the whole local CI, verbatim | `bash tools/ci-local.sh` |

> **Where the report head lives.** `todo-ready.sh` is **ecosystem-scoped** (it reads all six repos
> plus the cross-repo register), so it lives in the ecosystem repo, **not here**: run it as
> run the ecosystem repo's `tools/todo-ready.sh` from that checkout (the path differs per machine; that is why
> it is written as words, not as a shell placeholder). Everything else in this table is in **this** repo's
> `tools/`. (An earlier draft of this README pointed at `tools/todo-ready.sh` here — it would have
> failed with "No such file" for a fresh adopter. Fixed 2026-10-12.)

*Snapshot 2026-10-12, already rotting: 30 ADRs · 22 hard · 3 retired ·
**active = hard ∧ ¬retired = 19** — of which **2 carry `replay-exempt`** (replay obligation covers 17)
and **1 is named-unprobeable**. Trust the commands.*

**Calibers are spelled out on purpose.** "Active" means `hard: true` ∧ `¬status: deprecated`.
Two further subsets matter and are **not** the same number: `replay-exempt` gates carry no replay
obligation; "named-unprobeable" gates cannot be probed at all. Printing one number and calling it
"active" is how three different counts of the same repo coexist.

---

## Start here — by question

| The question you are asking | Read this |
|-----------------------------|-----------|
| **Is this repo healthy, and how do I prove it?** | the commands above · [`docs/PROTECTION.md`](docs/PROTECTION.md) — gates are leaves, not walls; named · can go red · can die · bounded |
| **May I believe a verdict? (true green / false green …)** | [`docs/MULTIMETER.md`](docs/MULTIMETER.md) — the second axis (`verdict` × `validity`) |
| **May I believe a *gate*? (birth, blueprints, promotion)** | the birth law below · `bash tools/validate.sh --index` |
| **Why did a gate stay silent about an old violation?** | the timing:post blind spot below · `bash tools/check-pool.sh` |
| **May I believe a *report*?** | derived self-attestation below · the ecosystem repo's `tools/todo-ready.sh` |
| **What documents exist, and which answers my question?** | [`docs/INDEX.md`](docs/INDEX.md) — question-keyed; a gate forbids leaving any doc unlisted |
| **Where are the gates themselves?** | `decisions/` — see `decisions/INDEX.md` (generated; do not hand-edit) |
| **Where is the accounting for runs and probes?** | `ledger/` — append-only; corrections are new records; the replay census is tagged `census: true` |
| **Where is a gate that has gone fake diagnosed?** | [`docs/DNA-GATE-DIAGNOSIS.md`](docs/DNA-GATE-DIAGNOSIS.md) · [`docs/FINDING-2026-10-09-ledger-is-not-jsonl.md`](docs/FINDING-2026-10-09-ledger-is-not-jsonl.md) |
| **Across the ecosystem: what is known-broken?** | `helix-mind/docs/helixECO/KNOWN_ISSUES.md` — the single cross-repo register |
| **Across the ecosystem: how do I spot a lying criterion?** | `helix-mind/docs/helixECO/DIAGNOSIS-METHODS.md` — seven methods, slug-anchored |

---

## The one command

Run this after any change. It is the repo's signature move:

```bash
bash tools/validate.sh --probe-all     # every gate: baseline / injected / counter
bash tools/validate.sh --index         # the gate INDEX — run this BEFORE proposing a new gate
bash tools/ci-local.sh                 # replay the CI steps verbatim — run this BEFORE pushing
```

**`--index` answers "how do I avoid re-discovering what already exists."** It prints one line per gate
(id · `applies-to` · has `inject.sh` · has `counter.sh` · timing), **generated by the engine, not typed
by hand** — and a gate keeps it from drifting.

**`ci-local.sh` replays `.github/workflows/phyt.yml` step by step** — nine steps as of 2026-10-12
(the script enumerates them; the step names below are the ones this README can vouch for). Two
additions over the original five matter enough to name: a **standing baseline red fails the run,
by name** (a red that is "visible but doesn't count" is a specimen, not a pass), and the **whole
pool is scanned** — not only the files just written.

Three lines matter, and a reading without all three is incomplete:

| line | the question it answers |
| --- | --- |
| `baseline (un-injected)` | **is the repo compliant right now?** → red ⇒ the repo is ill |
| `injected RED` | **is the gate alive?** → this red is **manufactured by the fixture**, *not* the repo's illness |
| `counter held` | **is the criterion two-way falsifiable?** → a content-preserving edit must not change the verdict |

**A probe must report two worlds.** Reporting only the injected state makes a fixture's achievement look
like the repo's disease.

---

## The core idea: a verdict is not a boolean

`pass | block` cannot tell these four apart:

|  | **true** | **false** |
| --- | --- | --- |
| **green** | passed **and can be shown to fail** (a fixture crosses the threshold) | passed but **no fixture** — nobody ever proved it can go red |
| **red** | failed for a **nameable** reason (the criterion) | failed for **something else** (tool error / missing precondition / the same command answering differently) |

> 
> **`pass` alone is not reportable — it must be `pass + alive`.**
> **A green set with no fixtures is not green, it is UNMEASURED.**

Measured on the first real adopter: **79 "proven", of which 78 had no fixture**; and **8 runs in one
identical environment produced 6 distinct fingerprints** (`proven 53..79`, `red 2..10`, `held 1..31`)
— source: [`docs/MULTIMETER.md`](docs/MULTIMETER.md), §"同环境 8 次运行出现 6 种指纹".

**And measured on this repo, 2026-10-11:** the report-head generator had died mid-print
(`set -u`, unbound variable) for several rounds — the commit trail dates the interval
(`2944919` onward) — while every report still carried a hand-typed "self-check ✅". False green is not
a hypothesis — it happened to the authors, in the most-watched file of the repository. The fix is
structural, not moral: see **derived self-attestation** below.

Full treatment: [`docs/MULTIMETER.md`](docs/MULTIMETER.md).

---

## The birth law — three edges

A gate is born only when all three are shown. Two edges were always the law; the third was added
2026-10-11, after two gates were born defective in complementary ways.

| edge | proof | the question it answers |
| --- | --- | --- |
| **can go red** | `fixtures/<id>/inject.sh` goes RED | does failure exist at all? |
| **won't go red wrongly** | `fixtures/<id>/counter.sh` stays GREEN under a content-preserving edit | does it fail *only* for the named reason? |
| **can go green** | a compliant state verifies GREEN | is satisfaction *reachable* — or was the gate born dead? |

The two wounds that taught the third edge, both 2026-10-11: one criterion born **unable to go red**
(a recopy monitor whose extraction was locale-sensitive — no fixture could cross the threshold), and
one born **unable to go green** (a replay-coverage window of 10 records against 19+ hard gates —
mathematically unsatisfiable, red since birth while CI looked away).

A gate that fails any edge is `hard: false` — a **blueprint, honestly labeled**, with a registered
promotion criterion. **`unproven ≠ alive`**, and an unproven check must say so **in its own CI
output**, not in the report prose. A green that has never said "no" is a claim, not a reading.

**First application — supersede is a two-halves action.** Retiring an ADR means the new one carries
`supersedes:` **and** the old one flips to `status: deprecated`. Half-actions leave dead gates
running. `ADR-20261011-supersede-must-be-paired` enforces both directions — and was the first gate
born with all three edges, using the live repository as its green-side proof.

> 
> **Honest scope note.** The pairing gate's `applies-to` covers `decisions/` ADRs. This README's own
> frontmatter (`id` / `supersedes` / `revisit-on`) follows the **same convention** but is
> **hand-written metadata in a layer no gate covers** — unlike a gate, it stores state in a file that
> is not re-derived. Its guard today is **the archive plus this note**: the superseded half
> (`DOC-README-v2`) is retained at [`docs/archive/DOC-README-v1.md`](docs/archive/DOC-README-v1.md) with
> `status: deprecated`, so the pairing is **executable, not promised**; extending the pairing gate's
> `applies-to` to docs is a registered debt.

---

## The timing:post blind spot — and the full-pool scan

A `timing: post` gate judges **the file being written**. It never re-judges the already-existing pool.
A violation that predates a gate's birth is invisible to it forever.

Measured: a broken supersede pair stood across three commits while the pairing gate was present
and silent — the two files involved were simply never written again.

`tools/check-pool.sh` (ci-local step **4b**) is the patch: it feeds the **whole pool** to the engine
in one pass, catching violations that predate the gates. Its own status, by the birth law above:
**unproven** — the red-side fixture has not been made to fire yet. It runs, it reports consistency,
and until its fixture fires it does not count as a green light. The promotion criterion is registered.

*(A related silent disease, found the same week: a count assembled by `xargs` over ~30 files
overran the command line, the tool errored, and the reading printed a plausible **0** — "active hard
gates: 0". A tool error that leaves a reasonable-looking number behind is worse than a crash.)*

---

## Derived self-attestation — the report that checks itself

Since the 2026-10-11 incident (a dead generator covered by hand-typed ✅), the self-check line is
**computed, not typed**: the generator captures its own output and greps each required section for
existence — a section that did not print yields `✗`, and the head says so **in the head itself**.

The first run caught a genuinely missing section that hand-typing had covered for several rounds.

> 
> **A green with no receipt is a claim.** Absence must be able to say its own name — a report that
> cannot print "I am incomplete" is not reporting, it is attesting.

---

## The review stack — four layers

No single layer catches everything. Measured: a silently-reverted constitutional fix was invisible
to the executor's own self-check, caught by a second agent reading from a non-default perspective,
and confirmed only by machine commands (`git show`, `grep`).

| layer | role | what it caught (measured) |
| --- | --- | --- |
| self-check | the executor verifies its own work | in-flight errors — but not its own blind spots |
| second agent, non-default perspective | an external agent audits the same ground from a different lens | the silent revert; ledger-wide holes |
| external reviewer | an outside synthesis pass over both | evaporated follow-ups; memory-level drift |
| machine commands | `git` / `grep` / probes — the final court | ground truth when tools and reports disagree |

The stack is the value, not any layer's cleverness.

---

## Replay by revisit period — with a census

The old rule ("the last 10 replay records must cover every hard gate") was **unsatisfiable on the
day it was born** — 10 records cannot cover 19+ gates. It has been replaced:

- every hard gate must be replayed at least once **within its own `revisit-on` period**;
- a one-time **census** replayed every gate once (tagged `census: true` in the ledger), so each
  gate's clock starts from a real reading rather than an assumption;
- invariants (e.g. "DEPRECATE must exist", "DNA is immutable") are exempt — their aliveness is
  proven by every CI run, and a replay obligation does not fit them.

Enforcement status, by the birth law: the gate is a **blueprint** (`hard: false`) — its fixture has
not been made to fire. Until promotion, the obligation is carried by a **manual ritual at
ring-close** (the single-gate probe is run by hand), and the report head prints the coverage reading.

---

## Frozen bodies, and the pre-commit hook

**`tools/frozen-body.sh --write` refuses silent rewrites.** Rebasing a frozen document requires
`--rebaseline "<reason>"` and leaves a named trace. It has already refused its own author once —
which is the point.

**The pre-commit hook** scans staged text with the step-4 rules and rejects the commit on red;
`PHYT_WIP=1` skips the scan but keeps regeneration. `--no-verify` is the shotgun — it kills
regeneration too; don't. CI remains the only real gate; the hook is convenience, not defense.

*(Registered limitation: the scan must target the **staged snapshot**, not the working tree.)*

---

## How to add a gate

**A description is not guidance.** Four steps, in order — each exists because skipping it cost
someone real time (recorded in each ADR's `origin:` field).

### ① Look first

before proposing anything:

```
bash tools/validate.sh --index     # one line per gate: id · applies-to · inject · counter · timing
cat PLAN.md                        # the current stage — what is already done
```

If what you are about to build is already in that table, you are about to duplicate it.

*(Measured 2026-10-09: an adopter "discovered" that ports needed a gate — a port-table test already
existed; and "discovered" that think / say / do needed separating — the channels, the gate contract
and the I7 rule already existed.)*

### ② Write

a gate is four pieces, never fewer:

| # | file | why |
| --- | --- | --- |
| 1 | `decisions/ADR-<date>-<slug>.md` | a gate is an **attribute of an ADR**, not a separate layer — H1 first line, then front-matter (`id` / `seq` / `status` / `hard` / `applies-to` / `redtest` / `revisit-on` / `check`) |
| 2 | `fixtures/<gate-id>/inject.sh` | proves it **can** go red |
| 3 | `fixtures/<gate-id>/counter.sh` | proves it does **not** go red when nothing changed |
| 4 | regenerate + refresh baseline | `bash tools/validate.sh --index > decisions/INDEX.md` · `bash tools/check-baseline.sh --update` |

**All three edges of the birth law must be shown — including that a compliant state goes green.**

**If your gate supersedes another, that is a two-halves action**: the pairing gate will demand the
old ADR's `status: deprecated` in the same breath.

### ③ Verify

three lines: `bash tools/validate.sh --probe-all` (and, for pool-wide criteria,
`bash tools/check-pool.sh`).

### ④ Push

replay CI, do not assume: `bash tools/ci-local.sh`.

> 
> **Anything you cannot run, you cannot claim.** A step that is declared but missing is a **marked
> skip** (`exit 4`), never a silent pass.

---

## Status — the honesty boundary

| Item | State (run the command; do not trust this cell) |
| --- | --- |
| Gate mechanism | active gates two-way falsifiable — `bash tools/validate.sh --probe-all` |
| Pool consistency | `bash tools/check-pool.sh` — runs, reports consistency, **unproven** (fixture pending) |
| Replay-per-revisit | criterion in force; enforcement gate is a **blueprint** — manual ritual carries it |
| Recopy monitor | **blueprint** — fixture could not cross the threshold; promotion test registered |
| Report head | generated; self-attestation **derived** (each ✅ computed from the head's own output) |
| Inner-ring rotation | ⚠️ 0/0 — this repo itself has zero `kind: task` production tasks |
| Physical interception | ⚠️ payload-level only, **never observed in a real agent task** |
| `--cull` | judge in place, **no defendant yet** |

> 
> **Complete machinery ≠ production-verified.** Every self-check here is green, and **this system
> has never turned once in production.** The first real project will produce the real numbers.

**Evidence tags.** Every conclusion in [`docs/PROTECTION.md`](docs/PROTECTION.md) is tagged
**measured / research-backed / unverified**. *Unverified items must not be written into DNA.*

---

## Adopt it

README's promise: *"Every project adopting this methodology lands the zero-cost checklist at its
first public milestone."* V2 makes that sentence **executable** — formerly manual checkmarks, now
`cp -r` plus CI.

```
# 1. Copy the skeleton (v2: the repo root IS the template)
git clone git@github.com:Jasonmilk/phyt-DNA.git /tmp/phyt-dna
cp -r /tmp/phyt-dna/{DNA.md,RNA.md,SPEC.md,PLAN.md,GROWTH.md,VISION.md,DEPRECATE.md,decisions,ledger,fixtures,tools} <your-project>/

# 2. Write your first gate (see examples/ADR-EXAMPLE.md; no engine change needed)
cp examples/ADR-EXAMPLE.md <your-project>/decisions/ADR-<date>-<your-first-gate>.md

# 3. Turn on CI (the pre-commit hook is optional convenience; CI is the gate)
cp examples/phyt.yml <your-project>/.github/workflows/
cd <your-project> && ./tools/check-baseline.sh --update && git add tools/baseline.sha256 && git commit
```

**The first CI run is necessarily RED** (missing asset baseline) — land the baseline to go green;
do not bypass it. After that every push must pass every step.

**Optional hook (real-time interception).** Lives in `examples/claude-code/`; copy it in only if you
want it. **Not claimed verified:** assembly is verified, interception is payload-level only
(`Edit DNA.md` → exit 2) and has **never happened in a real agent task**. Run a real task to verify
it yourself.

**W0 rule: zero scripts at first.** Do one real task by hand and log it. Writing scripts before you
have real data is guessing which gates deserve to exist.

---

## Directory structure

```
DNA.md          immutable gene (10 native + 6 derived laws)
RNA.md          loading protocol (budgeted, calibrated — see the threshold ADR, landed at 10db511)
SPEC.md         knowledge ontology
PLAN.md         current growth stage — MUST READ at session start
GROWTH.md       growth rings (keep last 3)
VISION.md       the seed
DEPRECATE.md    death and retirement
decisions/      single source of truth — gates live here (INDEX.md is generated, do not hand-edit)
ledger/         append-only accounting (corrections are new records; census tagged)
fixtures/       per-gate: inject.sh (must go RED) + counter.sh (must NOT) — three edges at birth
tools/          validate.sh · ci-local.sh · check-baseline.sh
                check-pool.sh (full-pool consistency) · frozen-body.sh (refuses silent rewrites)
                (the report head `todo-ready.sh` is ecosystem-scoped — it lives in the ecosystem repo)
docs/           MULTIMETER · PROTECTION · REPLAY-MISSING · DNA-GATE-DIAGNOSIS · FINDING-* · INDEX · archive/
examples/       copy-paste ready ADR, CI workflow, claude-code/ hook package
```

**Loading protocol.** Total load is budgeted at **≤320 lines** — calibrated at the first premiere
2026-10-11 (the threshold ADR, landed at commit `10db511`, is the source of truth; the report head
prints the live reading). `PLAN.md` is must-read: a new session loads it first to confirm the
current stage, so effort is not spent on finished stages. Every other volume is loaded **by task
keyword** — never all at once.

---

## What's new in V2

V1 was a document template. **V2 adds the parts that were proven by actually running it.**
Evolution goes by **diff, not rewrite** — and the debt column hides nothing.

|  | v1 | v2 | Debt (unfinished — not hidden) |
| --- | --- | --- | --- |
| Gates | prose in README (no id, no check, cannot die) | **`hard: true` on an ADR** (id, `check:`, heartbeat, can die) | — |
| Check logic | hardcoded in the engine | **the ADR carries its own `check:`** (zero hardcoded gates) | — |
| Timing | not distinguished | **`timing: pre\|post`** | **post blind spot**: pre-existing violations invisible — patched by `check-pool.sh` (step 4b), whose own fixture is still pending |
| Verification | none | **four-layer** review stack (self · second agent · external · machine) | — |
| CI | none | steps + red-test; a **standing baseline red fails by name** | step-0 generator assertion: **landed** (`check-report-head.sh`, CI step ⓪·4) |
| Birth law | — | two edges (inject + counter) | → **three edges** (+ green-able), 2026-10-11 |
| Supersede | convention | **pairing gate** — a two-halves action, both directions | `applies-to` covers `decisions/` only; docs-level pairing is **backed by an archive**, gate extension registered |
| Replay | window rule (born unsatisfiable) | per-`revisit-on` periods + one-time **census** (`census: true`) | enforcement gate is a blueprint |
| Report | hand-typed self-check ✅ | **derived self-attestation** — ✅/✗ computed from the generator's own output | — |
| Frozen bodies | — | `frozen-body.sh` refuses silent rewrites (`--rebaseline` named) | — |
| Hook interception | none | `.claude/` hook + **pre-commit staged scan** (`PHYT_WIP` escape) | **not observed in a real agent task** (T2); hook must target the staged snapshot |
| `--cull` | law only in conversation | judge in place (`validate.sh --cull`, report-only) | **no enforcement yet**: cold-store needs human approval |
| Growth-ring format | four totals only | three numbers + three categories; the report head adds usage / replay coverage / recent retirements | trend / distribution / override-by-reason fields (T8) |
| 60-minute parameter | hardcoded | calibratable field | **recalibrate after one year** (revisit-on 2027-04-09) |

---

## Links

- Docs by question: [`docs/INDEX.md`](docs/INDEX.md) · gates: [`decisions/INDEX.md`](decisions/INDEX.md)
- The full protection spec: [`docs/PROTECTION.md`](docs/PROTECTION.md)
- Cross-repo register: `helix-mind/docs/helixECO/KNOWN_ISSUES.md` · ecosystem entry point: `helix-mind/docs/helixECO/HANDOFF.md`

## Governed documents at the root

The root of this repo **is** the template an adopter copies. These files are **governed**: a gate checks they exist,
are listed in [`docs/INDEX.md`](docs/INDEX.md), and are **reachable from this README** (the second hop).

| The question you are asking | Read this |
|---|---|
| Where do I start, in Chinese? | [`README.zh-CN.md`](README.zh-CN.md) |
| Where is this going, and what is out of bounds? | [`VISION.md`](VISION.md) |
| Which genes may never be deleted? | [`DNA.md`](DNA.md) |
| What does the spec look like? | [`SPEC.md`](SPEC.md) |
| What is the working protocol? | [`RNA.md`](RNA.md) |
| What stage are we at, and what is left? | [`PLAN.md`](PLAN.md) |
| How did it grow? | [`GROWTH.md`](GROWTH.md) |
| How does something die here? | [`DEPRECATE.md`](DEPRECATE.md) |
| Where is this repo, and what does it *not* do? | [`position.md`](position.md) |

### Wire the pre-commit hook (a fresh clone does not get it)

Hooks live in `tools/hooks/`, **not** in `.git/hooks/`, and `core.hooksPath` is **per-clone** — so a fresh clone
runs **no** hook at all (measured 2026-10-12). One line fixes it:

```bash
git config core.hooksPath tools/hooks    # 启用**全部**核心钩子：pre-commit（快层）+ pre-push（慢层）
```

To bypass the scan on purpose (mid-state commits), use an **environment variable** — not a `[wip]` tag in the message:
git cannot see the pending message inside `pre-commit`, so a tag would only reflect the *previous* commit (measured).

```bash
PHYT_WIP=1 git commit -m "…"
```
```bash
git config core.hooksPath tools/hooks    # 启用**全部**核心钩子：pre-commit（快层）+ pre-push（慢层）
```

### What the two hooks do (adopter pack · 2026-10-13)

| hook | layer | runs | when |
|---|---|---|---|
| `pre-commit` | **fast** | `0/1 manifest+baseline` · `2 spec-lint` · `3b escape-ledger` · **`4 whole-repo scan (always)`** | every commit |
| `pre-push` | **slow** | **full** `ci-local` = fast + `3 heartbeat` · `5 spec-lint-red-able` · `5a hook_test` | every push · CI · manual |

**Not enabled ⇒ nothing runs**: `core.hooksPath` is **per-clone** (measured 2026-10-13) — run the one-liner above, or
`bash tools/ci-local.sh` manually. Layers are **enforcement by touched surface**, not just time saving:
`tools/ .github/ examples/ fixtures/` ⇒ the fast layer escalates to **full**.

### ★ The **pre face** has exactly one entry (2026-10-13)

| face | gates | only entry | covered by |
|---|---|---|---|
| **post** (file content) | 22 `hard` gates | `tools/ci-local.sh` step 4 (per-file, `--timing post`) | pre-commit hook · **CI** (so CI is real) |
| **pre** (tool calls: `file_path`/`command`) | 2 `hard` gates | `examples/claude-code/hooks/pretooluse-gate.sh` | **nothing else** |

**Why this matters**: `git commit` via **bash / `git apply` / merge / hand-edit** never passes the execute gate ⇒ the pre face is *silent* there.
A **fresh clone has no `core.hooksPath`** (measured) ⇒ the adopter's default is *no gate at all*. See `DEBTS.md` `d-phyt-pre-gap-a/b/c`.
**Restore-command for the execute gate's own receipts** (not borrowed from `hook_test.sh`):
```bash
printf '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/x"}}' | bash examples/claude-code/hooks/pretooluse-gate.sh; echo "rc=$? (expect 2)"
printf '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | bash examples/claude-code/hooks/pretooluse-gate.sh; echo "rc=$? (expect 2)"
printf '{"tool_name":"Write","bad":' | bash examples/claude-code/hooks/pretooluse-gate.sh; echo "rc=$? (expect 2, fail-closed)"
```
