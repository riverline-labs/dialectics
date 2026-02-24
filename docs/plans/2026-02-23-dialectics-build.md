# Dialectics Engine Build Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the existing flat protocol collection into a structured, validated CUE dialectic engine with consistent types, governance primitives, four new protocols, and an extracted kernel.

**Architecture:** Three-layer system — governance (routing + recording), protocols (adversarial / evaluative / exploratory), and the dialectics.cue kernel extracted last. Each protocol file is a standalone CUE package validated per-file (not directory-level). The kernel (`dialectics.cue`) defines pure dialectical structure with zero domain knowledge; protocols are domain-specific instantiations.

**Tech Stack:** CUE (cuelang.org) — install via `brew install cue-lang/tap/cue` or `go install cuelang.org/go/cmd/cue@latest`. Validation is `cue vet <file>` per file. Concrete instance validation is `cue vet --concrete <file>`.

---

## Prerequisite: Install CUE

**Step 1: Install CUE toolchain**

```bash
brew install cue-lang/tap/cue
```

Or via Go:
```bash
go install cuelang.org/go/cmd/cue@latest
```

**Step 2: Verify**

```bash
cue version
```
Expected: version output with `cue v0.x.x` or similar.

**Step 3: Create target directory structure**

```bash
mkdir -p /Users/bwb/src/riverline/dialectics/protocols/adversarial
mkdir -p /Users/bwb/src/riverline/dialectics/protocols/evaluative
mkdir -p /Users/bwb/src/riverline/dialectics/protocols/exploratory
mkdir -p /Users/bwb/src/riverline/dialectics/governance
mkdir -p /Users/bwb/src/riverline/dialectics/examples/runs
```

---

## Understanding the CUE Package Model

Each `.cue` file in this project is a **standalone package** (e.g., `package cffp`, `package cdp`). Files in the same directory may have different package declarations — that is fine as long as `cue vet` is run **per file**, not per directory.

Per-file validation: `cue vet protocols/adversarial/cffp.cue` ✓
Directory validation: `cue vet protocols/adversarial/` ✗ (mixed packages = error)

All validation in this plan uses per-file commands.

---

## Phase 1: Move and Clean Existing Protocols

Phase 1 reorganizes the 8 "keep" protocols into the target directory structure and fixes structural inconsistencies discovered by comparing against the CFFP v0.2.1 gold standard.

**CFFP v0.2.1 gold standard defines:**
- `#Rebuttal: { kind: "refutation" | "scope_narrowing", argument: string, valid: bool, limitation_description?: string }`
- `#Eliminated: { candidate_id: string, reason: #EliminationReason, source_id: string }`
- `#Survivor: { candidate_id: string, scope_narrowings: [...string] }`
- `#Derived: { eliminated: [...#Eliminated], survivors: [...#Survivor] }`
- Phase structure: 1 intake → 2 candidates → 3 pressure → (3b revision) → 4 selection/collapse → 5 obligations → 6 adoption

### Task 1: Move CFFP (no content changes)

**Files:**
- Source: `protocols/cffp.cue`
- Destination: `protocols/adversarial/cffp.cue`

CFFP is at v0.2.1 and is the gold standard. Copy it as-is.

**Step 1: Copy the file**
```bash
cp /Users/bwb/src/riverline/dialectics/protocols/cffp.cue \
   /Users/bwb/src/riverline/dialectics/protocols/adversarial/cffp.cue
```

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/adversarial/cffp.cue
```
Expected: no output (success).

**Step 3: Delete the original**
```bash
rm /Users/bwb/src/riverline/dialectics/protocols/cffp.cue
```

**Step 4: Commit**
```bash
git add protocols/adversarial/cffp.cue protocols/cffp.cue
git commit -m "move: cffp.cue → protocols/adversarial/cffp.cue (no changes)"
```

---

### Task 2: Move and clean CDP

**Files:**
- Source: `protocols/cdp.cue`
- Destination: `protocols/adversarial/cdp.cue`

**Issues to fix:**
- Version: bump `0.1.0` → `0.1.1` (change in header comment and `#Protocol.version`)
- `#EliminatedSplit` and `#SurvivorSplit`: structurally consistent with CFFP pattern — no changes needed
- Rebuttal: `#BoundaryRebuttal` has the correct structure — no changes needed
- Add the standard phase comment header pattern matching CFFP

**Step 1: Copy and edit**

Copy `protocols/cdp.cue` to `protocols/adversarial/cdp.cue`. Edit:

```cue
// Version: 0.1.1
//
// Changes from 0.1.0:
//   - Reorganized to protocols/adversarial/
```

And in the `#Protocol` struct:
```cue
#Protocol: {
    name:        "Construct Decomposition Protocol"
    version:     "0.1.1"   // was 0.1.0
    description: "Incoherence-driven construct splitting. Parts must be more coherent than the whole."
}
```

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/adversarial/cdp.cue
```

**Step 3: Delete original, commit**
```bash
rm /Users/bwb/src/riverline/dialectics/protocols/cdp.cue
git add protocols/adversarial/cdp.cue protocols/cdp.cue
git commit -m "move: cdp.cue → protocols/adversarial/ (v0.1.1, no structural changes)"
```

---

### Task 3: Move and clean CBP

**Files:**
- Source: `protocols/cbp.cue`
- Destination: `protocols/adversarial/cbp.cue`

**Issues to fix:**
- Version: `0.1.0` → `0.1.1`
- `#DefinitionRebuttal` structure is consistent with CFFP — no changes
- `#EliminatedCandidate` and `#SurvivorCandidate` are consistent — no changes
- `#Phase3b` is minimal (just triggered/diagnosis/resolution/notes) — verify it matches CDP/CFFP pattern. Current CBP Phase3b:

```cue
#Phase3b: {
    triggered:  bool
    diagnosis:  "usages_insufficient" | "candidates_too_weak" | "term_irredeemable"
    resolution: "collect_more_usages" | "revise_candidates" | "close_as_retired"
    notes:      string
}
```

This is CBP-appropriate. Consistent with the pattern. No changes.

**Step 1: Copy, bump version in header comment and `#Protocol.version`**

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/adversarial/cbp.cue
```

**Step 3: Delete original, commit**
```bash
rm /Users/bwb/src/riverline/dialectics/protocols/cbp.cue
git add protocols/adversarial/cbp.cue protocols/cbp.cue
git commit -m "move: cbp.cue → protocols/adversarial/ (v0.1.1, no structural changes)"
```

---

### Task 4: Move and clean HEP

**Files:**
- Source: `protocols/hep.cue`
- Destination: `protocols/adversarial/hep.cue`

**Issues to fix:**
- Version: `0.1.0` → `0.1.1`
- `source_ids: [...string]` in `#EliminatedHypothesis` vs `source_id: string` in other protocols. **Resolution:** Change to `source_id: string` for structural consistency. HEP's `accumulated_weak_pressure` case can reference the `#AccumulatedPressure` record by id rather than listing all evidence item ids directly. Add a comment explaining this.

Current:
```cue
#EliminatedHypothesis: {
    hypothesis_id: string
    reason:        #EliminationReason
    source_ids:    [...string]
}
```

Change to:
```cue
#EliminatedHypothesis: {
    hypothesis_id: string
    reason:        #EliminationReason
    // For decisive/strong inconsistency: the evidence item id.
    // For accumulated_weak_pressure: the id of the #AccumulatedPressure record in Phase3.
    source_id: string
}
```

**Step 1: Copy, apply the source_id fix, bump version**

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/adversarial/hep.cue
```

**Step 3: Delete original, commit**
```bash
rm /Users/bwb/src/riverline/dialectics/protocols/hep.cue
git add protocols/adversarial/hep.cue protocols/hep.cue
git commit -m "move: hep.cue → protocols/adversarial/ (v0.1.1, normalize source_id)"
```

---

### Task 5: Move evaluative protocols (AAP, IFA, RCP)

**Files:**
- `protocols/aap.cue` → `protocols/evaluative/aap.cue`
- `protocols/ifa.cue` → `protocols/evaluative/ifa.cue`
- `protocols/rcp.cue` → `protocols/evaluative/rcp.cue`

Evaluative protocols follow inputs → extraction → assessment → verdict. All three already follow this pattern correctly:
- AAP: subject intake → assumption extraction → characterization → stress testing → fragility map → recommendations → audit record
- IFA: inputs → obligation extraction → fidelity evaluation → verdict derivation → remediation
- RCP: inputs → vocabulary alignment → conflict detection → resolution → reconciliation map → record

**Issues to fix (all three):**
- Version bump: `0.1.0` → `0.1.1`
- No structural changes needed

**Step 1: Copy all three files to evaluative/**

**Step 2: Bump version strings in header and `#Protocol` struct for each**

**Step 3: Validate all**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/evaluative/aap.cue
cue vet /Users/bwb/src/riverline/dialectics/protocols/evaluative/ifa.cue
cue vet /Users/bwb/src/riverline/dialectics/protocols/evaluative/rcp.cue
```

**Step 4: Delete originals, commit**
```bash
rm protocols/aap.cue protocols/ifa.cue protocols/rcp.cue
git add protocols/evaluative/ protocols/aap.cue protocols/ifa.cue protocols/rcp.cue
git commit -m "move: evaluative protocols → protocols/evaluative/ (v0.1.1)"
```

---

### Task 6: Move ADP (exploratory)

**Files:**
- Source: `protocols/adp.cue`
- Destination: `protocols/exploratory/adp.cue`

ADP is structurally unique (exploratory archetype with personas and rounds). No structural changes needed.

**Step 1: Copy, bump version** (`"1.0"` is the current version — ADP doesn't use semver in the same way. Keep as-is or bump to `"1.0.1"`.)

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/exploratory/adp.cue
```

