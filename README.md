# dialectics.cue

A formal engine for structured disagreement resolution, expressed in [CUE](https://cuelang.org/).

Protocols are schemas that AI agents execute and CUE can validate. Each protocol accepts structured input, runs a defined reasoning cycle, and produces a typed output — a canonical form, a verdict, a ranked priority, a validated observation. The outputs are composable: one protocol's finding can gate or seed the next.

---

## Layer Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  GOVERNANCE LAYER                                                   │
│  routing · recording                                                │
├─────────────────────────────────────────────────────────────────────┤
│  PROTOCOL LAYER                                                     │
│  domain-specific instantiations of the dialectic                   │
├─────────────────────────────────────────────────────────────────────┤
│  DIALECTIC LAYER  (dialectics.cue)                                  │
│  rebuttal · challenge · derivation · obligation · revision          │
└─────────────────────────────────────────────────────────────────────┘
```

**`dialectics.cue`** is the kernel. It defines the shared primitives every adversarial protocol uses — the rebuttal, the challenge, the survivor derivation, the obligation gate, the revision loop. It contains zero domain-specific knowledge.

**Protocols** instantiate those primitives for a specific question domain.

**Governance** handles routing (which protocol to run) and recording (projecting completed runs into queryable records). These are type operations, not adjudications.

---

## Protocols

### Adversarial — generate → pressure → survive → adopt

| Protocol | Domain | Core Question |
|----------|--------|---------------|
| **CFFP** | Formalization | What is the right formal structure? |
| **CDP**  | Decomposition | Is this one thing or two? |
| **CBP**  | Meaning | What does this term actually mean? |
| **HEP**  | Causation | Why did this happen? |
| **ATP**  | Analogy / Transfer | Is this structural similarity real and importable? |
| **EMP**  | Emergence | What behaviors appear at the seams that no part predicts? |

### Evaluative — subject × criteria → verdict

| Protocol | Domain | Core Question |
|----------|--------|---------------|
| **AAP**  | Assumption | What is this argument standing on? |
| **IFA**  | Fidelity | Does the implementation match the spec? |
| **RCP**  | Reconciliation | Do these outputs agree with each other? |
| **CGP**  | Governance | Is this canonical form still fit for purpose? |
| **PTP**  | Prioritization | Given finite resources, which path first? |
| **OVP**  | Observation | Is this phenomenon real as described? |

### Exploratory — personas → rounds → map

| Protocol | Domain | Core Question |
|----------|--------|---------------|
| **ADP**  | Exploration | What is the space of possibilities? |

---

## Domain Coverage

```
                        BEFORE        DURING         AFTER
                     (pre-formal)   (formalizing)  (post-canonical)
                    ┌──────────────┬──────────────┬──────────────┐
  What exists?      │  OVP         │              │  IFA         │
                    │  observation │              │  fidelity    │
                    ├──────────────┼──────────────┼──────────────┤
  What is it?       │  CBP         │  CFFP        │  CGP         │
                    │  meaning     │  formalize   │  governance  │
                    ├──────────────┼──────────────┼──────────────┤
  Is it one thing?  │              │  CDP         │              │
                    │              │  decompose   │              │
                    ├──────────────┼──────────────┼──────────────┤
  Why?              │  HEP         │              │              │
                    │  causation   │              │              │
                    ├──────────────┼──────────────┼──────────────┤
  What could it be? │  ADP         │  ATP         │  EMP         │
                    │  explore     │  transfer    │  emergence   │
                    ├──────────────┼──────────────┼──────────────┤
  How fragile?      │  AAP         │              │              │
                    │  assumptions │              │              │
                    ├──────────────┼──────────────┼──────────────┤
  Which first?      │  PTP         │              │              │
                    │  prioritize  │              │              │
                    ├──────────────┼──────────────┼──────────────┤
  Do they agree?    │              │              │  RCP         │
                    │              │              │  consistency │
                    └──────────────┴──────────────┴──────────────┘

  Governance:  Routing (entry)                    Recording (exit)
```

---

## Protocol Dependencies

```
            ┌─── Routing ───┐
            │                │
            ▼                ▼
  OVP ──→ HEP         ADP ──→ CFFP ──→ IFA
                        │       │
                        │       ▼
           CBP ─────────┤      CDP ──→ CFFP (per part)
                        │       │
           ATP ─────────┘       ▼
                              EMP
            PTP (any stage)
            AAP (any stage)

  All completed runs ──→ Recording
  Multiple runs ──→ RCP
  Canonical forms ──→ CGP
```

---

## File Structure

```
dialectics.cue                    — kernel: shared primitives for all protocols

protocols/
  adversarial/
    cffp.cue                      — Constraint-First Formalization Protocol
    cdp.cue                       — Construct Decomposition Protocol
    cbp.cue                       — Concept Boundary Protocol
    hep.cue                       — Hypothesis Elimination Protocol
    atp.cue                       — Analogy Transfer Protocol
    emp.cue                       — Emergence Mapping Protocol
  evaluative/
    aap.cue                       — Assumption Audit Protocol
    ifa.cue                       — Implementation Fidelity Audit
    rcp.cue                       — Reconciliation Protocol
    cgp.cue                       — Canonical Governance Protocol
    ptp.cue                       — Prioritization Triage Protocol
    ovp.cue                       — Observation Validation Protocol
  exploratory/
    adp.cue                       — Adversarial Design Protocol

governance/
  routing.cue                     — problem → protocol selection
  recording.cue                   — completed run → queryable record

examples/runs/
  cffp-example-01.cue             — formalization run, outcome: canonical
  cgp-example-01.cue              — governance run, outcome: admissible_revision
  atp-example-01.cue              — transfer run, outcome: validated (scope narrowing)
  ovp-example-01.cue              — observation run, outcome: validated (with caveat)
  routing-example-01.cue          — routing result: OVP → HEP sequence

docs/
  DOMAIN_MAP.md                   — full domain coverage and design rationale
```

---

## The Dialectic Kernel

Every adversarial protocol is built from the same five primitives defined in `dialectics.cue`:

**Rebuttal** — the atomic response to pressure. Either a `refutation` (challenge dismissed, no trace left) or a `scope_narrowing` (challenge accepted, candidate retreats from the targeted case and records the limitation). Scope narrowings accumulate and become acknowledged limitations in the final output.

**Challenge** — targeted adversarial pressure against a candidate, with a rebuttal slot. The challenge types vary by protocol; the structure is the same.

**Derivation** — mechanical survivor determination. A candidate is eliminated if any challenge targeting it has no valid rebuttal. Survivors carry their scope narrowings forward.

**Obligation Gate** — proof obligations that must be satisfied before a survivor is adopted. An unsatisfied obligation with `satisfied: false` blocks the run from closing. The anti-hallucination mechanism.

**Revision Loop** — zero-survivor feedback. When Phase 3 eliminates everything, the loop diagnoses why and determines where to restart. Zero survivors is not failure — it means the problem is harder than the initial candidates assumed.

---

## Validation

Each protocol file can be validated independently:

```sh
cue vet protocols/adversarial/cffp.cue
cue vet protocols/evaluative/ovp.cue
cue vet dialectics.cue
# etc.
```

Example run files validate against their own package types:

```sh
cue vet examples/runs/atp-example-01.cue
```
