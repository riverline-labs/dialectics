# dialectics.cue — Domain Map

## Layer Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  GOVERNANCE LAYER                                                   │
│  routing · recording · lifecycle                                    │
├─────────────────────────────────────────────────────────────────────┤
│  PROTOCOL LAYER                                                     │
│  domain-specific instantiations of the dialectic                    │
├─────────────────────────────────────────────────────────────────────┤
│  DIALECTIC LAYER  (dialectics.cue)                                  │
│  rebuttal · challenge · derivation · obligation · revision          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Current Protocols: Disposition

| Protocol | Status     | Disposition  | Rationale                                                   |
| -------- | ---------- | ------------ | ----------------------------------------------------------- |
| **CFFP** | ✅ Keep    | Protocol     | Core adversarial. Formalization domain. No overlap.         |
| **CDP**  | ✅ Keep    | Protocol     | Core adversarial. Decomposition domain. No overlap.         |
| **CBP**  | ✅ Keep    | Protocol     | Core adversarial. Meaning domain. No overlap.               |
| **HEP**  | ✅ Keep    | Protocol     | Core adversarial. Causation domain. No overlap.             |
| **ADP**  | ✅ Keep    | Protocol     | Core exploratory. Design space domain. Structurally unique. |
| **AAP**  | ✅ Keep    | Protocol     | Core evaluative. Assumption domain. No overlap.             |
| **IFA**  | ✅ Keep    | Protocol     | Core evaluative. Fidelity domain. No overlap.               |
| **RCP**  | ✅ Keep    | Protocol     | Core evaluative. Consistency domain. No overlap.            |
| **RPP**  | 🔀 Merge   | → **CGP**    | Merge with DJP. Revision is partial deprecation.            |
| **DJP**  | 🔀 Merge   | → **CGP**    | Merge with RPP. Deprecation is total revision.              |
| **PSP**  | ⬆️ Promote | → Governance | Routing is type matching, not adjudication.                 |
| **ARP**  | ⬆️ Promote | → Governance | Recording is projection, not adjudication.                  |

**Result: 12 → 9 protocols + 2 governance primitives**

---

## Merged Protocol

| New Protocol | Name                          | Absorbs   | Question                                      |
| ------------ | ----------------------------- | --------- | --------------------------------------------- |
| **CGP**      | Canonical Governance Protocol | RPP + DJP | Is this canonical form still fit for purpose? |

CGP verdicts: **admissible revision** · **inadmissible** · **deprecated** · **conditional retention** · **deferred**

---

## Surviving Protocol Map by Domain

| #   | Protocol | Archetype   | Domain        | Core Question                           |
| --- | -------- | ----------- | ------------- | --------------------------------------- |
| 1   | **CFFP** | Adversarial | Formalization | What is the right formal structure?     |
| 2   | **CDP**  | Adversarial | Decomposition | Is this one thing or two?               |
| 3   | **CBP**  | Adversarial | Meaning       | What does this term actually mean?      |
| 4   | **HEP**  | Adversarial | Causation     | Why did this happen?                    |
| 5   | **ADP**  | Exploratory | Exploration   | What is the space of possibilities?     |
| 6   | **AAP**  | Evaluative  | Assumption    | What is this argument standing on?      |
| 7   | **IFA**  | Evaluative  | Fidelity      | Does the implementation match the spec? |
| 8   | **RCP**  | Evaluative  | Consistency   | Do these outputs agree with each other? |
| 9   | **CGP**  | Evaluative  | Governance    | Is this canonical form still fit?       |

---

## Missing Domains

| #   | Proposed ID | Domain                          | Core Question                                             | Archetype   | Notes                                                                                                                                                                                                             |
| --- | ----------- | ------------------------------- | --------------------------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 10  | **ATP**     | Analogy / Transfer              | Is this structural similarity real and importable?        | Adversarial | Thesis: "these are the same structure." Antithesis: "surface similarity hides deep differences." Pressure via disanalogy counterexamples. Output: validated transfer with acknowledged divergences, or rejection. |
| 11  | **PTP**     | Prioritization / Triage         | Given finite resources, which path first?                 | Evaluative  | Multiple valid options exist. Not about correctness but about value under constraint. Evaluates cost, risk, dependency order, reversibility. Verdict: ranked priority with rationale.                             |
| 12  | **EMP**     | Emergence / Composition Effects | What behaviors appear at the seams that no part predicts? | Adversarial | Inverse of CDP. Composed canonical forms may produce emergent behaviors not predicted by any individual form. Pressure via composition scenario generation. Could extend RCP but the question is distinct enough. |
| 13  | **OVP**     | Observation Validation          | Is this phenomenon real as described?                     | Evaluative  | Prior to HEP. Before asking "why did this happen," ask "did this actually happen?" Evaluates measurement validity, selection bias, mischaracterization. Verdict: validated / contested / artifact.                |

---

## Complete Target Map (13 protocols + 2 governance primitives)

### Dialectic Layer

```
dialectics.cue
├── Rebuttal          (refutation | scope_narrowing | evidence_unreliability)
├── Challenge         (targeted pressure with rebuttal slot)
├── Derived           (elimination + survivor records)
├── ObligationGate    (proof obligations before adoption)
├── RevisionLoop      (zero-survivor feedback)
└── Finding           (contradiction | gap | ambiguity | decision | dependency | risk | limitation)
```

### Protocol Layer — Adversarial (generate → pressure → survive → adopt)

```
protocols/adversarial/
├── CFFP   Formalization        candidates × invariants → canonical form
├── CDP    Decomposition        splits × incoherence → authorized parts
├── CBP    Meaning              resolutions × usages → sharpened definition
├── HEP    Causation            hypotheses × evidence → adopted explanation
├── ATP    Analogy/Transfer     transfer claims × disanalogies → validated transfer
└── EMP    Emergence            composition scenarios × canonical forms → emergence map
```

### Protocol Layer — Exploratory (personas → rounds → map)

```
protocols/exploratory/
└── ADP    Exploration          personas × constraints → design map
```

### Protocol Layer — Evaluative (subject × criteria → verdict)

```
protocols/evaluative/
├── AAP    Assumption           argument × extraction procedures → fragility map
├── IFA    Fidelity             implementation × canonical form → fidelity verdict
├── RCP    Consistency          run outputs × vocabulary alignment → reconciliation map
├── CGP    Governance           canonical form × revision/deprecation case → fitness verdict
├── PTP    Prioritization       valid paths × resource constraints → ranked priority
└── OVP    Observation          phenomenon × validation procedures → observation verdict
```

### Governance Layer (not protocols — primitives)

```
governance/
├── Routing     (was PSP)    problem → protocol selection via trigger matching
└── Recording   (was ARP)    completed run → queryable record via type projection
```

---

## Domain Coverage Matrix

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

## Archetype Distribution

```
  Adversarial (6):  CFFP  CDP  CBP  HEP  ATP  EMP
  Evaluative  (5):  AAP   IFA  RCP  CGP  PTP  OVP
  Exploratory (1):  ADP
  Governance  (2):  Routing  Recording
```

---

## Dependency Graph (simplified)

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