**Step 3: Delete original, commit**
```bash
rm protocols/adp.cue
git add protocols/exploratory/adp.cue protocols/adp.cue
git commit -m "move: adp.cue → protocols/exploratory/"
```

---

## Phase 2: Create CGP (Canonical Governance Protocol)

CGP merges RPP (revision adjudication) and DJP (deprecation adjudication) into a unified governance protocol that handles the full spectrum from minor revision to full retirement.

**File to create:** `protocols/evaluative/cgp.cue`
**Files to delete:** `protocols/rpp.cue`, `protocols/djp.cue`

### Task 7: Write CGP

**Files:**
- Create: `protocols/evaluative/cgp.cue`

**Structure reference:**
- From RPP: canonical reference input, invariant preservation checks, dependent impact assessment, revision ruling
- From DJP: evidence evaluation (5 kinds), successor readiness, deprecation notice
- CGP adds: discriminated union governance case input, combined verdict space

**CGP archetype:** Evaluative (inputs → analysis → verdict). Not adversarial — no candidate pressure loop.

**CGP phases:**
1. Inputs — canonical reference + governance case (revision | deprecation | combined)
2. Invariant Analysis — preservation check (for revision) or erosion assessment (for deprecation)
3. Successor/Alternative Assessment — is there something better? Is it ready?
4. Dependent Impact — who breaks, what is the migration burden?
5. Verdict — ruling with evidence

**Key design:** The governance case input is a discriminated union. Use a `kind` field:
```cue
#GovernanceCase: {
    kind: "revision" | "deprecation" | "combined"
    // ... conditional fields per kind
}
```

**Full skeleton for `protocols/evaluative/cgp.cue`:**

```cue
// Canonical Governance Protocol (CGP)
// Version: 0.1.0
//
// CGP adjudicates whether a canonical form is still fit for purpose.
// It handles the full spectrum from minor revision to full deprecation.
// CGP absorbs and replaces RPP (Revision Proposal Protocol) and
// DJP (Deprecation Judgment Protocol).
//
// The governance case input is a discriminated union:
//   revision    — a proposed change to a canonical form
//   deprecation — a case for retiring a canonical form
//   combined    — deprecation with a proposed successor/replacement
//
// Verdicts:
//   admissible_revision  — revision preserves all invariants; non-breaking
//   inadmissible         — revision breaks invariants or dependents
//   deprecated           — construct retired; migration guidance issued
//   conditional_retention — retained provisionally under defined conditions
//   deferred             — cannot evaluate without additional runs
//
// An agent reading this file should be able to:
//   - Accept a canonical reference and a governance case (revision, deprecation, or combined)
//   - Evaluate invariant preservation (for revisions) or erosion (for deprecation)
//   - Assess successor readiness and dependent impact
//   - Produce a binding verdict with migration or remediation guidance

package cgp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
    name:        "Canonical Governance Protocol"
    version:     "0.1.0"
    description: "Adjudicates fitness-for-purpose of canonical forms. Handles revision through deprecation."
}

// ─── CANONICAL REFERENCE ────────────────────────────────────────────────────

#CanonicalReference: {
    construct:                string
    source_run_id:            string
    formal_statement:         string
    evaluation_def:           string
    satisfies:                [...string]
    acknowledged_limitations: [...string]
    canonicalized_at:         string // ISO 8601
}

// ─── GOVERNANCE CASE (discriminated union) ───────────────────────────────────

#RevisionProposal: {
    id:                 string
    proposed_by:        string | *"unattributed"
    description:        string
    changes: {
        formal_statement?:   string
        evaluation_def?:     string
        add_invariants?:     [...string]
        remove_invariants?:  [...string]
        add_limitations?:    [...string]
        remove_limitations?: [...string]
    }
    motivation:          string
    claims_non_breaking: bool
}

#EvidenceKind:
    "practical_failure"    |
    "invariant_erosion"    |
    "superior_alternative" |
    "design_space_shift"   |
    "implementation_burden"

#DeprecationEvidence: {
    kind:             #EvidenceKind
    description:      string
    severity:         "compelling" | "suggestive" | "weak"
    failure_cases?:   [...string]
    limitation_refs?: [...string]
}

#DeprecationCase: {
    submitted_by:       string | *"unattributed"
    summary:            string
    evidence:           [...#DeprecationEvidence]
    evidence:           [_, ...]
}

#GovernanceCase: {
    kind: "revision" | "deprecation" | "combined"

    if kind == "revision" {
        revision: #RevisionProposal
    }

    if kind == "deprecation" {
        deprecation: #DeprecationCase
    }

    if kind == "combined" {
        // Combined: deprecating the current canonical form and proposing a replacement.
        deprecation:  #DeprecationCase
        revision:     #RevisionProposal // the proposed replacement/successor
        relationship: string // how the revision relates to the deprecation
    }
}

// ─── PHASE 1: INPUTS ────────────────────────────────────────────────────────

#Phase1: {
    canonical: #CanonicalReference
    case:      #GovernanceCase
}

// ─── PHASE 2: INVARIANT ANALYSIS ─────────────────────────────────────────────

#PreservationVerdict: "preserved" | "broken" | "weakened" | "indeterminate"

#InvariantPreservation: {
    invariant_id: string
    verdict:      #PreservationVerdict
    rationale:    string
    if verdict == "broken" || verdict == "weakened" {
        intentional:   bool
        justification?: string // required if intentional
    }
}

#InvariantErosion: {
    invariant_id:     string
    eroded:           bool
    erosion_argument: string
    if eroded {
        severity: "fatal" | "degraded"
    }
}

#Phase2: {
    // Populated when case.kind == "revision" or "combined"
    preservation_checks?: [...#InvariantPreservation]

    // Populated when case.kind == "deprecation" or "combined"
    erosion_assessments?: [...#InvariantErosion]

    // Overall invariant health verdict for this phase.
    invariant_health: "sound" | "degraded" | "broken" | "indeterminate"
    invariant_health_argument: string
}

// ─── PHASE 3: SUCCESSOR/ALTERNATIVE ASSESSMENT ───────────────────────────────

#SuccessorReadiness: {
    evaluated:             bool
    has_canonical_form:    bool
    canonical_run_id?:     string
    covers_all_invariants: bool
    invariant_gaps:        [...string]
    migration_path_exists: bool
    migration_description?: string
    ready:                 bool
}

#Phase3: {
    // Is there a declared successor in the governance case?
    successor_proposed: bool
    if successor_proposed {
        successor_ref:    string // reference to the proposed successor/revision
        readiness:        #SuccessorReadiness
    }
    if !successor_proposed {
        // Is there an undeclared alternative that should be considered?
        alternative_exists: bool
        if alternative_exists {
            alternative_description: string
            alternative_readiness:   #SuccessorReadiness
        }
    }
    assessment_notes: string
}

// ─── PHASE 4: DEPENDENT IMPACT ───────────────────────────────────────────────

#MigrationBurden: "trivial" | "moderate" | "significant" | "unknown"

#Dependent: {
    id:          string
    kind:        "canonical_construct" | "implementation" | "protocol_run" | "other"
    description: string
}

#DependentImpact: {
    dependent_id: string
    breaking:     bool
    burden:       #MigrationBurden
    rationale:    string
    if breaking {
        severity:    "fatal" | "degraded"
        description: string
        blocker:     bool
    }
}

#Phase4: {
    known_dependents:     [...#Dependent]
    impact_assessments:   [...#DependentImpact]
    total_burden:         #MigrationBurden
    blocked_dependents:   [...string] // dependent_ids with blocker: true
    incomplete_landscape: bool
    if incomplete_landscape {
        unknown_dependents: string
    }
}

// ─── PHASE 5: VERDICT ────────────────────────────────────────────────────────

#Verdict: "admissible_revision" | "inadmissible" | "deprecated" | "conditional_retention" | "deferred"

#DeprecationNotice: {
    construct:          string
    reason:             string
    successor?:         string
    migration_guidance: string
    effective_at:       string // ISO 8601
}

#RevisedCanonical: {
    formal_statement:         string
    evaluation_def:           string
    satisfies:                [...string]
    acknowledged_limitations: [...string]
}

#ConditionalRetention: {
    conditions:            [...string]
    re_evaluation_trigger: string
    provisional_expiry:    string
}

#Phase5: {
    verdict:                #Verdict
    rationale:              string

    if verdict == "inadmissible" {
        blocking_reasons: [...string]
    }
    if verdict == "deprecated" {
        deprecation_notice: #DeprecationNotice
    }
    if verdict == "admissible_revision" {
        revised_canonical: #RevisedCanonical
    }
    if verdict == "conditional_retention" {
        conditional_retention: #ConditionalRetention
    }
    if verdict == "deferred" {
        required_before_ruling: [...string]
    }
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "admissible_revision" | "inadmissible" | "deprecated" | "conditional_retention" | "deferred"

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#CGPInstance: {
    protocol: #Protocol
    version:  string

    phase1: #Phase1
    phase2: #Phase2
    phase3: #Phase3
    phase4: #Phase4
    phase5: #Phase5

    outcome:       #Outcome
    outcome_notes: string
}
```

