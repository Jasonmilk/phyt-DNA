# phyt-DNA — Self-Growing Project Methodology

> **Version**: v1.0
> **Date**: 2026-08-29
> **Status**: Finalized (methodology anchor project)
> **Nature**: Generic self-growing project methodology template and authoritative source. All projects adopting this methodology anchor to it, avoiding version drift and ambiguity.
> **Philosophy**: A plant is not designed — it grows from a seed, spontaneously, continuously, slowly, according to environmental conditions and intrinsic genes.
>
> **中文版 (Chinese Version)**: [README.zh-CN.md](./README.zh-CN.md)

---

## A Seed's Confession

**Plants are not built; they grow.**

Traditional software methodology treats a project as a machine — draw a blueprint, assemble parts, debug, run. But living projects are not like that. They are more like plants: from a seed (core vision), driven by environment (user needs, technical constraints, ecosystem change) and intrinsic genes (immutable principles), they grow spontaneously, continuously, slowly.

**phyt-DNA borrows plant metaphors to describe this methodology — we are not doing botany.** DNA, RNA are metaphors, not biology class. DNA is the immutable gene (principles and processes), RNA is the loading protocol (how to read the gene and guide growth), SPEC is the knowledge ontology (complete narrative), PLAN is the current growth stage, GROWTH is the growth record, DEPRECATE is death and retirement, archive is historical sediment.

**phyt-DNA makes projects grow like plants, not get built like machines.**

---

## Methodology Core Components (10-piece set)