**Step 1: Write the file** using the skeleton above.

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/evaluative/cgp.cue
```

**Step 3: Delete RPP and DJP**
```bash
rm /Users/bwb/src/riverline/dialectics/protocols/rpp.cue
rm /Users/bwb/src/riverline/dialectics/protocols/djp.cue
```

**Step 4: Commit**
```bash
git add protocols/evaluative/cgp.cue protocols/rpp.cue protocols/djp.cue
git commit -m "feat: add CGP (merges RPP + DJP), delete RPP and DJP"
```

---

## Phase 3: Create governance/routing.cue from PSP

PSP's job is matching a raw problem to the right protocol. This is type matching, not adjudication — no adversarial loop, no phases with candidates and pressure. Express as pure type definitions.

### Task 8: Write governance/routing.cue

**Files:**
- Create: `governance/routing.cue`
- Delete: `protocols/psp.cue`

**Design:** Routing is constraint evaluation. The `#StructuralFeature` enum → protocol mapping is the core of PSP. Express this as a lookup table plus input/output types. No instance type with outcome tracking.

```cue
// Governance: Protocol Routing
// Version: 0.1.0
//
// Routing determines which protocol(s) to run for a given problem.
// This was previously PSP (Protocol Selection Protocol). Promoted to
// governance because routing is type matching, not adjudication.
//
// Usage: populate a #RoutingInput, then use #FeatureToProtocol to
// determine which protocols apply. Apply disambiguation rules when
// multiple protocols could handle the same features. Sequencing rules
// determine order when multiple protocols must run.
//
// An agent reading this file should be able to:
//   - Classify a raw problem by its structural features
//   - Map features to candidate protocols
//   - Apply disambiguation and sequencing rules
//   - Produce a #RoutingResult without running a full protocol phase cycle

package routing

// ─── STRUCTURAL FEATURES ────────────────────────────────────────────────────
//
// A structural feature is an observable property of the problem that
// indicates which protocol family is appropriate.

#StructuralFeature:
    "term_inconsistency"       | // term used differently across contexts → CBP
    "competing_candidates"     | // multiple formalisms competing → CFFP
    "unknown_design_space"     | // design space not yet understood → ADP
    "argument_fragility"       | // existing argument needs stress-testing → AAP
    "construct_incoherence"    | // construct seems to be two things → CDP
    "causal_ambiguity"         | // multiple explanations for phenomenon → HEP
    "cross_run_conflict"       | // independent runs need reconciling → RCP
    "implementation_gap"       | // implementation vs canonical dispute → IFA
    "revision_pressure"        | // canonical form proposed for change → CGP
    "deprecation_pressure"     | // canonical form proposed for retirement → CGP
    "structural_transfer"      | // cross-domain analogy being claimed → ATP
    "composition_emergence"    | // unexpected behavior at component seams → EMP
    "observation_validity"     | // empirical claim needs validation → OVP
    "resource_constrained_choice" // multiple valid paths, finite resources → PTP

// ─── KNOWN PROTOCOLS ─────────────────────────────────────────────────────────

#KnownProtocol:
    "AAP" | "ADP" | "ATP" | "CBP" | "CDP" | "CFFP" | "CGP" |
    "EMP" | "HEP" | "IFA" | "OVP" | "PTP" | "RCP"

// ─── FEATURE TO PROTOCOL MAPPING ─────────────────────────────────────────────

// Canonical mapping from structural features to protocols.
// A feature may map to more than one protocol — disambiguation rules handle this.
#FeatureProtocolMapping: {
    feature:              #StructuralFeature
    primary_protocol:     #KnownProtocol
    confidence:           "high" | "medium" | "low"
    // Under what conditions is this mapping valid?
    conditions:           string
    // When might a different protocol be more appropriate?
    exceptions:           string
    // Does this protocol have prerequisites?
    prerequisites:        [...#KnownProtocol]
}

// The canonical feature-to-protocol table.
// This is the routing logic — expressed as data, not as procedural code.
#RoutingTable: [...#FeatureProtocolMapping] & [
    { feature: "term_inconsistency",          primary_protocol: "CBP",  confidence: "high",   conditions: "Term used differently across contexts",              exceptions: "If the inconsistency is between implementations of the same spec, use IFA instead", prerequisites: [] },
    { feature: "competing_candidates",         primary_protocol: "CFFP", confidence: "high",   conditions: "Multiple formalisms competing for a construct",       exceptions: "If design space is still open (candidates are not yet formal), use ADP first",   prerequisites: [] },
    { feature: "unknown_design_space",         primary_protocol: "ADP",  confidence: "high",   conditions: "Design space not yet mapped or understood",           exceptions: "If candidates are already known, use CFFP directly",                           prerequisites: [] },
    { feature: "argument_fragility",           primary_protocol: "AAP",  confidence: "high",   conditions: "An existing argument or design needs assumption audit", exceptions: "None",                                                                         prerequisites: [] },
    { feature: "construct_incoherence",        primary_protocol: "CDP",  confidence: "high",   conditions: "A construct satisfies conflicting invariants simultaneously", exceptions: "If incoherence is terminological rather than behavioral, use CBP first",    prerequisites: [] },
    { feature: "causal_ambiguity",             primary_protocol: "HEP",  confidence: "high",   conditions: "Multiple hypotheses for an observed phenomenon",      exceptions: "Validate observation first with OVP if observation is contested",             prerequisites: ["OVP"] },
    { feature: "cross_run_conflict",           primary_protocol: "RCP",  confidence: "high",   conditions: "Two or more independent protocol runs need reconciliation", exceptions: "None",                                                                    prerequisites: [] },
    { feature: "implementation_gap",           primary_protocol: "IFA",  confidence: "high",   conditions: "Dispute about whether an implementation follows a spec", exceptions: "None",                                                                       prerequisites: [] },
    { feature: "revision_pressure",            primary_protocol: "CGP",  confidence: "high",   conditions: "A proposed change to a canonical form requires adjudication", exceptions: "None",                                                                  prerequisites: [] },
    { feature: "deprecation_pressure",         primary_protocol: "CGP",  confidence: "high",   conditions: "A case for retiring a canonical form",               exceptions: "None",                                                                         prerequisites: [] },
    { feature: "structural_transfer",          primary_protocol: "ATP",  confidence: "high",   conditions: "Claiming that a formalism from domain A applies to domain B", exceptions: "None",                                                                  prerequisites: [] },
    { feature: "composition_emergence",        primary_protocol: "EMP",  confidence: "high",   conditions: "Unexpected behavior observed at the boundary of composed canonical forms", exceptions: "Check via RCP first if the emergence might be a cross-run conflict",  prerequisites: [] },
    { feature: "observation_validity",         primary_protocol: "OVP",  confidence: "high",   conditions: "An empirical claim or observation needs validation before being used as protocol input", exceptions: "None",                                      prerequisites: [] },
    { feature: "resource_constrained_choice",  primary_protocol: "PTP",  confidence: "medium", conditions: "Multiple valid protocol paths exist and resources require prioritization", exceptions: "Only use PTP when all options are genuinely valid — if selection is epistemic, use a different protocol", prerequisites: [] },
]

// ─── DISAMBIGUATION RULES ────────────────────────────────────────────────────
//
// When multiple features are present, these rules resolve ambiguity.
// Applied in order — first matching rule wins.

#DisambiguationRule: {
    when:   [...#StructuralFeature] // these features co-occur
    prefer: #KnownProtocol          // prefer this protocol
    because: string                 // why this protocol takes precedence
    run_other_after: bool           // should the other protocol run after?
    other_protocol?: #KnownProtocol
}

#DisambiguationRules: [...#DisambiguationRule] & [
    { when: ["term_inconsistency", "competing_candidates"],  prefer: "CBP",  because: "Term clarity must precede formalism selection",         run_other_after: true,  other_protocol: "CFFP" },
    { when: ["unknown_design_space", "competing_candidates"], prefer: "ADP", because: "Design space must be mapped before pressure testing",   run_other_after: true,  other_protocol: "CFFP" },
    { when: ["causal_ambiguity", "observation_validity"],    prefer: "OVP",  because: "Observation must be validated before hypothesis elimination", run_other_after: true, other_protocol: "HEP" },
    { when: ["construct_incoherence", "term_inconsistency"], prefer: "CBP",  because: "Terminological clarity first; behavioral incoherence may dissolve", run_other_after: true, other_protocol: "CDP" },
]

// ─── ROUTING INPUT / OUTPUT ──────────────────────────────────────────────────

#RoutingInput: {
    problem_statement:   string
    structural_features: [...#StructuralFeature]
    structural_features: [_, ...] // at least one required
    context:             string   // additional context for disambiguation
}

#SequencedStep: {
    order:    uint
    protocol: #KnownProtocol
    purpose:  string // why this step is in the sequence
    feeds:    string // what this step's output feeds into
}

#RoutingResult: {
    primary:   #KnownProtocol
    secondary: [...#KnownProtocol]
    sequenced: bool
    if sequenced {
        sequence: [...#SequencedStep]
        sequence: [_, ...]
    }
    rationale:  string
    warnings:   [...string]
    outcome:    "routed" | "ambiguous" | "unroutable"
    outcome_notes: string
}
```

**Step 1: Write `governance/routing.cue`** using the structure above.

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/governance/routing.cue
```

**Step 3: Delete PSP**
```bash
rm /Users/bwb/src/riverline/dialectics/protocols/psp.cue
```

**Step 4: Commit**
```bash
git add governance/routing.cue protocols/psp.cue
git commit -m "feat: add governance/routing.cue (from PSP), delete psp.cue"
```

---

## Phase 4: Create governance/recording.cue from ARP

ARP is a type projection, not a protocol. Express it as a set of types that any completed run can be projected into.

### Task 9: Write governance/recording.cue

**Files:**
- Create: `governance/recording.cue`
- Delete: `protocols/arp.cue`

**Key changes from ARP:**
- Remove `#Protocol` metadata (not a protocol)
- Remove anything implying ARP is "run"
- Expand `#DisputeKind` to include new protocols (ATP, EMP, OVP, PTP, CGP)
- Rename `#ARPRecord` to `#Record`
- Update `#SourceProtocol` to include all new protocols

```cue
// Governance: Protocol Run Recording
// Version: 0.1.0
//
// Recording standardizes the output of any protocol run into a uniform,
// queryable record. This was previously ARP (Adjudication Record Protocol).
// Promoted to governance because recording is type projection, not adjudication.
//
// A #Record can be produced from any completed protocol run.
// Records are the input to RCP (Reconciliation Protocol).
// They form the decision log of the dialectic system.
//
// An agent reading this file should be able to:
//   - Accept the output of any completed protocol run
//   - Project it into a #Record with all required fields
//   - Identify what was resolved vs. what remains open
//   - Tag the record for downstream queryability

package recording

// ─── SOURCE PROTOCOL ────────────────────────────────────────────────────────

#SourceProtocol:
    "AAP" | "ADP" | "ATP" | "CBP" | "CDP" | "CFFP" | "CGP" |
    "EMP" | "HEP" | "IFA" | "OVP" | "PTP" | "RCP"

#SourceRun: {
    protocol:    #SourceProtocol
    run_id:      string
    run_version: string
    subject:     string
    started:     string // ISO 8601
    completed:   string // ISO 8601
}

// ─── DISPUTE CHARACTERIZATION ────────────────────────────────────────────────

#DisputeKind:
    "term_ambiguity"         |
    "candidate_selection"    |
    "assumption_audit"       |
    "design_mapping"         |
    "construct_repair"       |
    "implementation_check"   |
    "governance_case"        | // was revision_proposal + deprecation_case; now CGP
    "cross_run_conflict"     |
    "analogy_transfer"       | // ATP
    "composition_emergence"  | // EMP
    "observation_validity"   | // OVP
    "prioritization"           // PTP

#DisputeCharacterization: {
    kind:        #DisputeKind
    description: string
    prior_runs:  [...string] // run_ids of prior relevant runs
}

// ─── RESOLUTION SUMMARY ──────────────────────────────────────────────────────

#ResolutionStatus: "decided" | "open" | "rejected"

#ResolutionSummary: {
    status:           #ResolutionStatus
    decision?:        string
    open_questions?:  [...string]
    eliminated_count: int | *0
    survivors:        [...string]
}

// ─── ACKNOWLEDGED LIMITATIONS ────────────────────────────────────────────────

#AcknowledgedLimitation: {
    description: string
    source:      string // which phase or challenge produced this limitation
}

// ─── DEPENDENCIES ────────────────────────────────────────────────────────────

#Dependencies: {
    consumed: [...string] // run_ids this run depended on
    produced: [...string] // artifacts this run produced
}

// ─── NEXT ACTIONS ────────────────────────────────────────────────────────────

#NextAction: {
    action:    string
    protocol?: #SourceProtocol
    rationale: string
}

// ─── RECORD ──────────────────────────────────────────────────────────────────
//
// The canonical projection of any completed protocol run.
// All fields are required. Absent fields indicate an incomplete projection.

#Record: {
    record_id: string

    source_run:               #SourceRun
    dispute:                  #DisputeCharacterization
    resolution:               #ResolutionSummary
    acknowledged_limitations: [...#AcknowledgedLimitation]
    dependencies:             #Dependencies
    tags:                     [...string]
    next_actions:             [...#NextAction]
    notes:                    string | *""
}
```

**Step 1: Write `governance/recording.cue`** using the structure above.

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/governance/recording.cue
```

**Step 3: Delete ARP**
```bash
rm /Users/bwb/src/riverline/dialectics/protocols/arp.cue
```

**Step 4: Commit**
```bash
git add governance/recording.cue protocols/arp.cue
git commit -m "feat: add governance/recording.cue (from ARP), delete arp.cue"
```

---

## Phase 5: Build New Protocols

All new adversarial protocols (ATP, EMP) use **exactly** the same phase structure as CFFP/CDP/CBP/HEP. Only the domain-specific types plugged into those slots differ. New evaluative protocols (OVP, PTP) follow the inputs → assessment → verdict pattern.

### Task 10: Write ATP (Analogy Transfer Protocol)

**File:** `protocols/adversarial/atp.cue`
**Package:** `package atp`
**Archetype:** Adversarial — uses full pressure loop

**Domain:** Cross-domain structural transfer. "Does formalization from domain A apply to domain B?"

**Phase structure:**
1. Transfer Declaration — source construct + target domain + claimed structural correspondence
2. Correspondence Candidates — proposed mappings with structural alignment arguments
3. Pressure — three challenge types: disanalogy counterexample, domain mismatch, scope challenge
4. Survivor Derivation — same pattern as CFFP (unrebutted challenges eliminate)
5. Phase 3b (conditional) — zero survivors means correspondence needs revision
6. Phase 4 (conditional) — multiple survivors: select one
7. Transfer Obligations — verify the imported formalization preserves its invariants in the new domain
8. Phase 6 — Validated Transfer or Rejection record

**Key types to implement:**

```cue
package atp

#Protocol: {
    name:        "Analogy Transfer Protocol"
    version:     "0.1.0"
    description: "Cross-domain structural transfer validation. Survivors carry acknowledged divergences."
}

#SourceConstruct: {
    name:             string
    domain:           string
    formal_statement: string // the formalization in the source domain
    invariants:       [...string] // what the source formalization guarantees
}

#TargetDomain: {
    name:        string
    description: string
    // What constructs are already canonicalized in this domain?
    canonical_constructs: [...string]
}

#Phase1: {
    source_construct:           #SourceConstruct
    target_domain:              #TargetDomain
    claimed_correspondence:     string // the structural similarity being claimed
    motivation:                 string // why this transfer is useful
}

// ─── PHASE 2: CORRESPONDENCE CANDIDATES ──────────────────────────────────────
//
// Each candidate proposes a mapping from source structure to target structure.
// The mapping must be precise: for each element of the source formalization,
// what is its analog in the target domain?

#StructuralMapping: {
    source_element: string // an element of the source formalization
    target_element: string // its proposed analog in the target domain
    alignment_argument: string // why these elements correspond
    // Is this mapping 1-to-1, or does it require adjustment?
    mapping_kind: "direct" | "adjusted" | "partial"
    if mapping_kind == "adjusted" || mapping_kind == "partial" {
        adjustment_description: string
    }
}

#CorrespondenceCandidate: {
    id:       string
    description: string
    mappings: [...#StructuralMapping]
    mappings: [_, ...] // at least one mapping required
    // Does this candidate claim all source invariants transfer?
    invariants_transfer: bool
    if !invariants_transfer {
        non_transferring_invariants: [...string]
        non_transfer_argument:       string
    }
    // What domain-specific properties does this candidate claim to gain?
    domain_specific_gains: [...string]
}

#Phase2: {
    candidates: [...#CorrespondenceCandidate]
    candidates: [_, ...]
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────
//
// Three challenge types — same rebuttal mechanics as CFFP:
//
// DisanalagyCounterexample — a case where the claimed structural correspondence
//   breaks: source element X does not behave like target element Y in this case.
//   Rebuttal: refutation (the analogy holds) or scope_narrowing (acknowledged divergence).
//
// DomainMismatch — the source and target domains differ in a foundational way
//   that invalidates the transfer even if the structural correspondence holds.
//   Example: the source domain has property P that the target domain lacks,
//   and P is what makes the source formalization coherent.
//   Rebuttal: refutation only (scope narrowing on a domain mismatch would
//   eliminate the transfer entirely).
//
// ScopeChallenge — the transfer only works for a subset of the target domain.
//   Rebuttal: scope_narrowing (the candidate can survive by accepting the restriction).

#TransferRebuttal: {
    kind:     "refutation" | "scope_narrowing"
    argument: string
    valid:    bool
    limitation_description?: string // required if scope_narrowing
}

#DisanalogyCE: {
    id:               string
    target_candidate: string
    target_mapping?:  string // which mapping is being challenged, if specific
    witness:          string // the case where the analogy breaks
    minimal:          bool & true
    rebuttal?:        #TransferRebuttal
}

#DomainMismatch: {
    id:               string
    target_candidate: string
    missing_property: string // the property the target domain lacks
    argument:         string // why this property is required for the transfer
    // Domain mismatch rebuttals must be refutations — scope narrowing is not available.
    rebuttal?: {
        argument: string
        valid:    bool
    }
}

#ScopeChallenge: {
    id:               string
    target_candidate: string
    restricted_scope: string // the subset where the transfer holds
    argument:         string // why the transfer fails outside this scope
    rebuttal?:        #TransferRebuttal
}