| # | Component | Role | Analogy | Size constraint |
|---|---|---|---|---|
| 1 | **VISION.md** | Root index: what the project "is" and "why", atomic principles, ecological niche | Seed's embryo | ~100 lines |
| 2 | **DNA.md** | Constitution: immutable principles + self-growing process + anti-rot ironclad rules | Gene | ~80 lines |
| 3 | **RNA.md** | Loading protocol: three-layer loading + AI collaboration ironclad rules + major-version update SOP | Gene expression mechanism | ~100 lines |
| 4 | **SPEC.md** | Complete narrative: "A Seed's Confession", knowledge ontology | Plant's full form | unlimited |
| 5 | **spec/** | Spec volumes: philosophy/architecture/contract/safety/position | Detailed structure of each organ | on demand |
| 6 | **PLAN.md** | Navigation board: current stage + next-stage preview + stage overview | Current growing season | ≤150 lines |
| 7 | **GROWTH.md** | Growth record: last 3 health snapshots | Tree rings | ≤3 entries |
| 8 | **DEPRECATE.md** | Retirement record: features that are dying | Dead leaves | ≤30 lines |
| 9 | **decisions/** | ADR: architecture decision records (why A was chosen, what was given up) | Growth traces | on demand |
| 10 | **archive/** | Historical archive: growth/ + deprecated/, never deleted | Organic matter in soil | unlimited |

---

## Protection Chapter (the railing of growth)

Protection is the railing of growth, not a wall. Methodology protection spec: [docs/PROTECTION.md](docs/PROTECTION.md)

- **Big-tech practices distilled** (Google/Apple, publicly verifiable): open source = automatic defensive publication, Apache 2.0 patent terms, specs public + services proprietary, trademark is a long-term asset, rank by threat
- **Five protection principles** (philosophy-trimmed): on-demand / physical facts first / extreme efficiency / determinism / decoupling
- **Zero-cost checklist**: LICENSE (Apache 2.0) / NOTICE / prior-art.md / README license section / CONTRIBUTING declaration / SECURITY.md (on demand)
- **Prior Art as Code spec**: same-repo same-commit, enabling, evidence path, discoverable, modular
- **Explicit non-actions**: IP.com paid publication / formal patent filing / OIN alliance / trademark registration (all agenda-gated, only when real commercial need arises)

Every project adopting this methodology lands the zero-cost checklist at its first public milestone.

## Logical Closed Loop (Growth Metabolism)

```
DNA (constitution, immutable)
  ↓ load
SPEC + spec/ (knowledge ontology, complete narrative)
  ↓ guide
PLAN (current growth stage navigation board)
  ↓ execute
Code implementation + test verification
  ↓ stage complete
GROWTH (growth record, last 3)
  ↓ feature retirement
DEPRECATE (death and retirement)
  ↓ archive
archive/ (historical archive, never deleted)
  ↓ trace back
DNA self-check (principles violated? need evolution?)
```

**Closed-loop key nodes:**

1. **PLAN → GROWTH flow**: after a stage completes, detailed content is removed from PLAN, summary written into GROWTH. PLAN holds only current stage + next preview + stage overview.
2. **GROWTH → archive flow**: when GROWTH exceeds 3 entries, oldest moves into `archive/growth/`.
3. **DEPRECATE → archive flow**: after a feature fully retires, it moves into `archive/deprecated/`.
4. **Decision precedes code**: architecture/interface changes must create an ADR first (D-layer frozen), then change code, then sync facade documents.
5. **DNA is immutable**: DNA.md is the constitution; AI must not modify it (may propose; humans hold final authority). Modifying DNA changes identity, and the old identity's trust does not transfer.

---

## RNA Three-Layer Loading Protocol

### Layer 1: Active files (new session must-read, load in order)

| Order | File | Duty |
|---|---|---|
| 1 | `docs/DNA.md` | Constitution: immutable principles |
| 2 | `docs/RNA.md` | Navigation: this file |
| 3 | `docs/PLAN.md` | **Navigation board: current stage (must-read)** |
| 4 | `docs/GROWTH.md` | Growth: last 3 health snapshots |
| 5 | `docs/DEPRECATE.md` | Dying: features being retired |

**Total load**: ≤280 lines, ≤4500 tokens. PLAN.md is must-read — a new session must load PLAN first to confirm the current stage, avoiding wasted effort on completed stages.

### Layer 2: Whitepaper volumes (load by task)

Match volumes by task keywords. Load only volumes relevant to the current task; never load everything at once.

| Volume | Path | Anchored principles |
|---|---|---|
| Ecosystem positioning | `docs/spec/position.md` | independent + ecosystem-native first |
| Philosophy axioms | `docs/spec/philosophy.md` | all axioms |
| Core architecture | `docs/spec/architecture.md` | decoupling / declaration-execution separation |
| Transport & contract | `docs/spec/contract.md` | multi-transport equality / credential label flow |
| Safety design | `docs/spec/safety.md` | sandbox-as-contract / integrity verification / redaction |

### Layer 3: Historical archaeology (load only on human request)

| Archive | Path | Load trigger |
|---|---|---|
| Growth history | `docs/archive/growth/` | reviewing evolution |
| Death history | `docs/archive/deprecated/` | archaeology of old interfaces |
| Decision history | `docs/decisions/` | tracing "why A was chosen" |
| Design docs | `docs/design/` | tracing degradation chains / safety design |

---

## AI Collaboration Ironclad Rules (9 general + N project-specific)

### General rules (apply to all projects)

| # | Rule | Description |
|---|---|---|
| 1 | **Attention anchoring** | After loading DNA.md, judge the 1-2 most relevant principles for the current task and focus primary attention on them |
| 2 | **Doubter** | Check whether the solution violates DNA principles; alarm when it does. Especially watch: plaintext credentials introduced? hardcoded thresholds? core-layer purity broken? |
| 3 | **No constitutional amendment** | Must not modify DNA.md (may propose; humans hold final authority) |
| 4 | **Permission check** | Before architecture/interface changes, confirm whether the current autonomy level permits it. Core-layer changes need extra review |
| 5 | **Decision interception** | On architecture/interface changes, prompt creating `docs/decisions/ADR-<4-digit>-<title>.md`. Reference as `ADR-<number>`; filename and reference must match |
| 6 | **Atomic refactor** | When changing function signatures, list all call sites; fix ≤5 in this round, generate a script for >5 |
| 7 | **Kill magic** | No hardcoded thresholds; everything goes through config |
| 8 | **Epistemological spiral** | Understand "append-only, no modification" is not simple accumulation — via `CORRECTS` / `REFINES` / `DOUBTS` dialectics, spiral upward on the timeline |
| 9 | **Project-specific rules** | Each project defines its own ironclad rules in DNA.md (e.g., credential red lines, sandbox boundaries) |

### ADR naming convention

- Filename: `ADR-<4-digit>-<title>.md` (e.g., `ADR-0001-rust-rebuild.md`)
- Reference: `ADR-<number>` (e.g., `ADR-0001`)
- Numbering: 4 digits, sequential ascending
- Status: two states (Draft / Active); once Active cannot be overwritten, only Superseded
- Commit message association: `(ADR-NNNN §Tx)`

---

## Major-Version Update SOP

### Before update
- [ ] Confirm targets: which volumes to change? (see spec/ volume table)
- [ ] Confirm boundary: which DNA principle is touched?
- [ ] Confirm legacy: does `DEPRECATE.md` have items to bury?
- [ ] Branch: `git checkout -b feature/vX.X-<summary>`

### During update
- [ ] Modify corresponding `docs/spec/` volumes (only relevant volumes)
- [ ] Code implementation
- [ ] DNA principle self-check (core principles violated? project-specific rules held?)
- [ ] Project-specific acceptance checks

### After update
- [ ] Tests pass (all green + 0 warnings)
- [ ] Write `GROWTH.md` (record this growth health)
- [ ] Write ADR (`docs/decisions/`, if a hard decision was made)
- [ ] Write `DEPRECATE.md` (if features retired)
- [ ] **Update `PLAN.md` (stage flow: remove completed-stage details, switch to next stage; keep three-part form: current stage + next preview + stage overview; ≤150 lines)**
- [ ] Archive: GROWTH > 3 entries? move into `docs/archive/growth/`
- [ ] Archive: DEPRECATE buried? move into `docs/archive/deprecated/`
- [ ] Commit message includes ADR association: `(ADR-NNNN §Tx)`
- [ ] Merge branch + delete feature branch

---

## Anti-Rot Ironclad Rules (5)

| # | Rule | Description |
|---|---|---|
| 1 | **Version source of truth is spec/code** | README/facade annotations must align; prevent version drift |
| 2 | **Frozen contracts not silently modified** | Extensions go through Append-Only / reserved regions |
| 3 | **Change order: ADR first (D-layer frozen) → code → facade sync** | Decision precedes code |
| 4 | **Growth records keep last 3, archive beyond** | History never deleted, loaded on demand |
| 5 | **Human confirmation before commit** | No auto-commits |

---

## Quick Start: Using phyt-DNA in a New Project

### 1. Copy the template

```bash
# clone the methodology repository
git clone https://github.com/Jasonmilk/phyt-DNA.git

# copy the template into your project
cp -r phyt-DNA/template/* /path/to/your-project/docs/
cp -r phyt-DNA/template/.gitkeep /path/to/your-project/docs/decisions/
cp -r phyt-DNA/template/.gitkeep /path/to/your-project/docs/archive/growth/
cp -r phyt-DNA/template/.gitkeep /path/to/your-project/docs/archive/deprecated/
```

### 2. Initialize core documents

Fill in this order (replace metadata at each file's top with your project info):

1. **VISION.md** — write clearly what the project "is" and "why"; define atomic principles (5-10)
2. **DNA.md** — distill immutable principles from VISION, define project-specific ironclad rules, confirm anti-rot rules
3. **RNA.md** — confirm three-layer loading protocol, confirm AI collaboration rules (9 general + project-specific), confirm major-version update SOP
4. **SPEC.md** — write the complete narrative ("A Seed's Confession")
5. **spec/** — create volumes as the project needs (philosophy/architecture/contract/safety/position)
6. **PLAN.md** — define P0/P1/P2... stages, set current stage to P0
7. **GROWTH.md** — empty template, waiting for the first growth record
8. **DEPRECATE.md** — empty template, waiting for the first retirement record

### 3. Start growing

- After each stage completes, run the post-update checklist per the Major-Version Update SOP
- PLAN.md stage flow is the key to the closed loop — completed-stage details must be removed, summaries written into GROWTH
- Architecture/interface changes must create an ADR first

---

## Template Directory Structure

```
template/
├── VISION.md              # root index: vision + atomic principles + ecological niche
├── DNA.md                 # constitution: immutable principles + processes + anti-rot rules
├── RNA.md                 # loading protocol: three-layer loading + AI rules + major-version SOP
├── SPEC.md                # complete narrative: knowledge ontology
├── PLAN.md                # navigation board: current stage + next preview + stage overview
├── GROWTH.md              # growth record: last 3 health snapshots
├── DEPRECATE.md           # retirement record: features that are dying
├── spec/                  # spec volumes
│   ├── philosophy.md      # philosophy axioms
│   ├── architecture.md    # core architecture
│   ├── contract.md        # transport & contract
│   ├── safety.md          # safety design
│   └── position.md        # ecosystem positioning
├── decisions/             # ADR architecture decision records
│   └── ADR-0001-template.md
└── archive/               # historical archive (never deleted)
    ├── growth/            # growth history
    └── deprecated/        # death history
```

---

## Methodology Origins and Evolution

phyt-DNA methodology was distilled, verified and closed-looped from the practice of the following projects:

| Project | Role | Methodology status |
|---|---|---|
| **Helix-Mind** | birthplace (memory/cognition core) | methodology origin, Python-stage practice |
| **Anaphase-Helix** | migration reference (execution body) | full migration, Rust rebuild verification |
| **Helix-Tentacle** | latest migration (information tentacle/weapon forge) | full migration + closed-loop completion (PLAN stage flow SOP, ADR naming convention) |
| **CI-144 / BIND-19** | protocol family practice | "one authority, many presentations" architecture verification |

**Key closed-loop completion history:**
- v1.0 (2026-08-29): distilled from the practice of Helix-Mind/Anaphase-Helix/Helix-Tentacle, consolidated as an independent methodology anchor project. Completed the PLAN.md stage-flow SOP (the previous SOP only required GROWTH/ADR/DEPRECATE, not PLAN stage flow, creating knowledge-rot risk). Completed the ADR naming convention (filename and reference must match).

---

## Design Inspiration

phyt-DNA is an independent methodology, but its design philosophy is inspired by the following mature practices:

| Mature practice | Inspiration |
|---|---|
| **Plant growth biology** | seed → gene expression → environmental adaptation → growth → death → organic matter returning to soil, the full lifecycle |
| **RFC document series** | versioning, freezing, evolution of spec documents |
| **OpenSSL documentation policy** | code and docs reviewed in the same PR, never separated |
| **ADR (Architecture Decision Records)** | recording the "why" and "what was given up" of architecture decisions |
| **Monorepo documentation governance** | document lifecycle management (active/archived/retired) |

> "Inspired by" means: we learned the design ideas, implemented independently. Ideas are not copyrightable; this is open-source etiquette, not a legal obligation.

---

## One-Sentence Summary

> **phyt-DNA makes projects grow like plants: from the seed (VISION), guided by the gene (DNA), expressed through the loading protocol (RNA), unfolded in the knowledge ontology (SPEC), growing by stage navigation (PLAN), leaving tree rings (GROWTH), retiring dead leaves (DEPRECATE), organic matter returning to soil (archive), decision traces traceable (ADR). Anti-rot ironclad rules keep knowledge from decaying; the logical closed loop keeps growth from drifting.**

---

*End of "phyt-DNA Methodology" v1.0.*