#Phase3: {
    disanalogy_counterexamples: [...#DisanalogyCE]
    domain_mismatches:          [...#DomainMismatch]
    scope_challenges:           [...#ScopeChallenge]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────

#EliminationReason:
    "disanalogy_ce_unrebutted"       |
    "domain_mismatch_unrebutted"     |
    "scope_challenge_unrebutted"

#EliminatedTransfer: {
    candidate_id: string
    reason:       #EliminationReason
    source_id:    string
}

#SurvivorTransfer: {
    candidate_id:     string
    scope_narrowings: [...string] // from scope-narrowing rebuttals; become acknowledged divergences
}

#Derived: {
    eliminated: [...#EliminatedTransfer]
    survivors:  [...#SurvivorTransfer]
}

// ─── PHASE 3b: REVISION (conditional) ────────────────────────────────────────

#Phase3b: {
    triggered:  bool
    diagnosis:  "correspondence_too_strong" | "candidates_too_weak" | "transfer_not_viable"
    resolution: "revise_correspondence" | "revise_candidates" | "close_as_rejected"
    notes:      string
}

// ─── PHASE 4: SELECTION (conditional) ────────────────────────────────────────

#Phase4: {
    multiple_survivors: bool
    if multiple_survivors {
        selected:        string // candidate id
        selection_basis: string // prefer fewest scope narrowings, then strongest domain_specific_gains
        alternatives_rejected: [...{
            candidate_id: string
            reason:       string
        }]
    }
    final_candidate: string
}

// ─── PHASE 5: TRANSFER OBLIGATIONS ───────────────────────────────────────────
//
// Before adopting the correspondence, verify that the imported formalization
// actually preserves its invariants when instantiated in the target domain.

#TransferObligation: {
    property:  string // what invariant or property must be preserved
    argument:  string // why it is preserved in the target domain
    satisfied: bool
    if !satisfied {
        blocker: string
    }
}

#Phase5: {
    obligations:   [...#TransferObligation]
    all_satisfied: bool
}

// ─── PHASE 6: VALIDATED TRANSFER OR REJECTION ────────────────────────────────

#ValidatedTransfer: {
    source_construct:          string
    target_domain:             string
    adopted_correspondence:    string // description of the validated mapping
    transferred_formalization: string // the formalization as instantiated in the target domain
    acknowledged_divergences:  [...string] // from scope narrowings; places where transfer is limited
    // Invariants the transfer preserves in the target domain.
    preserved_invariants:      [...string]
    // Invariants from the source that do NOT transfer.
    non_transferred_invariants: [...string]
}

#RejectionRecord: {
    reason:           string
    strongest_challenge: string // the challenge that ultimately prevented transfer
    what_would_help:  string  // what revision to source or target might enable future transfer
}

#Phase6: {
    if outcome == "validated" {
        validated_transfer: #ValidatedTransfer
    }
    if outcome == "rejected" {
        rejection_record: #RejectionRecord
    }
    outcome: #Outcome
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "validated" | "rejected" | "open"
// validated — correspondence survived all pressure; formalization transferred with acknowledged divergences
// rejected  — correspondence eliminated by unrebutted challenges; transfer not viable
// open      — multiple correspondences survived; requires further discrimination

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#ATPInstance: {
    protocol: #Protocol
    version:  string

    phase1: #Phase1
    phase2: #Phase2
    phase3: #Phase3

    derived: #Derived

    phase3b?: #Phase3b

    phase4?: #Phase4 // only if len(derived.survivors) > 1

    phase5: #Phase5
    phase6?: #Phase6 // only if phase5.all_satisfied == true

    outcome:       #Outcome
    outcome_notes: string
}
```

**Step 1: Write `protocols/adversarial/atp.cue`** using the full skeleton above. The skeleton is complete — fill in the header comment block to match the style in the build prompt.

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/adversarial/atp.cue
```

**Step 3: Commit**
```bash
git add protocols/adversarial/atp.cue
git commit -m "feat: add ATP (Analogy Transfer Protocol) v0.1.0"
```

---

### Task 11: Write EMP (Emergence Mapping Protocol)

**File:** `protocols/adversarial/emp.cue`
**Package:** `package emp`
**Archetype:** Adversarial — uses full pressure loop

**Domain:** Composition effects — unexpected behavior at boundaries of composed canonical forms.

**Core question:** "We composed these canonical forms and something unexpected appeared — what is it and is it a problem?"

**Key structural insight:** EMP's Phase 2 candidates are proposed *explanations* of what the emergent behavior IS (not competing formalisms as in CFFP). The pressure in Phase 3 challenges these explanations via three mechanisms: reduction challenges (show the behavior IS predicted by one of the parts), scope challenges (show the emergence only occurs under specific conditions), composition counterexamples (show the composition works fine in related cases).

**Phase structure:**
1. Composition Declaration — which canonical forms are composed, the emergent behavior, the interaction boundary
2. Emergence Candidates — proposed explanations (interaction_effect | missing_constraint | unmodeled_dependency | genuine_novelty)
3. Pressure — reduction, scope, composition counterexample challenges
4. Survivor Derivation — same pattern
5. Phase 3b — zero survivors means explanation space needs revision
6. Phase 4 (conditional) — select among survivors
7. Impact Obligations — verify impact classification
8. Emergence Map — documented emergent behavior with classification and remediation path

**Skeleton to implement:**

```cue
package emp

#Protocol: {
    name:        "Emergence Mapping Protocol"
    version:     "0.1.0"
    description: "Composition emergence analysis. Maps unexpected behavior at canonical form boundaries."
}

#ComposedForm: {
    name:      string // name of the canonical form
    run_id:    string // the CFFP or equivalent run that produced it
    invariants: [...string]
}

#Phase1: {
    composed_forms:        [...#ComposedForm]
    composed_forms:        [_, _, ...] // at least two forms being composed
    emergent_behavior:     string      // the unexpected behavior observed
    interaction_boundary:  string      // where the forms interact / the seam
    // Is this behavior reproducible?
    reproducible: bool
    if !reproducible {
        reproducibility_notes: string
    }
    // Under what conditions was the emergence observed?
    observation_context: string
}

// Emergence candidates — proposed explanations for what the behavior IS.
// Each candidate must propose a causal account.
#EmergenceKind:
    "interaction_effect"       | // behavior arises from the interaction rule between forms
    "missing_constraint"       | // one or both forms lacks a constraint that would prevent this
    "unmodeled_dependency"     | // a shared dependency between forms was not modeled
    "genuine_novelty"            // the behavior cannot be reduced to any single form

#EmergenceCandidate: {
    id:            string
    kind:          #EmergenceKind
    description:   string
    causal_account: string // why this explanation produces the observed behavior
    // Is the behavior predicted by this explanation reducible to one of the composed forms?
    reducible_to?: string  // name of the composed form, if reducible
    predictions: [...{
        id:          string
        description: string // what else should be observable if this explanation is correct
        discriminating: bool
    }]
    predictions: [_, ...]
}

#Phase2: {
    candidates: [...#EmergenceCandidate]
    candidates: [_, ...]
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────

#EmergenceRebuttal: {
    kind:     "refutation" | "scope_narrowing"
    argument: string
    valid:    bool
    limitation_description?: string
}

// Reduction challenge: show the behavior IS predicted by one of the parts.
#ReductionChallenge: {
    id:               string
    target_candidate: string
    reduces_to:       string // which composed form explains the behavior
    argument:         string // how the form's invariants predict this behavior
    rebuttal?:        #EmergenceRebuttal
}

// Scope challenge: show the emergence only occurs under specific conditions.
#ScopeChallenge: {
    id:               string
    target_candidate: string
    restricted_to:    string // the conditions under which the behavior occurs
    argument:         string // why the behavior doesn't generalize beyond this scope
    rebuttal?:        #EmergenceRebuttal
}

// Composition counterexample: show the composition works fine in a related case.
#CompositionCE: {
    id:               string
    target_candidate: string
    related_case:     string // a related composition where the behavior does NOT occur
    minimal:          bool & true
    argument:         string // why this case undermines the candidate's explanation
    rebuttal?:        #EmergenceRebuttal
}

#Phase3: {
    reduction_challenges:       [...#ReductionChallenge]
    scope_challenges:           [...#ScopeChallenge]
    composition_counterexamples: [...#CompositionCE]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────

#EliminationReason:
    "reduction_unrebutted"             |
    "scope_challenge_unrebutted"       |
    "composition_ce_unrebutted"

#EliminatedExplanation: {
    candidate_id: string
    reason:       #EliminationReason
    source_id:    string
}

#SurvivorExplanation: {
    candidate_id:     string
    scope_narrowings: [...string]
}

#Derived: {
    eliminated: [...#EliminatedExplanation]
    survivors:  [...#SurvivorExplanation]
}

// ─── PHASE 3b: REVISION (conditional) ────────────────────────────────────────

#Phase3b: {
    triggered:  bool
    diagnosis:  "candidates_too_weak" | "behavior_not_emergent" | "observation_insufficient"
    resolution: "revise_candidates" | "close_as_non_emergent" | "gather_more_observations"
    notes:      string
}

// ─── PHASE 4: SELECTION (conditional) ────────────────────────────────────────

#Phase4: {
    multiple_survivors: bool
    if multiple_survivors {
        selected:        string
        selection_basis: string
        alternatives_rejected: [...{
            candidate_id: string
            reason:       string
        }]
    }
    final_candidate: string
}

// ─── PHASE 5: IMPACT OBLIGATIONS ─────────────────────────────────────────────
//
// Classify the emergent behavior: benign, degrading, or invalidating?
// And determine what remediation is required.

#ImpactClassification:
    "benign"       | // emergence does not threaten any invariant of composed forms
    "degrading"    | // emergence weakens guarantees without breaking invariants
    "invalidating"   // emergence breaks an invariant of one or more composed forms

#ImpactObligation: {
    property:  string
    argument:  string
    satisfied: bool
    if !satisfied {
        blocker: string
    }
}

#Phase5: {
    obligations:   [...#ImpactObligation]
    all_satisfied: bool
    impact:        #ImpactClassification
    impact_argument: string
}

// ─── PHASE 6: EMERGENCE MAP ───────────────────────────────────────────────────

#RemediationPath:
    "none_required"        | // benign — document and proceed
    "revise_one_form"      | // degrading or invalidating — specify which form needs revision
    "revise_both_forms"    | // invalidating — both composed forms need revision
    "add_composition_rule" | // the composition needs an explicit constraint added
    "separate_forms"         // the forms should not be composed as specified

#EmergenceMap: {
    emergent_behavior:         string
    adopted_explanation:       string // the surviving explanation
    impact:                    #ImpactClassification
    acknowledged_scope_limits: [...string] // from scope narrowings
    remediation:               #RemediationPath
    if remediation == "revise_one_form" || remediation == "revise_both_forms" {
        forms_requiring_revision: [...string]
        revision_guidance:        string
    }
    if remediation == "add_composition_rule" {
        rule_description: string
    }
    // What follow-on protocol runs does this emergence map authorize?
    downstream_protocols: [...{
        protocol: string // "CGP", "CFFP", etc.
        purpose:  string
    }]
}

#Phase6: {
    if outcome == "mapped" {
        emergence_map: #EmergenceMap
    }
    if outcome == "non_emergent" {
        reduction_record: string // which composed form fully explains the behavior
    }
    outcome: #Outcome
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "mapped" | "non_emergent" | "open"
// mapped       — emergence explained; impact classified; remediation path defined
// non_emergent — behavior reducible to one of the composed forms; not genuine emergence
// open         — surviving explanations remain; further evidence needed

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#EMPInstance: {
    protocol: #Protocol
    version:  string

    phase1: #Phase1
    phase2: #Phase2
    phase3: #Phase3

    derived: #Derived

    phase3b?: #Phase3b

    phase4?: #Phase4

    phase5: #Phase5
    phase6?: #Phase6

    outcome:       #Outcome
    outcome_notes: string
}
```

**Step 1: Write `protocols/adversarial/emp.cue`** with the full header comment and the skeleton above.

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/adversarial/emp.cue
```

**Step 3: Commit**
```bash
git add protocols/adversarial/emp.cue
git commit -m "feat: add EMP (Emergence Mapping Protocol) v0.1.0"
```

---

### Task 12: Write OVP (Observation Validation Protocol)

**File:** `protocols/evaluative/ovp.cue`
**Package:** `package ovp`
**Archetype:** Evaluative — inputs → assessment → verdict. No adversarial loop.

**Domain:** Empirical grounding. "Is this observation real as described, or is it an artifact?"

**Design note:** OVP gates HEP. OVP's validated output becomes HEP's phenomenon input. OVP is NOT adversarial — it does not pit candidates against each other. It evaluates a single observation against validity criteria.

**Phase structure:**
1. Observation Intake — claimed phenomenon, measurement method, context, reproducibility
2. Validity Assessment — evaluate against: measurement validity, selection bias, confounding factors, sample adequacy, reporting accuracy, reproducibility
3. Challenge Generation — construct specific validity challenges as structured findings
4. Verdict — validated / contested / artifact

```cue
package ovp

#Protocol: {
    name:        "Observation Validation Protocol"
    version:     "0.1.0"
    description: "Empirical observation validation. Gates HEP — validates that phenomena are real before hypothesis elimination begins."
}

#Phase1: {
    phenomenon:          string  // what was claimed to be observed
    measurement_method:  string  // how the observation was made
    context:             string  // conditions, environment, when
    reproducible:        bool
    if !reproducible {
        reproducibility_notes: string
    }
    claim_source:        string  // who/what made the original claim
    prior_validations:   [...string] // prior attempts to validate this observation, if any
}

#ValidityCriterion:
    "measurement_validity"  | // the measurement instrument is appropriate
    "selection_bias"        | // the sample was not systematically biased
    "confounding_factors"   | // no confound explains the observation better
    "sample_adequacy"       | // sample size/diversity is sufficient
    "reporting_accuracy"    | // the observation was accurately reported
    "reproducibility"         // the observation can be reproduced

#ValidityEvaluation: {
    criterion:   #ValidityCriterion
    verdict:     "passes" | "fails" | "indeterminate"
    argument:    string
    if verdict == "fails" {
        severity:        "fatal" | "significant" | "minor"
        // fatal      — the observation cannot be trusted
        // significant — the observation is questionable; caveats required
        // minor       — the observation is probably real; document the concern
        artifact_hypothesis: string // what might explain the observation as an artifact
    }
}

#Phase2: {
    evaluations: [...#ValidityEvaluation]
    // All six criteria must be evaluated or skipped with justification.
    skipped_criteria: [...{
        criterion:  #ValidityCriterion
        justification: string
    }]
    summary: string
}

#ValidityChallenge: {
    id:          string
    kind:        #ValidityCriterion // which criterion this challenges
    argument:    string // specific challenge to the observation's validity
    severity:    "fatal" | "significant" | "minor"
    // What would need to be true for this challenge to be resolved?
    resolution_condition: string
}

#Phase3: {
    challenges: [...#ValidityChallenge]
    // Evaluator's synthesis: do the challenges, taken together, undermine the observation?
    aggregate_assessment: string
}

#OVPVerdict: "validated" | "contested" | "artifact"
// validated — observation is real as described; can serve as HEP input
// contested  — significant validity concerns; observation may be real but requires caveats
// artifact   — observation is an artifact of measurement or methodology

#Phase4: {
    verdict:             #OVPVerdict
    rationale:           string
    if verdict == "validated" {
        // The validated observation record for downstream HEP use.
        validated_observation: {
            phenomenon:   string
            confidence:   "high" | "medium"
            caveats:      [...string] // any residual concerns to carry into HEP
        }
    }
    if verdict == "contested" {
        // What would upgrade this to validated?
        validation_path: string
        // Can this be used as HEP input despite concerns?
        usable_with_caveats: bool
        if usable_with_caveats {
            required_caveats: [...string]
        }
    }
    if verdict == "artifact" {
        // What does the observation actually show?
        artifact_explanation: string
        // What genuine phenomenon (if any) does the artifact point toward?
        underlying_signal?: string
    }
}

#Outcome: "validated" | "contested" | "artifact"

#OVPInstance: {
    protocol: #Protocol
    version:  string

    phase1: #Phase1
    phase2: #Phase2
    phase3: #Phase3
    phase4: #Phase4

    outcome:       #Outcome
    outcome_notes: string
}
```

**Step 1: Write `protocols/evaluative/ovp.cue`** with header comment and skeleton.

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/evaluative/ovp.cue
```

**Step 3: Commit**
```bash
git add protocols/evaluative/ovp.cue
git commit -m "feat: add OVP (Observation Validation Protocol) v0.1.0"
```

---

### Task 13: Write PTP (Prioritization Triage Protocol)

**File:** `protocols/evaluative/ptp.cue`
**Package:** `package ptp`
**Archetype:** Evaluative — inputs → criteria declaration → assessment → ranking. No adversarial loop.

**Domain:** Resource-constrained path selection. "Which valid option first?"

**Design note from build prompt:** "PTP is evaluative, not adversarial. There's no 'wrong' option — all inputs are assumed valid. The question is strategic, not epistemic." If this feels too thin, it may be demoted to governance alongside routing and recording. Implement it as a protocol first.

**Phase structure:**
1. Option Intake — valid options + resource constraints
2. Criteria Declaration — what dimensions matter + weights/priority ordering
3. Option Assessment — evaluate each option against each criterion
4. Ranking — ranked priority with rationale + sensitivity analysis
5. Decision Record — ranking, rationale, what was deprioritized, re-evaluation conditions

```cue
package ptp

#Protocol: {
    name:        "Prioritization Triage Protocol"
    version:     "0.1.0"
    description: "Resource-constrained path selection. All options are valid; PTP ranks them strategically."
}

#Option: {
    id:          string
    description: string
    kind:        "canonical_form" | "protocol_run" | "implementation_path" | "other"
    // What is the expected output or value of choosing this option?
    expected_value: string
    // What dependencies must exist before this option can be executed?
    dependencies:   [...string]
    // Is this option reversible if chosen and then abandoned?
    reversible:     bool
    if !reversible {
        irreversibility_notes: string
    }
}

#ResourceConstraint: {
    kind:        "time" | "effort" | "budget" | "attention" | "dependency_order"
    description: string
    limit:       string // the actual constraint value (e.g. "2 weeks", "one sprint")
}

#Phase1: {
    options:     [...#Option]
    options:     [_, _, ...] // at least two required — ranking a single option is trivial
    constraints: [...#ResourceConstraint]
}

#Criterion: {
    id:          string
    name:        string
    description: string
    // Weight: relative importance of this criterion.
    // Either express as explicit weight (higher = more important) or use ordering.
    weight?:     uint // explicit numeric weight
    // What evidence or argument supports this weight assignment?
    weight_rationale: string
}

#Phase2: {
    criteria:        [...#Criterion]
    criteria:        [_, ...] // at least one criterion required
    // Are criteria weights explicit (numeric) or ordinal (ranked)?
    weighting_approach: "numeric" | "ordinal"
    // What constraints drove the criteria selection?
    criteria_rationale: string
}

#CriterionScore: {
    criterion_id: string
    option_id:    string
    score:        "high" | "medium" | "low" | "unknown"
    argument:     string // why this option scores this way on this criterion
}

#Phase3: {
    scores: [...#CriterionScore]
    // All option × criterion combinations must be scored.
    coverage_argument: string // confirmation that all combinations were assessed
}

#RankedOption: {
    rank:        uint
    option_id:   string
    rationale:   string // why this option is ranked here
    // How sensitive is this ranking to weight changes?
    sensitivity: "stable" | "unstable"
    if sensitivity == "unstable" {
        sensitivity_notes: string // which weight change would change the rank
    }
}

#Phase4: {
    ranked_options:     [...#RankedOption]
    ranked_options:     [_, ...]
    // Sensitivity analysis summary: how robust is the top ranking?
    sensitivity_summary: string
    // What would change the top-ranked option?
    top_rank_vulnerabilities: [...string]
}

#DeprioritizedRecord: {
    option_id: string
    reason:    string // why this option was ranked below others
    // Under what conditions should this be re-evaluated?
    re_evaluation_conditions: string
}

#Phase5: {
    decision:         string // plain-language summary of the ranking
    top_choice:       string // option_id
    top_rationale:    string
    deprioritized:    [...#DeprioritizedRecord]
    // When should this ranking be revisited?
    re_evaluation_trigger: string
    // Are there conditions under which the ranking should NOT be followed?
    override_conditions: string
}

#Outcome: "ranked" | "tied" | "insufficient_data"
// ranked           — a clear ranking was produced
// tied             — two or more options are genuinely equivalent; additional criteria needed
// insufficient_data — criteria cannot be scored without more information

#PTPInstance: {
    protocol: #Protocol
    version:  string

    phase1: #Phase1
    phase2: #Phase2
    phase3: #Phase3
    phase4: #Phase4
    phase5: #Phase5

    outcome:       #Outcome
    outcome_notes: string
}
```

**Step 1: Write `protocols/evaluative/ptp.cue`** with header comment and skeleton.

**Step 2: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/protocols/evaluative/ptp.cue
```

**Step 3: Commit**
```bash
git add protocols/evaluative/ptp.cue
git commit -m "feat: add PTP (Prioritization Triage Protocol) v0.1.0"
```

---

## Phase 6: Extract dialectics.cue

**This is done LAST.** The current `dialectics.cue` file contains the build prompt document. Phase 6 replaces it with the formal CUE kernel extracted from reading all protocol files.

### Task 14: Write dialectics.cue

**File:** `dialectics.cue` (overwrite the current build prompt content)
**Package:** `package dialectics`

The kernel defines:
1. The primitive dialectical structures shared by all adversarial protocols
2. Archetype contracts (`#Adversarial`, `#Evaluative`, `#Exploratory`)
3. Suite-level constraints (edge integrity, recordability, routing completeness)
4. A `#Run` type that every protocol execution must satisfy

**Reading checklist** — before writing, verify these types are consistent across ALL adversarial protocols by re-reading each:
- `#Rebuttal`: `{ kind: "refutation" | "scope_narrowing", argument, valid, limitation_description? }` — CFFP, CDP, CBP, HEP (+ `evidence_unreliability`), ATP, EMP
- `#Challenge`: targeted pressure with rebuttal slot — present in all adversarial Phase 3s
- `#Derived`: `{ eliminated, survivors }` — present in all adversarial protocols
- `#EliminationRecord`: `{ candidate_id (or domain variant), reason, source_id }`
- `#SurvivorRecord`: `{ candidate_id, scope_narrowings }`
- Obligation Gate: `Phase5.obligations: [...{ property, argument, satisfied, blocker? }]`
- Revision Loop: `Phase3b: { triggered, diagnosis, resolution, notes }`

**dialectics.cue skeleton:**

```cue
// dialectics.cue — The Dialectic Kernel
// Version: 0.1.0
//
// This file defines the formal theory of structured disagreement resolution.
// It contains zero domain-specific knowledge. It knows nothing about
// "formalism", "invariant", "hypothesis", or "canonical form".
// Those are protocol-layer concerns.
//
// What this file knows:
//   - The Rebuttal: the atomic dialectic primitive
//   - The Challenge: adversarial pressure with a rebuttal slot
//   - The Derivation: mechanical survivor determination
//   - The Obligation Gate: proof requirements before adoption
//   - The Revision Loop: zero-survivor feedback
//   - The Finding: structured epistemic output
//   - Archetype contracts: what any adversarial/evaluative/exploratory protocol must satisfy
//   - Suite constraints: what the protocol collection must satisfy as a whole
//
// Protocols import from this file via the types they must satisfy.
// This file does NOT import from any protocol.

package dialectics

// ─── THE REBUTTAL ────────────────────────────────────────────────────────────
//
// The atomic dialectic primitive. Present in every adversarial protocol.
//
// "refutation"     — the pressure is incorrect. Claim stands.
// "scope_narrowing" — the pressure is correct. Candidate retreats from this case.
//                    Retreat is recorded as an acknowledged limitation.
//
// A scope_narrowing is always valid by definition — the candidate is conceding.
// valid: true must still be set explicitly.
// The distinction matters: refutations leave no trace; scope_narrowings accumulate.

#Rebuttal: {
    kind:     "refutation" | "scope_narrowing"
    argument: string
    valid:    bool
    limitation_description?: string // required when kind is "scope_narrowing"
}

// HEP extends #Rebuttal with "evidence_unreliability" for evidence-driven pressure.
// This extension is declared at the HEP protocol layer, not here.

// ─── THE CHALLENGE ───────────────────────────────────────────────────────────
//
// Targeted adversarial pressure with a rebuttal slot.
// Every adversarial protocol's Phase 3 is a collection of challenges.
// The challenge types differ by protocol; the structure is the same.

#Challenge: {
    id:               string
    target_candidate: string
    argument:         string
    minimal:          bool | *false  // for counterexample-type challenges: must be true
    rebuttal?:        #Rebuttal
}

// ─── THE DERIVATION ──────────────────────────────────────────────────────────
//
// Mechanical survivor determination. Populated after Phase 3.
// A candidate is eliminated if any challenge targeting it has no valid rebuttal.
// Survivors carry scope_narrowings accumulated during Phase 3.

#EliminationRecord: {
    candidate_id: string
    reason:       string // protocol-specific elimination reason
    source_id:    string // id of the challenge that caused elimination
}

#SurvivorRecord: {
    candidate_id:     string
    scope_narrowings: [...string] // from scope_narrowing rebuttals; become acknowledged limitations
}

#Derivation: {
    eliminated: [...#EliminationRecord]
    survivors:  [...#SurvivorRecord]
}

// ─── THE OBLIGATION GATE ─────────────────────────────────────────────────────
//
// Proof obligations that must be satisfied before adoption.
// Present in adversarial Phase 5 and some evaluative protocols.
// An unsatisfied obligation blocks completion.

#Obligation: {
    property:  string
    argument:  string
    satisfied: bool
    if !satisfied {
        blocker: string
    }
}

#ObligationGate: {
    obligations:   [...#Obligation]
    all_satisfied: bool
}

// ─── THE REVISION LOOP ───────────────────────────────────────────────────────
//
// Zero-survivor feedback. Makes the system self-correcting.
// If nothing survives, the problem is harder than assumed.
// Diagnose and restart.

#RevisionLoop: {
    triggered:  bool
    diagnosis:  string // protocol-specific diagnosis
    resolution: string // protocol-specific resolution
    notes:      string
}

// ─── THE FINDING ─────────────────────────────────────────────────────────────
//
// Structured epistemic output. All protocol runs produce findings.
// Findings vary by protocol; their structure is uniform.

#FindingKind:
    "contradiction"   | // two claims cannot both be true
    "gap"             | // something expected is missing
    "ambiguity"       | // a claim could mean multiple things
    "decision"        | // a choice was made with explicit rationale
    "dependency"      | // a relation between protocol outputs
    "risk"            | // a potential failure mode
    "limitation"        // a known scope boundary

#Finding: {
    kind:      #FindingKind
    content:   string
    severity?: "fatal" | "significant" | "minor"
    source?:   string // which phase or challenge produced this finding
}

// ─── ARCHETYPE CONTRACTS ─────────────────────────────────────────────────────
//
// Every protocol must satisfy exactly one archetype contract.
// Contracts specify the MINIMUM required structural elements.
// Protocols may add domain-specific fields beyond the minimum.

// An adversarial protocol must have:
//   - A candidate input phase (Phase 2)
//   - A pressure phase (Phase 3) with challenges
//   - A derivation (populated after Phase 3)
//   - An obligation gate (Phase 5)
//   - A revision loop (Phase 3b, conditional)
//   - An adoption phase (Phase 6)
#Adversarial: {
    has_candidates:      bool & true
    has_pressure:        bool & true
    has_derivation:      bool & true
    has_obligation_gate: bool & true
    has_revision_loop:   bool & true
    has_adoption:        bool & true
}

// An evaluative protocol must have:
//   - A subject input phase
//   - Criteria or obligations to evaluate against
//   - An assessment phase
//   - A verdict phase
#Evaluative: {
    has_subject:     bool & true
    has_criteria:    bool & true
    has_assessment:  bool & true
    has_verdict:     bool & true
}

// An exploratory protocol must have:
//   - A subject input (open-ended)
//   - Multiple rounds or perspectives
//   - A referee or synthesis mechanism
//   - A map or output structure
#Exploratory: {
    has_subject:   bool & true
    has_rounds:    bool & true
    has_referee:   bool & true
    has_map:       bool & true
}

// ─── SUITE CONSTRAINTS ───────────────────────────────────────────────────────
//
// Constraints that the protocol COLLECTION must satisfy.
// Not enforceable by individual protocol files — evaluated at suite level.

// Every protocol in the suite must be:
//   - Routable (governance/routing.cue covers it)
//   - Recordable (governance/recording.cue can project its output)
//   - Reachable (some other protocol or direct use can trigger it)

#SuiteProtocol:
    "AAP" | "ADP" | "ATP" | "CBP" | "CDP" | "CFFP" | "CGP" |
    "EMP" | "HEP" | "IFA" | "OVP" | "PTP" | "RCP"

#SuiteConstraints: {
    // All protocols are routable
    routing_complete: bool & true
    // All protocols are recordable
    recording_complete: bool & true
    // Every protocol has at least one known trigger (structural feature or upstream protocol)
    reachability_complete: bool & true
}

// ─── RUN VALIDATION ──────────────────────────────────────────────────────────
//
// A #Run is the minimum structure any protocol execution must satisfy.
// Protocols embed their specific types within these fields.

#Run: {
    protocol_name:    #SuiteProtocol
    run_id:           string
    version:          string
    started:          string // ISO 8601
    completed?:       string // ISO 8601 — absent if run is not yet complete
    outcome:          string // protocol-specific outcome value
    outcome_notes:    string
    // Can this run be projected into a governance/recording.cue #Record?
    recordable:       bool & true
}
```

**Step 1: Read every protocol file one more time.** Confirm the extracted primitives are consistent with the actual implementations. Pay special attention to:
- `#Rebuttal` structure (check all 6 adversarial protocols)
- `#Derivation` pattern (especially HEP's `source_id` vs `source_ids` fix from Task 4)
- `#ObligationGate` (Phase 5 in adversarial, Phase 3/4 in evaluative)
- `#RevisionLoop` (Phase 3b trigger conditions)

**Step 2: Write `dialectics.cue`** replacing the current build prompt content with the skeleton above. The skeleton above is complete but may need minor adjustments after the cross-protocol review in Step 1.

**Step 3: Validate**
```bash
cue vet /Users/bwb/src/riverline/dialectics/dialectics.cue
```

**Step 4: Commit**
```bash
git add dialectics.cue
git commit -m "feat: extract dialectics.cue kernel (v0.1.0) — pure dialectical structure"
```

---

## Phase 7: Full Validation + Example Runs

### Task 15: Validate all files

**Step 1: Validate every file**
```bash
# Adversarial
cue vet protocols/adversarial/cffp.cue
cue vet protocols/adversarial/cdp.cue
cue vet protocols/adversarial/cbp.cue
cue vet protocols/adversarial/hep.cue
cue vet protocols/adversarial/atp.cue
cue vet protocols/adversarial/emp.cue

# Evaluative
cue vet protocols/evaluative/aap.cue
cue vet protocols/evaluative/ifa.cue
cue vet protocols/evaluative/rcp.cue
cue vet protocols/evaluative/cgp.cue
cue vet protocols/evaluative/ovp.cue
cue vet protocols/evaluative/ptp.cue

# Exploratory
cue vet protocols/exploratory/adp.cue

# Governance
cue vet governance/routing.cue
cue vet governance/recording.cue

# Kernel
cue vet dialectics.cue
```
Expected: no output (all pass).

**Step 2: Fix any validation errors** that appear. Common CUE issues to watch for:
- Conditional fields using `if` on non-bool expressions — CUE's `if` requires bool
- Referencing `outcome` in a `#Phase6` body when `outcome` is defined at the instance level — move the reference to the instance type
- `[_, ...]` on list fields — valid CUE for "at least one element"
- `bool & true` — valid CUE for "must be true"; don't simplify to `true` (loses expressiveness as a struct field)

### Task 16: Write example run instances

Create one concrete (fully populated) example run per protocol. These serve as:
1. Proof that the type accepts valid data
2. Documentation for agents on how to instantiate the protocol

**File naming convention:** `examples/runs/<PROTOCOL>-example-01.cue`

For each example, the file should:
- Import the protocol package (use `package <protocol>_example`)
- Declare a variable that is typed as `#<PROTOCOL>Instance`
- Populate all required fields with plausible values
- Use `cue vet --concrete <file>` to validate

**Example for CFFP** (`examples/runs/cffp-example-01.cue`):

```cue
// Example CFFP run: formalizing "evaluation order" for a hypothetical system.
// This demonstrates a run that reaches outcome "canonical".
package cffp_example

import "dialectics/protocols/adversarial/cffp"

_run: cffp.#CFFPInstance & {
    protocol: cffp.#Protocol
    construct: {
        name:        "evaluation_order"
        description: "The order in which expressions in a system are evaluated."
        depends_on:  []
    }
    version: "1.0"
    phase1: {
        invariants: [
            {
                id:         "I1"
                description: "Evaluation always terminates for finite inputs."
                testable:    true
                structural:  true
                class:       "termination"
            },
            {
                id:          "I2"
                description: "Identical inputs always produce identical evaluation orders."
                testable:    true
                structural:  true
                class:       "determinism"
            },
        ]
    }
    phase2: {
        candidates: [
            {
                id:          "C1"
                description: "Left-to-right strict evaluation"
                formalism: {
                    structure:       "Expressions are evaluated from left to right, outermost-first."
                    evaluation_rule: "eval(e1, e2) = strict(eval(e1), eval(e2))"
                    resolution_rule: "No ambiguity — order is fixed."
                }
                claims: [
                    { invariant_id: "I1", argument: "Strict evaluation terminates if all sub-expressions terminate." },
                    { invariant_id: "I2", argument: "Fixed left-to-right order is deterministic by construction." },
                ]
                complexity: { time: "O(n)", space: "O(depth)", static: "O(n)" }
                failure_modes: []
            },
        ]
    }
    phase3: {
        counterexamples:     []
        composition_failures: []
    }
    derived: {
        eliminated: []
        survivors: [
            { candidate_id: "C1", scope_narrowings: [] },
        ]
    }
    phase5: {
        obligations: [
            {
                property:  "All claimed invariants hold under the evaluation rule"
                argument:  "Left-to-right strict evaluation trivially satisfies termination and determinism."
                provable:  true
            },
        ]
        all_provable: true
    }
    phase6: {
        canonical: {
            construct:        "evaluation_order"
            formal_statement: "Left-to-right strict evaluation: eval(e1, e2) = strict(eval(e1), eval(e2))"
            evaluation_def:   "Evaluate e1 fully, then evaluate e2 fully, then combine."
            satisfies:        ["I1", "I2"]
            acknowledged_limitations: []
        }
    }
    outcome:       "canonical"
    outcome_notes: "Single candidate survived with no pressure; adopted directly."
}
```

**Validation command:**
```bash
cue vet --concrete examples/runs/cffp-example-01.cue
```

Write similar example files for:
- `examples/runs/cgp-example-01.cue` — a revision case
- `examples/runs/atp-example-01.cue` — a validated analogy transfer
- `examples/runs/ovp-example-01.cue` — a validated observation
- `examples/runs/routing-example-01.cue` — a routing result (from governance/routing.cue types)

**Note on imports:** CUE module imports require a `cue.mod/module.cue` file. If import paths don't work, either:
1. Initialize a CUE module: `cue mod init dialectics`
2. Or put the example in the same package as the protocol (simplest for validation)

**Step 1: Write all example files**

**Step 2: Validate with `--concrete`**
```bash
cue vet --concrete examples/runs/cffp-example-01.cue
# ... for each example
```

**Step 3: Fix any type errors revealed by concrete instances** (concrete validation catches issues abstract validation misses — e.g., conditional fields that are required in practice)

**Step 4: Final commit**
```bash
git add examples/
git commit -m "feat: add example run instances for Phase 7 validation"
```

---

## Execution Order Summary

| Task | Phase | Action | Files Touched |
|------|-------|--------|---------------|
| 1 | 1 | Move CFFP | protocols/adversarial/cffp.cue |
| 2 | 1 | Move+clean CDP | protocols/adversarial/cdp.cue |
| 3 | 1 | Move+clean CBP | protocols/adversarial/cbp.cue |
| 4 | 1 | Move+fix HEP | protocols/adversarial/hep.cue |
| 5 | 1 | Move evaluatives | protocols/evaluative/aap,ifa,rcp.cue |
| 6 | 1 | Move ADP | protocols/exploratory/adp.cue |
| 7 | 2 | Create CGP | protocols/evaluative/cgp.cue, delete rpp+djp |
| 8 | 3 | Create routing | governance/routing.cue, delete psp |
| 9 | 4 | Create recording | governance/recording.cue, delete arp |
| 10 | 5a | Create ATP | protocols/adversarial/atp.cue |
| 11 | 5b | Create EMP | protocols/adversarial/emp.cue |
| 12 | 5c | Create OVP | protocols/evaluative/ovp.cue |
| 13 | 5d | Create PTP | protocols/evaluative/ptp.cue |
| 14 | 6 | Extract kernel | dialectics.cue |
| 15 | 7 | Validate all | all files |
| 16 | 7 | Example runs | examples/runs/ |

**Critical constraint:** Task 14 (dialectics.cue) MUST come after all protocol files are complete and validated. The kernel is extracted FROM the protocols, not the other way around.
