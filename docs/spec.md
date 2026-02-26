# Dialectics Spec

Machine-readable specification for the Riverline Dialectics framework.
Each section contains a CUE file defining either the kernel, a governance
layer, or a dialectical protocol.

## Kernel

### dialectics.cue — The Dialectic Kernel

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
//   - The Rebuttal        — the atomic dialectic primitive
//   - The Challenge       — adversarial pressure with a rebuttal slot
//   - The Derivation      — mechanical survivor determination
//   - The Obligation Gate — proof requirements before adoption
//   - The Revision Loop   — zero-survivor feedback
//   - The Finding         — structured epistemic output
//   - Archetype contracts — what any adversarial/evaluative/exploratory protocol must satisfy
//   - Suite constraints   — what the protocol collection must satisfy as a whole
//
// Protocols are instantiations of the archetypes defined here.
// This file does NOT import from any protocol.
//
// An agent reading this file should be able to:
//   - Understand the shared logic across all adversarial protocols
//   - Verify that a new protocol satisfies its archetype contract
//   - Understand what "scope narrowing" means formally and why it matters
//   - Understand the obligation gate as the anti-shortcut mechanism
//   - Understand the revision loop as the self-correction mechanism

package dialectics

// ─── THE REBUTTAL ────────────────────────────────────────────────────────────
//
// The atomic dialectic primitive. Every adversarial protocol uses this.
//
// Two kinds:
//
//   "refutation"      — the pressure is incorrect given the candidate's formalism.
//                       The candidate's claim stands. The challenge is dismissed.
//                       Leaves no trace in the survivor record.
//
//   "scope_narrowing" — the pressure is correct. The candidate retreats from
//                       the case the challenge targets. The candidate survives,
//                       but the retreat is recorded as an acknowledged limitation.
//                       This is semantically distinct from refutation: the candidate
//                       did not defeat the pressure, it withdrew from it.
//
// A scope_narrowing rebuttal is always valid by definition — the candidate is
// conceding the point, not disputing it. valid: true must still be set explicitly
// to make the concession unambiguous.
//
// The distinction matters downstream: refutations leave no trace;
// scope_narrowings accumulate and become acknowledged limitations in the
// protocol's final output.

#Rebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	// Required when kind is "scope_narrowing": what scope was excluded.
	// This text becomes an entry in the survivor's scope_narrowings list.
	limitation_description?: string
}

// HEP extends #Rebuttal with "evidence_unreliability" for evidence-driven pressure.
// ATP and EMP use #Rebuttal directly.
// These extensions are declared at the protocol layer, not here.

// ─── THE CHALLENGE ───────────────────────────────────────────────────────────
//
// Targeted adversarial pressure against a candidate, with a rebuttal slot.
// Every adversarial protocol's Phase 3 is a collection of challenges.
// The challenge TYPES differ by protocol; the structure is the same.
//
// "minimal" is required for counterexample-type challenges where the challenge
// is a concrete case demonstrating a violation. It must be explicitly asserted
// true — a non-minimal counterexample is inadmissible.
//
// Challenges without a rebuttal slot (e.g., composition failures in CFFP)
// are protocol-specific extensions that omit the rebuttal field because
// they are structurally irrebuttable.

#Challenge: {
	id:               string
	target_candidate: string
	argument:         string
	minimal:          bool | *false // must be true for counterexample-type challenges
	rebuttal?:        #Rebuttal
}

// ─── THE DERIVATION ──────────────────────────────────────────────────────────
//
// Mechanical survivor determination. Populated after Phase 3.
// Must be populated before Phase 4 can proceed.
//
// A candidate is eliminated if ANY challenge targeting it has no valid rebuttal.
// Survivors are all candidates not eliminated by any challenge.
// A run with zero survivors proceeds to the revision loop, not to Phase 4.
//
// Elimination and survival are recorded explicitly — not inferred from comments.

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
// Proof obligations that must be satisfied before a survivor is adopted.
// This is the anti-hallucination mechanism: a run cannot close as long as
// any obligation has satisfied: false.
//
// Obligations are argued, not tested. Each must have a prose argument
// that a reviewer can evaluate for soundness.

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
// Zero-survivor feedback. Triggered when Phase 3 eliminates all candidates.
// Zero survivors is not failure — it means the problem is harder than assumed.
// The revision loop diagnoses WHY nothing survived and determines where to restart.
//
// Each protocol has its own diagnosis and resolution vocabulary.
// The abstract structure is the same across all adversarial protocols.

#RevisionLoop: {
	triggered:  bool
	diagnosis:  string // protocol-specific diagnosis enum
	resolution: string // protocol-specific resolution enum
	notes:      string
}

// ─── THE FINDING ─────────────────────────────────────────────────────────────
//
// Structured epistemic output. All protocol runs produce findings.
// Findings characterize what was learned, not what was built.

#FindingKind:
	"contradiction" | // two claims cannot both be true
	"gap"           | // something expected is missing
	"ambiguity"     | // a claim could mean multiple things
	"decision"      | // a choice was made with explicit rationale
	"dependency"    | // a relation between protocol outputs
	"risk"          | // a potential failure mode
	"limitation"      // a known scope boundary

#Finding: {
	kind:      #FindingKind
	content:   string
	severity?: "fatal" | "significant" | "minor"
	source?:   string
}

// ─── ARCHETYPE CONTRACTS ─────────────────────────────────────────────────────
//
// Every protocol belongs to exactly one archetype.
// The archetype contract specifies the MINIMUM structural elements required.
// Protocols may add domain-specific phases beyond the minimum.
//
// These are documentation contracts enforced by convention and suite review,
// not by CUE's type system across packages.

// Adversarial protocols: CFFP, CDP, CBP, HEP, ATP, EMP
#Adversarial: {
	has_candidates:      bool & true
	has_pressure:        bool & true
	has_derivation:      bool & true
	has_revision_loop:   bool & true
	has_selection:       bool & true
	has_obligation_gate: bool & true
	has_adoption:        bool & true
}

// Evaluative protocols: AAP, IFA, RCP, CGP, OVP, PTP
#Evaluative: {
	has_subject:    bool & true
	has_criteria:   bool & true
	has_assessment: bool & true
	has_verdict:    bool & true
}

// Exploratory protocols: ADP
#Exploratory: {
	has_subject:  bool & true
	has_rounds:   bool & true
	has_referee:  bool & true
	has_map:      bool & true
}

// ─── KNOWN PROTOCOLS ─────────────────────────────────────────────────────────

#KnownProtocol:
	"AAP" | "ADP" | "ATP" | "CBP" | "CDP" | "CFFP" | "CGP" |
	"EMP" | "HEP" | "IFA" | "OVP" | "PTP" | "RCP"

// ─── SUITE CONSTRAINTS ───────────────────────────────────────────────────────
//
// Invariants the protocol collection must maintain:
//
//   routing_complete     — governance/routing.cue covers every #KnownProtocol
//   recording_complete   — governance/recording.cue can project any run into a #Record
//   reachability_complete — every protocol has at least one known trigger

#SuiteConstraints: {
	routing_complete:      bool & true
	recording_complete:    bool & true
	reachability_complete: bool & true
}

// ─── RUN VALIDATION ──────────────────────────────────────────────────────────
//
// The minimum structure any protocol execution must satisfy.
// Every completed run must be projectable into a governance/recording.cue #Record.

#Run: {
	protocol_name:  #KnownProtocol
	run_id:         string
	version:        string
	started:        string  // ISO 8601
	completed?:     string  // ISO 8601 — absent if run is not yet complete
	outcome:        string  // protocol-specific outcome value
	outcome_notes:  string
	// Assertion that this run can be projected into a #Record.
	recordable:     bool & true
}

```

## Governance

### Governance: Protocol Routing

```cue
// Governance: Protocol Routing
// Version: 0.1.0
//
// Routing determines which protocol(s) to run for a given problem.
// This was previously PSP (Protocol Selection Protocol). Promoted to
// governance because routing is type matching, not adjudication.
//
// Usage: populate a #RoutingInput, then use #RoutingTable and
// #DisambiguationRules to determine which protocols apply.
// Sequencing rules determine order when multiple protocols must run.
//
// An agent reading this file should be able to:
//   - Classify a raw problem by its structural features
//   - Map features to candidate protocols using the routing table
//   - Apply disambiguation rules when multiple protocols could apply
//   - Produce a #RoutingResult without running a full protocol phase cycle

package routing

// ─── STRUCTURAL FEATURES ─────────────────────────────────────────────────────
//
// A structural feature is an observable property of the problem that
// indicates which protocol family is appropriate.

#StructuralFeature:
	"term_inconsistency"          | // term used differently across contexts → CBP
	"competing_candidates"        | // multiple formalisms competing → CFFP
	"unknown_design_space"        | // design space not yet understood → ADP
	"argument_fragility"          | // existing argument needs stress-testing → AAP
	"construct_incoherence"       | // construct seems to be two things → CDP
	"causal_ambiguity"            | // multiple explanations for phenomenon → HEP
	"cross_run_conflict"          | // independent runs need reconciling → RCP
	"implementation_gap"          | // implementation vs canonical dispute → IFA
	"revision_pressure"           | // canonical form proposed for change → CGP
	"deprecation_pressure"        | // canonical form proposed for retirement → CGP
	"structural_transfer"         | // cross-domain analogy being claimed → ATP
	"composition_emergence"       | // unexpected behavior at component seams → EMP
	"observation_validity"        | // empirical claim needs validation → OVP
	"resource_constrained_choice"   // multiple valid paths, finite resources → PTP

// ─── KNOWN PROTOCOLS ─────────────────────────────────────────────────────────

#KnownProtocol:
	"AAP" | "ADP" | "ATP" | "CBP" | "CDP" | "CFFP" | "CGP" |
	"EMP" | "HEP" | "IFA" | "OVP" | "PTP" | "RCP"

// ─── FEATURE TO PROTOCOL MAPPING ─────────────────────────────────────────────

// Each entry maps one structural feature to its primary protocol.
#FeatureProtocolMapping: {
	feature:          #StructuralFeature
	primary_protocol: #KnownProtocol
	confidence:       "high" | "medium" | "low"
	conditions:       string // when this mapping is valid
	exceptions:       string // when a different protocol is more appropriate
	prerequisites:    [...#KnownProtocol]
}

// ─── DISAMBIGUATION RULES ────────────────────────────────────────────────────
//
// When multiple features co-occur, these rules resolve ambiguity.
// Applied in order — first matching rule wins.

#DisambiguationRule: {
	when:            [...#StructuralFeature] // these features co-occur
	prefer:          #KnownProtocol          // prefer this protocol first
	because:         string
	run_other_after: bool
	other_protocol?: #KnownProtocol
}

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
	rationale:     string
	warnings:      [...string]
	outcome:       "routed" | "ambiguous" | "unroutable"
	outcome_notes: string
}

```

### Governance: Protocol Run Recording

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
	"term_ambiguity"        |
	"candidate_selection"   |
	"assumption_audit"      |
	"design_mapping"        |
	"construct_repair"      |
	"implementation_check"  |
	"governance_case"       | // was revision_proposal + deprecation_case; now CGP
	"cross_run_conflict"    |
	"analogy_transfer"      | // ATP
	"composition_emergence" | // EMP
	"observation_validity"  | // OVP
	"prioritization"          // PTP

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

## Adversarial Protocols

### Constraint-First Formalization Protocol (CFFP)

```cue
// Constraint-First Formalization Protocol (CFFP)
// Version: 0.2.1
//
// Changes from 0.2.0:
//   - #Rebuttal: added kind field ("refutation" | "scope_narrowing") with
//     full semantics. Scope-narrowing rebuttals are structurally distinguished
//     from refutations and carry a limitation_description that feeds Phase 6.
//   - #Derived: explicit survivor derivation types (#Eliminated, #Survivor,
//     #Derived) replacing the informal comment. #CFFPInstance now requires
//     derived to be populated before Phase 4 proceeds.
//   - #EliminationReason: enumerated elimination causes for mechanical clarity.
//   - #Survivor: carries scope_narrowings accumulated during Phase 3, which
//     become acknowledged_limitations in the canonical form.
//
// CFFP is not a debate protocol. There are no personas, no stakeholders,
// no consensus-building. The only participants are candidate formalisms
// and the invariants that kill them.
//
// The protocol produces one of three outcomes:
//   canonical   — one candidate survived all pressure; formal definition adopted
//   collapse    — multiple survivors merged into a single stronger candidate
//   open        — no candidate survived; invariants or candidates need revision
//
// "open" is not failure. It means the question is harder than the candidates
// assumed. Document what broke and why, then revise.
//
// An agent reading this file should be able to:
//   - Declare invariants for a construct under design
//   - Generate candidate formalisms that claim to satisfy them
//   - Generate minimal counterexamples targeting specific claims
//   - Evaluate rebuttal validity
//   - Perform composition tests against already-canonicalized constructs
//   - Apply the collapse test
//   - Produce a canonical form or open record
//   - Determine what the next run should address

package cffp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Constraint-First Formalization Protocol"
	version:     "0.2.1"
	description: "Invariant-driven semantic design. Candidates survive pressure or die."
}

// ─── CONSTRUCT UNDER DESIGN ──────────────────────────────────────────────────

// What construct is this run formalizing?
// A run covers exactly one construct. Composition with prior constructs
// is tested explicitly in Phase 4, not assumed.
#Construct: {
	name:        string
	description: string

	// Which constructs have already been canonicalized?
	// This run's candidates must compose correctly with all of these.
	// Empty list means this is the first construct.
	depends_on: [...string]
}

// ─── PHASE 1: INVARIANT DECLARATION ─────────────────────────────────────────
//
// Invariants are the non-negotiables. They must be:
//   testable    — there exists a procedure to determine if a candidate satisfies it
//   structural  — grounded in the evaluation model, not in ergonomics or convention
//   falsifiable — a counterexample can in principle demonstrate violation
//
// Invariants are declared before candidates. Candidates do not define invariants.
// If an invariant is discovered during later phases, the run restarts from Phase 1.

#Invariant: {
	id:          string // short identifier, e.g. "I1", "I2"
	description: string // precise enough that two independent agents agree on its meaning
	testable:    bool & true
	structural:  bool & true

	// What class of property is this?
	// "termination"    — evaluation always halts
	// "determinism"    — identical inputs produce identical outputs
	// "decidability"   — membership/evaluation is decidable
	// "soundness"      — the formalism does not permit invalid states
	// "completeness"   — the formalism can express all intended behaviors
	// "composability"  — the construct integrates correctly with others
	// "analyzability"  — static analysis can derive the required properties
	class: "termination" | "determinism" | "decidability" | "soundness" |
	       "completeness" | "composability" | "analyzability"
}

#Phase1: {
	invariants: [...#Invariant]
	invariants: [_, ...] // at least one required
}

// ─── PHASE 2: CANDIDATE FORMALISMS ───────────────────────────────────────────
//
// Candidates are formal structures — not implementations, not syntax sketches.
// A candidate must specify:
//   - its structure (what it is)
//   - its evaluation rule (how it is computed)
//   - its resolution rule (how conflicts or ambiguities are resolved)
//   - explicit claims of invariant satisfaction with proof sketches
//   - known complexity bounds
//   - known or anticipated failure modes
//
// A candidate that does not claim to satisfy an invariant is assumed to violate it.
// Partial compliance is not permitted — a candidate either satisfies an invariant
// or it does not.

#ProofSketch: {
	invariant_id: string
	argument:     string // informal but precise argument for why invariant holds
}

#FailureMode: {
	description: string // what breaks
	trigger:     string // the condition that causes it
	severity:    "fatal" | "degraded" | "ergonomic"
	// fatal      — violates an invariant
	// degraded   — does not violate an invariant but produces poor outcomes
	// ergonomic  — correct but difficult to use correctly
}

#Complexity: {
	time:   string // e.g. "O(n)", "O(n²)", "linear in stratum count"
	space:  string
	static: string // complexity of static analysis over this construct
}

#Candidate: {
	id:          string
	description: string

	formalism: {
		structure:       string // what the construct is, formally
		evaluation_rule: string // how it is evaluated
		resolution_rule: string // how conflicts/ambiguities resolve
	}

	// Explicit invariant satisfaction claims with proof sketches.
	// A claim without a proof sketch is inadmissible.
	claims: [...#ProofSketch]
	claims: [_, ...] // at least one required

	complexity: #Complexity
	failure_modes: [...#FailureMode]
}

#Phase2: {
	candidates: [...#Candidate]
	candidates: [_, ...] // at least one required
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────
//
// Pressure has two forms:
//
// Counterexample — a minimal concrete case that demonstrates an invariant violation.
//   A counterexample must be minimal: no proper sub-case also demonstrates the violation.
//   A counterexample may be rebutted. A valid rebuttal shows the counterexample is
//   not actually a violation of the claimed invariant given the candidate's formalism.
//   An invalid rebuttal is one that re-defines the invariant or narrows the candidate's
//   claimed scope. Scope-narrowing rebuttals are recorded as acknowledged limitations,
//   not as refutations.
//
// Composition failure — a demonstration that the candidate, when combined with an
//   already-canonicalized construct, produces a violation of any invariant.
//   Composition failures cannot be rebutted — they are structural incompatibilities.
//   A candidate that fails composition is eliminated.

#Rebuttal: {
	argument: string // why the counterexample does not constitute a violation
	valid:    bool   // set by protocol evaluator

	// What kind of rebuttal is this?
	//
	//   "refutation"     — the counterexample is incorrect given the candidate's formalism.
	//                      The invariant claim stands. The counterexample is dismissed.
	//
	//   "scope_narrowing" — the counterexample is correct, but the candidate withdraws
	//                       its claim to cover the case the counterexample targets.
	//                       The candidate survives, but the narrowed scope is recorded
	//                       as an acknowledged limitation in Phase 6. This is a
	//                       semantically distinct outcome from refutation — the candidate
	//                       did not defeat the pressure, it retreated from it.
	//
	// A scope_narrowing rebuttal is always valid by definition — the candidate is
	// conceding the point, not disputing it. valid: true must still be set.
	// The distinction matters for Phase 6: refutations leave no trace;
	// scope_narrowings become acknowledged_limitations in the canonical form.
	kind: "refutation" | "scope_narrowing"

	// Required when kind is "scope_narrowing": what scope was excluded.
	// This text becomes an entry in canonical.acknowledged_limitations.
	limitation_description?: string

	// Required when valid is false: which invariant claim is considered falsified.
	// The candidate is eliminated unless it withdraws the claim entirely.
	falsified_claim?: string
}

#Counterexample: {
	id:               string
	target_candidate: string
	violates:         string // invariant id
	witness:          string // the minimal concrete case demonstrating violation
	minimal:          bool & true // must be explicitly asserted

	rebuttal?: #Rebuttal
}

#CompositionFailure: {
	target_candidate:      string
	conflicts_with:        string // name of already-canonicalized construct
	violates:              string // invariant id
	description:           string
	// No rebuttal field. Composition failures are not rebuttable.
}

#Phase3: {
	counterexamples:    [...#Counterexample]
	composition_failures: [...#CompositionFailure]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────
//
// A candidate is eliminated if:
//   (a) any counterexample targets it AND has no valid rebuttal, OR
//   (b) any composition failure targets it
//
// Survivors are candidates not eliminated by either condition.
// A run with zero survivors proceeds to Phase 3b (invariant revision) not Phase 4.
//
// Elimination and survival are recorded explicitly in #Derived — not inferred
// from comments. An agent evaluating this protocol instance must populate #Derived
// before proceeding to Phase 4.

#EliminationReason: "counterexample_unrebutted" | "counterexample_invalid_rebuttal" | "composition_failure"

#Eliminated: {
	candidate_id: string
	reason:       #EliminationReason
	// The id of the counterexample or composition failure that caused elimination.
	// For counterexample eliminations: the counterexample id.
	// For composition failures: the target_candidate field of the #CompositionFailure.
	source_id:    string
}

#Survivor: {
	candidate_id: string
	// Scope narrowings accumulated by this candidate during Phase 3.
	// Each entry here becomes an acknowledged_limitation in Phase 6.
	// Empty if all rebuttals were refutations.
	scope_narrowings: [...string]
}

#Derived: {
	eliminated: [...#Eliminated]
	survivors:  [...#Survivor]
	// survivors must be non-empty to proceed past Phase 3.
	// If empty, phase3b is required.
}

// ─── PHASE 3b: INVARIANT REVISION (conditional) ──────────────────────────────
//
// Triggered only when Phase 3 produces zero survivors.
// The protocol evaluator must determine:
//   - Were the invariants too strong? (a valid construct exists but was excluded)
//   - Were the candidates too weak? (the invariants are correct; better candidates needed)
//   - Is the construct as specified incoherent? (the design question needs reframing)
//
// Invariant revision restarts the run from Phase 1 with a new version number.
// Candidate revision restarts from Phase 2. Reframing closes the run as "open"
// and opens a new run on the reframed question.

#Phase3b: {
	triggered:  bool
	diagnosis:  "invariants_too_strong" | "candidates_too_weak" | "construct_incoherent"
	resolution: "revise_invariants" | "revise_candidates" | "reframe_and_close"
	notes:      string
}

// ─── PHASE 4: COLLAPSE TEST ───────────────────────────────────────────────────
//
// If multiple candidates survive Phase 3, attempt collapse:
// Can they be merged into a single candidate that is strictly at least as strong
// as each survivor individually?
//
// Collapse succeeds if the merged candidate:
//   - satisfies all invariants claimed by all survivors
//   - introduces no new failure modes not already present in the survivors
//   - is not strictly weaker than any survivor on any invariant
//
// If collapse fails, all survivors are documented. The protocol evaluator must
// determine which survivor to canonicalize, and must record the rationale.
// This is the only point in the protocol where a human judgment call is permitted.

#CollapseResult: {
	attempted: bool
	if attempted {
		succeeded: bool
		if succeeded {
			merged_candidate: #Candidate
			replaces: [...string] // ids of survivors that were merged
		}
		if !succeeded {
			reason:          string
			selected:        string // id of survivor selected for canonicalization
			selection_basis: string // rationale for selection
		}
	}
}

// ─── PHASE 5: STATIC ANALYSIS OBLIGATIONS ────────────────────────────────────
//
// Before canonicalization, the surviving candidate must satisfy a set of
// static analysis obligations. These are proof obligations, not tests.
// Each must be argued, not merely asserted.
//
// These obligations are in addition to, not a replacement for, the invariant
// claims made in Phase 2. Phase 5 is specifically about properties that emerge
// from the complete evaluation model, not from the construct in isolation.

#StaticObligation: {
	property:  string // what is being proved
	argument:  string // informal proof or reduction argument
	provable:  bool   // evaluator's assessment
	// If not provable, canonicalization is blocked.
	if !provable {
		blocker: string // what would need to change to make it provable
	}
}

#Phase5: {
	obligations: [...#StaticObligation]
	// All obligations must have provable: true to proceed to Phase 6.
	all_provable: bool
}

// ─── PHASE 6: CANONICALIZATION ───────────────────────────────────────────────
//
// Canonicalization is only reached if:
//   - At least one survivor from Phase 3
//   - Collapse test complete (Phase 4)
//   - All static obligations provable (Phase 5)
//
// The canonical form is the authoritative formal definition of the construct.
// It is added to the spec. Future runs that depend on this construct treat
// the canonical form as fixed.
//
// The canonical form must include:
//   - A formal statement precise enough for another agent to evaluate a contract
//   - The evaluation definition (operational semantics)
//   - The complete set of satisfied invariants
//   - Any acknowledged limitations (non-fatal scope exclusions from rebuttal)

#CanonicalForm: {
	construct:           string // name of the construct being canonicalized
	formal_statement:    string // the definition
	evaluation_def:      string // operational semantics
	satisfies:           [...string] // invariant ids
	acknowledged_limitations: [...string] // from scope-narrowing rebuttals, if any
}

#Phase6: {
	canonical: #CanonicalForm
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "canonical" | "collapse" | "open"
// canonical — one candidate survived and was canonicalized directly
// collapse  — multiple survivors were merged into a canonical form
// open      — no canonical form produced; see phase3b for diagnosis

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#CFFPInstance: {
	protocol:  #Protocol
	construct: #Construct
	version:   string // e.g. "1.0", "1.1" — increments on Phase 3b restarts

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3

	// Explicitly populated after Phase 3. Required before Phase 4 can proceed.
	derived: #Derived

	phase3b?: #Phase3b   // only if derived.survivors is empty

	phase4?: #CollapseResult // only if len(derived.survivors) > 1
	phase5:  #Phase5
	phase6?: #Phase6         // only if phase5.all_provable == true

	outcome: #Outcome
	outcome_notes: string // evaluator's summary of why this outcome was reached
}

```

### Construct Decomposition Protocol (CDP)

```cue
// Construct Decomposition Protocol (CDP)
// Version: 0.1.1
//
// Changes from 0.1.0:
//   - Reorganized to protocols/adversarial/
//
// CDP addresses the case where a construct exhibits incoherence that cannot
// be resolved by candidate selection or invariant revision within CFFP.
// Specifically: when the construct is secretly two (or more) distinct things
// that have been conflated, and no single formalism can satisfy all intended
// invariants simultaneously because those invariants belong to different things.
//
// CDP takes incoherence evidence as input and produces either:
//   split     — a validated partition of the construct into coherent parts,
//               each ready for an independent CFFP run
//   unified   — the construct is actually coherent; the apparent incoherence
//               has a different diagnosis (see outcome_notes)
//   open      — the incoherence is real but no valid split was found;
//               the boundary needs revision or the construct needs reframing
//
// The output of a successful CDP run is not a canonical form.
// It is a set of named, bounded sub-constructs and a recomposition proof,
// which together authorize independent CFFP runs on each part.
//
// CDP does not canonicalize. CFFP canonicalizes.
// CDP only establishes that independent canonicalization is warranted and safe.
//
// Relationship to CFFP:
//   CDP is typically triggered by a CFFP run that reached outcome "open"
//   with phase3b.diagnosis == "construct_incoherent". The CFFP instance
//   that triggered this run should be recorded in triggered_by.
//   CDP output authorizes new CFFP runs; it does not replace them.

package cdp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Construct Decomposition Protocol"
	version:     "0.1.1"
	description: "Incoherence-driven construct splitting. Parts must be more coherent than the whole."
}

// ─── CONSTRUCT UNDER DECOMPOSITION ───────────────────────────────────────────

#Construct: {
	name:        string
	description: string
	// The CFFP instance id that diagnosed this construct as incoherent, if any.
	// May be empty if decomposition was initiated directly.
	triggered_by?: string
}

// ─── PHASE 1: INCOHERENCE EVIDENCE ───────────────────────────────────────────
//
// Before proposing any split, the incoherence must be documented precisely.
// Vague claims of confusion are not admissible. The evidence must be one
// of the recognized incoherence forms below.
//
// An agent must populate at least one piece of evidence before proceeding.
// Multiple evidence items strengthen the case for decomposition and
// constrain which splits are admissible.
//
// If no evidence can be produced, the construct may not actually be incoherent.
// Close the run as "unified" and return to CFFP with revised candidates.

// A pair of invariants that cannot be simultaneously satisfied by any
// single formalism. The conflict must be demonstrated, not merely asserted.
#InvariantConflict: {
	invariant_a:   string // invariant id or description
	invariant_b:   string // invariant id or description
	demonstration: string // why no single formalism can satisfy both
}

// A partition of the construct's known cases into two sets such that
// no single evaluation rule covers both sets correctly.
// The sets must be exhaustive over the known cases and mutually exclusive.
#BehavioralPartition: {
	set_a: {
		description: string // what cases fall here
		behavior:    string // how the construct behaves in these cases
	}
	set_b: {
		description: string
		behavior:    string
	}
	incompatibility: string // why no single rule covers both behaviors
}

// A composition failure that only manifests in certain contexts,
// suggesting the construct behaves as different things in different roles.
#ContextualCompositionFailure: {
	context_a: {
		description:  string
		composes_with: string // what it successfully composes with here
	}
	context_b: {
		description:   string
		fails_with:    string // what it fails to compose with here
		failure_reason: string
	}
	implication: string // why this suggests two distinct constructs
}

#IncoherenceEvidence: {
	invariant_conflicts:           [...#InvariantConflict]
	behavioral_partitions:         [...#BehavioralPartition]
	contextual_composition_failures: [...#ContextualCompositionFailure]

	// At least one evidence item required across all three lists.
	// Enforced by protocol evaluator — CUE cannot express cross-list minimums directly.
	evidence_summary: string // evaluator's synthesis of why this construct is incoherent
}

#Phase1: {
	evidence: #IncoherenceEvidence
}

// ─── PHASE 2: SPLIT CANDIDATES ───────────────────────────────────────────────
//
// A split candidate proposes a partition of the construct into named parts.
// Each part must:
//   - have a name and description precise enough to seed a CFFP run
//   - have a declared boundary: the criterion that determines which cases
//     belong to this part and not others
//   - claim a set of invariants it satisfies (which may differ from the
//     invariants the original construct claimed)
//   - not claim invariants that contradict those of sibling parts
//
// A split candidate must also provide a recomposition argument:
// a demonstration that the union of all parts covers the original construct's
// intended scope, and that the parts do not overlap.
//
// Two-way splits are the default. Three-or-more-way splits are permitted
// but require proportionally stronger recomposition arguments.
//
// A split candidate that cannot produce a recomposition argument is inadmissible.

#Part: {
	name:        string
	description: string

	// The criterion that determines membership in this part.
	// Must be precise enough that a given case can be unambiguously assigned.
	boundary_criterion: string

	// Invariants this part claims to satisfy.
	// These become the Phase 1 invariants of the subsequent CFFP run for this part.
	claimed_invariants: [...{
		id:          string
		description: string
		class:       "termination" | "determinism" | "decidability" | "soundness" |
		             "completeness" | "composability" | "analyzability"
	}]
	claimed_invariants: [_, ...] // at least one required

	// Known limitations of this part — cases it explicitly does not cover.
	// These must not overlap with what sibling parts cover.
	explicit_exclusions: [...string]
}

#RecompositionArgument: {
	// Argument that the union of all parts covers the original construct's intended scope.
	coverage: string
	// Argument that no case belongs to more than one part.
	non_overlap: string
	// Argument that the incoherence evidence from Phase 1 is fully explained
	// by the proposed boundary — i.e., each evidence item maps cleanly to
	// a distinction between parts.
	evidence_mapping: string
}

// A split candidate also carries a naturalness argument.
// This is the pressure point that has no direct equivalent in CFFP:
// a split can be formally valid (coverage holds, non-overlap holds,
// invariants are consistent) but draw the boundary in the wrong place,
// producing parts that are technically correct but semantically useless.
// The naturalness argument must address this directly.
#NaturalnessArgument: {
	argument: string // why this boundary is the *right* boundary, not just a valid one
	// What alternative boundaries were considered and rejected, and why.
	alternatives_considered: [...{
		boundary:       string
		rejection_reason: string
	}]
}

#SplitCandidate: {
	id:    string
	parts: [...#Part]
	parts: [_, _, ...] // at least two parts required

	recomposition: #RecompositionArgument
	naturalness:   #NaturalnessArgument

	// Anticipated failure modes of this split — ways the boundary might
	// turn out to be wrong or the parts might fail their subsequent CFFP runs.
	anticipated_failures: [...{
		description: string
		severity:    "fatal" | "degraded" | "ergonomic"
		// fatal     — would invalidate the split entirely
		// degraded  — would require boundary revision
		// ergonomic — correct but inconvenient in practice
	}]
}

#Phase2: {
	candidates: [...#SplitCandidate]
	candidates: [_, ...] // at least one required
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────
//
// Pressure against split candidates takes three forms:
//
// BoundaryCounterexample — a case that cannot be unambiguously assigned to
//   exactly one part under the proposed boundary criterion. Either the case
//   belongs to both parts (overlap violation) or neither (coverage violation).
//   A valid rebuttal shows the case is in fact unambiguously assigned,
//   or performs a scope narrowing that records the case as an explicit exclusion.
//
// RecompositionChallenge — a demonstration that the recomposition argument fails:
//   either coverage does not hold (some intended case falls outside all parts)
//   or non-overlap does not hold (some case belongs to multiple parts).
//   Recomposition challenges cannot be rebutted with scope narrowing —
//   they must be refuted or the split candidate is eliminated.
//
// NaturalnessChallenge — an argument that the boundary is drawn in the wrong place:
//   a demonstration that an alternative boundary would produce parts that are
//   strictly more useful, more coherent, or more compositionally sound.
//   A valid rebuttal shows the proposed boundary is preferable on stated criteria.
//   Naturalness challenges can be rebutted with a boundary defense argument.
//
// Composition failures against already-canonicalized constructs apply here
// as in CFFP: they are not rebuttable and eliminate the split candidate.

#BoundaryRebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	limitation_description?: string // required if kind is "scope_narrowing"
}

#BoundaryCounterexample: {
	id:               string
	target_candidate: string
	target_part?:     string // which part's boundary is challenged, if specific
	witness:          string // the case that cannot be unambiguously assigned
	violation:        "overlap" | "coverage_gap"
	minimal:          bool & true
	rebuttal?:        #BoundaryRebuttal
}

#RecompositionChallenge: {
	id:               string
	target_candidate: string
	challenges:       "coverage" | "non_overlap"
	argument:         string // demonstration that the recomposition argument fails
	// No rebuttal with scope narrowing permitted here.
	rebuttal?: {
		argument: string // must be a refutation, not a retreat
		valid:    bool
	}
}

#NaturalnessChallenge: {
	id:               string
	target_candidate: string
	alternative_boundary: string // the boundary being proposed as superior
	argument:         string     // why this boundary is strictly preferable
	rebuttal?: {
		argument: string // defense of the original boundary
		valid:    bool
	}
}

#CompositionFailure: {
	target_candidate: string
	target_part:      string // which part fails composition
	conflicts_with:   string // already-canonicalized construct
	violates:         string // invariant id or description
	description:      string
	// Not rebuttable.
}

#Phase3: {
	boundary_counterexamples:  [...#BoundaryCounterexample]
	recomposition_challenges:  [...#RecompositionChallenge]
	naturalness_challenges:    [...#NaturalnessChallenge]
	composition_failures:      [...#CompositionFailure]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────
//
// A split candidate is eliminated if:
//   (a) any boundary counterexample targets it with no valid rebuttal, OR
//   (b) any recomposition challenge targets it with no valid refutation, OR
//   (c) any composition failure targets any of its parts, OR
//   (d) any naturalness challenge targets it with no valid rebuttal
//       AND a surviving alternative split candidate addresses the same
//       incoherence evidence with a boundary the challenge endorses.
//
// Note: a naturalness challenge alone does not eliminate a candidate
// if no alternative candidate embodies the challenged boundary.
// It becomes a recorded limitation instead.

#EliminationReason:
	"boundary_counterexample_unrebutted" |
	"recomposition_challenge_unrefuted"  |
	"composition_failure"                |
	"naturalness_dominated"

#EliminatedSplit: {
	candidate_id: string
	reason:       #EliminationReason
	source_id:    string
}

#SurvivorSplit: {
	candidate_id:     string
	scope_narrowings: [...string] // from scope-narrowing boundary rebuttals
	naturalness_limitations: [...string] // from unrebutted naturalness challenges with no dominating alternative
}

#Derived: {
	eliminated: [...#EliminatedSplit]
	survivors:  [...#SurvivorSplit]
}

// ─── PHASE 3b: REVISION (conditional) ────────────────────────────────────────
//
// Triggered when Phase 3 produces zero survivors.
// Diagnosis determines restart point.

#Phase3b: {
	triggered:  bool
	diagnosis:  "evidence_insufficient" | "candidates_too_weak" | "construct_not_decomposable"
	resolution: "revise_evidence" | "revise_candidates" | "close_as_unified"
	// "close_as_unified" — the incoherence evidence did not survive pressure;
	//   the construct may be coherent after all. Return to CFFP.
	notes:      string
	max_revisions: uint // terminate and set outcome "open" if exceeded
}

// ─── PHASE 4: SPLIT SELECTION ─────────────────────────────────────────────────
//
// If multiple split candidates survive, select one.
// Unlike CFFP's collapse test, splits cannot generally be merged —
// two valid splits draw different boundaries, and merging them
// would produce an incoherent boundary.
//
// Selection is based on:
//   - fewest scope narrowings (broader coverage)
//   - fewest naturalness limitations
//   - strongest recomposition argument
//   - best alignment with incoherence evidence from Phase 1
//
// If an autonomous agent is running this protocol, it must apply these
// criteria in order and record its reasoning. A human observer should
// be able to reconstruct why the selected split was preferred.

#SplitSelection: {
	selected:         string // candidate id
	selection_basis:  string // explicit reasoning against the criteria above
	alternatives_rejected: [...{
		candidate_id: string
		reason:       string
	}]
}

#Phase4: {
	multiple_survivors: bool
	if multiple_survivors {
		selection: #SplitSelection
	}
	final_candidate: string // id of the split proceeding to Phase 5
}

// ─── PHASE 5: CFFP READINESS OBLIGATIONS ─────────────────────────────────────
//
// Before authorizing CFFP runs on the parts, verify that each part
// is actually ready to be formalized independently.
//
// A part is CFFP-ready if:
//   - its boundary criterion is precise enough to seed Phase 1 invariants
//   - its claimed invariants are non-contradictory
//   - it has no unresolved composition obligations with already-canonicalized constructs
//   - the recomposition argument has survived all challenges
//
// If any part fails readiness, it must be refined before CFFP is authorized.
// Refinement does not restart the CDP run — it revises the part in place
// and re-evaluates readiness only.

#PartReadiness: {
	part_name:              string
	boundary_precise:       bool
	invariants_consistent:  bool
	composition_clear:      bool
	recomposition_survived: bool
	ready:                  bool // conjunction of above; evaluator sets this explicitly
	if !ready {
		blocking_issues: [...string]
	}
}

#Phase5: {
	readiness: [...#PartReadiness]
	all_ready: bool // must be true to proceed to Phase 6
}

// ─── PHASE 6: SPLIT AUTHORIZATION ────────────────────────────────────────────
//
// The authorized split is the output of CDP.
// It does not define canonical forms — it authorizes the CFFP runs that will.
//
// Each authorized part carries:
//   - its name and boundary criterion (for the CFFP construct definition)
//   - its claimed invariants (for the CFFP Phase 1 invariants)
//   - its acknowledged limitations (from scope narrowings and naturalness limitations)
//   - a note on what it depends on (for the CFFP depends_on field)
//
// The recomposition proof is preserved as a joint invariant that both
// subsequent CFFP runs must respect: neither canonical form, once produced,
// may be revised in a way that breaks coverage or introduces overlap.

#AuthorizedPart: {
	name:               string
	boundary_criterion: string
	seed_invariants: [...{
		id:          string
		description: string
		class:       "termination" | "determinism" | "decidability" | "soundness" |
		             "completeness" | "composability" | "analyzability"
	}]
	acknowledged_limitations: [...string]
	depends_on: [...string] // already-canonicalized constructs this part composes with
}

#RecompositionProof: {
	coverage_argument:   string
	non_overlap_argument: string
	// Joint invariant: both CFFP runs must preserve this.
	joint_invariant:     string
}

#Phase6: {
	authorized_parts:    [...#AuthorizedPart]
	authorized_parts:    [_, _, ...] // at least two
	recomposition_proof: #RecompositionProof
	// Instructions for the subsequent CFFP runs.
	cffp_instructions:   string
}

// ─── OUTCOME ──────────────────────────────────────────────────────────────────

#Outcome: "split" | "unified" | "open"
// split   — authorized parts produced; CFFP runs authorized
// unified — construct is coherent; return to CFFP with revised candidates
// open    — incoherence confirmed but no valid split found; boundary needs work

// ─── FULL PROTOCOL INSTANCE ───────────────────────────────────────────────────

#CDPInstance: {
	protocol:  #Protocol
	construct: #Construct
	version:   string

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3

	derived: #Derived

	phase3b?: #Phase3b

	phase4?: #Phase4 // only if len(derived.survivors) > 1

	phase5: #Phase5
	phase6?: #Phase6 // only if phase5.all_ready == true

	outcome:       #Outcome
	outcome_notes: string
}

```

### Concept Boundary Protocol (CBP)

```cue
// Concept Boundary Protocol (CBP)
// Version: 0.1.1
// Changelog:
//   - Reorganized to protocols/adversarial/
//
// CBP addresses the case where a term is being used inconsistently across
// contexts — meaning different things to different people, in different
// domains, or in different phases of the same argument. The protocol
// determines whether the term should be:
//
//   sharpened — one precise concept is identified that accounts for all
//               legitimate usages; variant usages are diagnosed as errors
//               or metaphors, not distinct concepts
//
//   split     — the term covers two or more genuinely distinct concepts
//               that have been conflated; each is named and bounded,
//               and the original term is either retired or assigned to one
//
//   retired   — the term is so contaminated by conflicting usage that no
//               sharpening or split can recover it; it should be replaced
//               entirely by new vocabulary
//
// CBP is related to CDP (Construct Decomposition Protocol) but starts
// from a different place. CDP starts with behavioral incoherence — a
// construct that works differently in different situations. CBP starts
// from linguistic/semantic incoherence — a term that means different
// things in different contexts. A successful CBP split may authorize
// CDP runs if the resulting concepts need formal decomposition, or
// CFFP runs if they need formalization.
//
// On naming:
// CBP must handle the naming of split concepts. This is the most
// subjective judgment in the protocol and cannot be fully formalized.
// The protocol handles naming by requiring candidates to propose names,
// requiring those names to survive a naming pressure phase, and recording
// the rationale for the selected names explicitly. The protocol evaluator
// must apply naming criteria (distinctness, non-prejudging, coverage) but
// the final selection is a judgment call that must be documented.
//
// Outcomes:
//   sharpened  — one precise definition adopted; variant usages diagnosed
//   split      — two or more named concepts authorized; vocabulary map produced
//   retired    — term retired; replacement vocabulary recommended
//   open       — no satisfactory resolution found; term remains contested

package cbp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Concept Boundary Protocol"
	version:     "0.1.1"
	description: "Usage-driven concept boundary determination. Output is a sharpened definition or a named split."
}

// ─── TERM UNDER INVESTIGATION ─────────────────────────────────────────────────

#TermUnderInvestigation: {
	term:        string // the exact term or phrase being investigated
	domain:      string // the field, codebase, discourse, or context where this matters
	// Why is this investigation being conducted now?
	// What problem does the inconsistent usage cause?
	motivation:  string
	// Are there already competing formal definitions in the literature or codebase?
	prior_definitions: [...{
		source:     string
		definition: string
		notes:      string
	}]
}

// ─── PHASE 1: USAGE INVENTORY ─────────────────────────────────────────────────
//
// Before proposing any definition, all known usages of the term must be
// collected and documented. A usage is a concrete instance of the term
// being used, with enough context to determine what the user meant by it.
//
// Usages are the evidence base for CBP. Everything that follows is
// constrained by the usage inventory. A definition that cannot account
// for the usages is inadmissible. A split that does not cover the usages
// is invalid.
//
// Usage collection uses three procedures:
//
// Procedure 1: Contextual Sampling
//   Collect representative usages from across the domain. Aim for
//   diversity of context, author, and apparent meaning.
//
// Procedure 2: Edge Case Elicitation
//   Actively seek usages that seem to strain or contradict each other.
//   The goal is to find the cases that would most stress any proposed definition.
//
// Procedure 3: Expert Probe
//   If available, ask domain experts: "What does this term mean?" and
//   "Is X a case of this term?" Compare answers for divergence.
//   If experts agree, note the consensus. If they diverge, record both.
//
// Each usage is classified by its apparent semantic intent.

#UsageIntent:
	"technical"     | // used as a precise technical term
	"colloquial"    | // used loosely or informally
	"metaphorical"  | // used by analogy or extension
	"contested"     | // speaker is aware of definitional dispute
	"ambiguous"       // intent cannot be determined from context

#Usage: {
	id:      string
	source:  string // where this usage was found (document, speaker, codebase, etc.)
	excerpt: string // the actual usage in context
	// What did the user apparently mean by this term here?
	apparent_meaning: string
	intent:           #UsageIntent
	// Is this usage consistent with other usages, or does it diverge?
	diverges_from: [...string] // usage ids this one is inconsistent with
	// Is this a core usage (clearly central to the term's identity)
	// or a peripheral usage (possibly metaphorical or derived)?
	centrality: "core" | "peripheral"
}

#Phase1: {
	procedure_log: [...{
		procedure: "contextual_sampling" | "edge_case_elicitation" | "expert_probe"
		applied:   bool
		if !applied {
			skip_justification: string
		}
		notes: string
	}]

	usages: [...#Usage]
	usages: [_, ...] // at least one required

	// Evaluator's synthesis: what is the pattern of divergence?
	// Are there clearly distinct semantic clusters, or is the divergence diffuse?
	divergence_summary: string

	// Preliminary diagnosis before candidates are proposed.
	preliminary_diagnosis: "likely_sharpening" | "likely_split" | "likely_retirement" | "unclear"
}

// ─── PHASE 2: CANDIDATE RESOLUTIONS ──────────────────────────────────────────
//
// Candidates are proposed resolutions to the boundary question.
// There are three kinds:
//
// SharpeningCandidate — proposes one precise definition that covers all
//   core usages. Must explain how peripheral and divergent usages are
//   diagnosed (error, metaphor, domain-specific extension, etc.).
//   Must not simply exclude inconvenient usages without diagnosis.
//
// SplitCandidate — proposes two or more named concepts.
//   Each concept gets a name, a definition, and a boundary criterion.
//   The candidate must show how all usages are covered by the split.
//   Naming is required: unnamed concepts are inadmissible.
//   The candidate must also propose a disposition for the original term:
//   retired, assigned to one concept, or retained as an umbrella term.
//
// RetirementCandidate — proposes that the term be retired entirely.
//   Must propose replacement vocabulary (at least one replacement term
//   with a definition). Must show the replacement vocabulary covers
//   all core usages. Retirement without replacement is inadmissible.
//
// All candidates must address all core usages. Peripheral usages should
// be addressed but a candidate may diagnose them as out of scope with justification.

#UsageCoverage: {
	usage_id:  string
	covered:   bool
	if covered {
		explanation: string // how this candidate covers this usage
	}
	if !covered {
		diagnosis: string // why this usage is excluded (error, metaphor, out of scope)
		diagnosis_kind: "error" | "metaphor" | "domain_extension" | "out_of_scope"
	}
}

// Naming criteria for split concepts:
//   Distinctness   — the names must not suggest the same thing
//   Non-prejudging — the names must not presuppose the outcome of future CFFP/CDP runs
//   Coverage       — the names must reflect what their concepts actually cover
//   Memorability   — the names should be usable in practice without confusion
// These criteria are applied in Phase 3 naming pressure.

#ConceptName: {
	proposed_name:   string
	naming_rationale: string // argument that this name satisfies naming criteria
	// What prior terms or concepts might this name be confused with?
	confusion_risks: [...string]
	// How are those confusion risks mitigated?
	confusion_mitigations: [...string]
}

#SharpeningCandidate: {
	id:         string
	kind:       "sharpening"
	definition: string // the proposed precise definition
	// Necessary and sufficient conditions, if expressible.
	necessary_conditions:  [...string]
	sufficient_conditions: [...string]
	// How does this definition handle the divergent usages?
	divergence_diagnosis: string
	coverage: [...#UsageCoverage]
	// What this definition explicitly excludes and why.
	explicit_exclusions: [...string]
}

#SplitConceptDefinition: {
	name:               #ConceptName
	definition:         string
	boundary_criterion: string // what makes something an instance of this concept and not others
	// Necessary and sufficient conditions, if expressible.
	necessary_conditions:  [...string]
	sufficient_conditions: [...string]
	// Which usages from Phase 1 map to this concept?
	mapped_usages: [...string] // usage ids
}

#SplitCandidate: {
	id:       string
	kind:     "split"
	concepts: [...#SplitConceptDefinition]
	concepts: [_, _, ...] // at least two concepts required

	// What happens to the original term?
	original_term_disposition:
		"retired"        | // original term no longer used
		"assigned"       | // original term assigned to one of the split concepts
		"umbrella"         // original term retained as umbrella for all concepts
	if original_term_disposition == "assigned" {
		assigned_to: string // concept name it is assigned to
		assignment_rationale: string
	}
	if original_term_disposition == "umbrella" {
		umbrella_rationale: string // why the original term works as an umbrella
	}

	coverage: [...#UsageCoverage]
}

#ReplacementTerm: {
	term:       string
	definition: string
	// Which usages from Phase 1 does this replacement term cover?
	mapped_usages: [...string]
}

#RetirementCandidate: {
	id:                   string
	kind:                 "retirement"
	retirement_rationale: string // why the term cannot be sharpened or split
	replacements:         [...#ReplacementTerm]
	replacements:         [_, ...] // at least one replacement required
	coverage:             [...#UsageCoverage]
}

#ResolutionCandidate: #SharpeningCandidate | #SplitCandidate | #RetirementCandidate

#Phase2: {
	candidates: [...#ResolutionCandidate]
	candidates: [_, ...] // at least one required
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────
//
// Pressure against resolution candidates takes four forms:
//
// CoverageGap — a usage from Phase 1 that the candidate does not cover
//   and has not diagnosed. A valid rebuttal shows the usage is covered
//   or provides a diagnosis. An invalid rebuttal eliminates the candidate.
//
// DefinitionCollision — two usages that the candidate assigns to the same
//   concept but which appear to mean different things. A valid rebuttal
//   shows they are the same concept under the candidate's definition.
//   A scope-narrowing rebuttal concedes they are different and narrows
//   the concept's claimed scope.
//
// NamingPressure (split candidates only) — a challenge to a proposed name
//   on any of the four naming criteria: distinctness, non-prejudging,
//   coverage, memorability. A valid rebuttal defends the name against
//   the specific criterion challenged. Names that fail naming pressure
//   must be revised; a split candidate whose names cannot be defended
//   is not eliminated but must revise its names before Phase 4.
//
// ConnotationPressure — a demonstration that the proposed definition or
//   name imports unwanted connotations from adjacent concepts, prior usage,
//   or common understanding, such that the definition would be systematically
//   misread. This has no equivalent in CFFP or CDP. A valid rebuttal shows
//   the connotation is not actually imported, or that it is unavoidable and
//   the documentation handles it.

#DefinitionRebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	limitation_description?: string // required if scope_narrowing
}

#CoverageGapChallenge: {
	id:               string
	target_candidate: string
	usage_id:         string // the uncovered usage
	argument:         string // why this usage is not covered or diagnosed
	rebuttal?:        #DefinitionRebuttal
}

#DefinitionCollisionChallenge: {
	id:               string
	target_candidate: string
	usage_id_a:       string
	usage_id_b:       string
	argument:         string // why these usages resist assignment to the same concept
	rebuttal?:        #DefinitionRebuttal
}

#NamingCriterion: "distinctness" | "non_prejudging" | "coverage" | "memorability"

#NamingPressureChallenge: {
	id:               string
	target_candidate: string
	target_concept:   string // the concept name being challenged
	criterion:        #NamingCriterion
	argument:         string // why the name fails this criterion
	rebuttal?: {
		argument: string
		valid:    bool
		// If invalid: the candidate must revise the name.
		// Name revision does not eliminate the candidate.
		revised_name?: #ConceptName // populated if rebuttal is invalid
	}
}

#ConnotationPressureChallenge: {
	id:               string
	target_candidate: string
	// Which term or concept does this definition/name import connotations from?
	connotation_source: string
	argument:           string // how the connotation is imported and why it is harmful
	rebuttal?: {
		argument: string
		valid:    bool
	}
}

#Phase3: {
	coverage_gaps:        [...#CoverageGapChallenge]
	definition_collisions: [...#DefinitionCollisionChallenge]
	naming_pressure:      [...#NamingPressureChallenge]
	connotation_pressure: [...#ConnotationPressureChallenge]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────
//
// A candidate is eliminated if:
//   (a) any coverage gap challenge targets it with no valid rebuttal, OR
//   (b) any definition collision targets it with no valid rebuttal, OR
//   (c) any connotation pressure challenge targets it with no valid rebuttal
//
// Naming pressure alone does not eliminate. It triggers name revision.
// A candidate with revised names re-enters survivor derivation with
// the revised names. If revised names also fail naming pressure, the
// candidate is eliminated.
//
// Scope narrowings from definition collision rebuttals are recorded
// as acknowledged limitations.

#EliminationReason:
	"coverage_gap_unrebutted"        |
	"definition_collision_unrebutted" |
	"connotation_pressure_unrebutted" |
	"naming_revision_failed"

#EliminatedCandidate: {
	candidate_id: string
	reason:       #EliminationReason
	source_id:    string
}

#SurvivorCandidate: {
	candidate_id:     string
	kind:             "sharpening" | "split" | "retirement"
	scope_narrowings: [...string]
	// Name revisions applied during pressure phase.
	name_revisions: [...{
		concept:      string
		original:     string
		revised:      string
		revision_rationale: string
	}]
}

#Derived: {
	eliminated: [...#EliminatedCandidate]
	survivors:  [...#SurvivorCandidate]
}

// ─── PHASE 3b: REVISION (conditional) ────────────────────────────────────────

#Phase3b: {
	triggered:  bool
	diagnosis:  "usages_insufficient" | "candidates_too_weak" | "term_irredeemable"
	resolution: "collect_more_usages" | "revise_candidates" | "close_as_retired"
	notes:      string
}

// ─── PHASE 4: CANDIDATE SELECTION ────────────────────────────────────────────
//
// If multiple candidates survive, select one.
// Selection criteria, applied in order:
//   1. Prefer sharpening over split over retirement (simpler resolutions preferred)
//   2. Among same-kind candidates: prefer fewest scope narrowings
//   3. Among same-kind candidates: prefer strongest coverage of core usages
//   4. Among split candidates: prefer names with fewest naming revisions
//
// This ordering may be overridden with explicit justification.

#CandidateSelection: {
	selected:        string // candidate id
	selection_basis: string // explicit reasoning against the criteria above
	alternatives_rejected: [...{
		candidate_id: string
		reason:       string
	}]
}

#Phase4: {
	multiple_survivors: bool
	if multiple_survivors {
		selection: #CandidateSelection
	}
	final_candidate: string
}

// ─── PHASE 5: RESOLUTION OBLIGATIONS ─────────────────────────────────────────
//
// Before adopting a resolution, verify:
//   - all core usages are covered or diagnosed
//   - all proposed names (in split candidates) satisfy naming criteria
//   - no unresolved connotation risks remain
//   - the resolution does not create new ambiguities worse than the original
//   - if split or retirement: the vocabulary map is complete and actionable

#ResolutionObligation: {
	property:  string
	argument:  string
	satisfied: bool
	if !satisfied {
		blocker: string
	}
}

#Phase5: {
	obligations:   [...#ResolutionObligation]
	all_satisfied: bool
}

// ─── PHASE 6: ADOPTED RESOLUTION ─────────────────────────────────────────────
//
// The adopted resolution is the output of CBP.
//
// For sharpening: a precise definition with usage coverage and
//   diagnosis of variant usages.
//
// For split: a named vocabulary map — each concept with its name,
//   definition, boundary criterion, and the usages that map to it.
//   Plus the disposition of the original term.
//   If formalization is needed, CDP or CFFP runs are authorized here.
//
// For retirement: replacement vocabulary with coverage map.
//
// The adopted resolution also carries:
//   - acknowledged limitations (from scope narrowings)
//   - open questions (usages that remain contested)
//   - authorization notes for downstream protocol runs

#SharpenedDefinition: {
	term:                  string
	definition:            string
	necessary_conditions:  [...string]
	sufficient_conditions: [...string]
	usage_coverage:        [...#UsageCoverage]
	acknowledged_limitations: [...string]
	// Usages diagnosed as errors, metaphors, or extensions.
	variant_diagnoses: [...{
		usage_id:  string
		diagnosis: "error" | "metaphor" | "domain_extension" | "out_of_scope"
		notes:     string
	}]
}

#VocabularyMap: {
	concepts: [...{
		name:               string
		definition:         string
		boundary_criterion: string
		mapped_usages:      [...string]
		acknowledged_limitations: [...string]
		// Does this concept warrant a CFFP or CDP run?
		downstream_protocol?: "cffp" | "cdp" | "none"
		downstream_notes?:    string
	}]
	original_term_disposition:
		"retired" | "assigned" | "umbrella"
	original_term_notes: string
}

#ReplacementVocabulary: {
	retired_term:  string
	retirement_rationale: string
	replacements:  [...#ReplacementTerm]
	usage_coverage: [...#UsageCoverage]
}

#AdoptedResolution: {
	kind: "sharpening" | "split" | "retirement"

	if kind == "sharpening" {
		sharpened: #SharpenedDefinition
	}
	if kind == "split" {
		vocabulary_map: #VocabularyMap
	}
	if kind == "retirement" {
		replacement_vocabulary: #ReplacementVocabulary
	}

	// Open questions: usages or distinctions that remain contested
	// even after the resolution is adopted.
	open_questions: [...string]

	// Plain-language summary for human observers.
	summary: string
}

#Phase6: {
	adopted_resolution: #AdoptedResolution
}

// ─── OUTCOME ──────────────────────────────────────────────────────────────────

#Outcome: "sharpened" | "split" | "retired" | "open"

// ─── FULL PROTOCOL INSTANCE ───────────────────────────────────────────────────

#CBPInstance: {
	protocol: #Protocol
	term:     #TermUnderInvestigation
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

### Hypothesis Elimination Protocol (HEP)

```cue
// Hypothesis Elimination Protocol (HEP)
// Version: 0.1.1
// Changelog:
//   - source_ids: [...string] changed to source_id: string for structural consistency
//   - Reorganized to protocols/adversarial/
//
// HEP addresses the case where a phenomenon has been observed and multiple
// causal explanations are on the table. The protocol drives toward the
// explanation that survives all available discriminating evidence.
//
// HEP is not a confirmation protocol. It does not prove hypotheses true.
// It eliminates hypotheses that are inconsistent with evidence, and
// produces a survivor — the hypothesis that has not yet been eliminated.
// A survivor is not proven. It is the least-eliminated candidate.
//
// HEP operates in two modes, declared at the instance level:
//
//   bounded   — the hypothesis space is declared upfront and closed.
//               New hypotheses require a formal revision step.
//               Experiments are assumed feasible.
//               Termination is guaranteed if the space is finite.
//
//   unbounded — the hypothesis space is open. New hypotheses may emerge
//               from evidence. Experiments have declared feasibility and cost.
//               Termination is not guaranteed; a budget mechanism applies.
//
// HEP also requires a declaration of exhaustiveness:
//
//   exhaustive     — the agent asserts the true explanation is guaranteed
//                    to be among the declared hypotheses. Requires an argument.
//                    Only valid in bounded mode.
//
//   non-exhaustive — the true explanation may not be among the declared
//                    hypotheses. Always the case in unbounded mode.
//
// The combination (unbounded + exhaustive) is incoherent and rejected.
//
// These two axes produce three valid configurations:
//
//   bounded + exhaustive     — closed-world diagnosis (e.g. debugging).
//                              Strongest convergence guarantees.
//                              "open" outcome is a strong failure signal.
//
//   bounded + non-exhaustive — constrained investigation with acknowledged
//                              blind spots. "open" may mean the true explanation
//                              is outside the declared space.
//
//   unbounded + non-exhaustive — open scientific inquiry.
//                              Weakest convergence guarantees.
//                              "open" is a legitimate finding, not a failure.
//
// Outcomes:
//   converged    — one hypothesis survived all evidence; adopted as best explanation
//   open         — multiple hypotheses survived; evidence is underdetermining
//   exhausted    — all hypotheses eliminated; space needs revision
//                  (only meaningful in non-exhaustive configurations;
//                   in bounded+exhaustive, exhausted means the observation
//                   itself needs to be questioned)

package hep

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Hypothesis Elimination Protocol"
	version:     "0.1.1"
	description: "Evidence-driven hypothesis elimination. Survivors are least-eliminated, not proven."
}

// ─── PHENOMENON UNDER INVESTIGATION ──────────────────────────────────────────

#Phenomenon: {
	description: string // what was observed
	context:     string // the system, environment, or conditions in which it occurred
	// Precise characterization of the observation.
	// Vague phenomena produce vague hypotheses. Be specific.
	observation: string

	// Is this phenomenon reproducible?
	reproducible: bool
	if !reproducible {
		// If not reproducible, note what this implies for experiment design.
		reproducibility_notes: string
	}
}

// ─── MODE DECLARATION ────────────────────────────────────────────────────────
//
// Declared once per instance. Cannot change mid-run.
// Mode affects which fields are required, which outcomes are valid,
// and what "open" means.

#ModeDeclaration: {
	bounded: bool

	// exhaustive may only be true in bounded mode.
	// An unbounded+exhaustive declaration is rejected by the protocol.
	exhaustive: bool

	// Structural constraint: unbounded mode cannot be exhaustive.
	// Enforced by protocol evaluator.
	if !bounded {
		exhaustive: false
	}

	// If exhaustive, an argument is required.
	// The agent asserts the true explanation is guaranteed to be among
	// the declared hypotheses. This is a strong claim.
	exhaustiveness_argument?: string
	// Required when exhaustive is true.

	// In unbounded mode, a budget is required.
	// The protocol terminates and produces outcome "open" when the budget is exceeded,
	// regardless of the state of the hypothesis space.
	budget?: {
		max_hypotheses:  uint // maximum hypotheses permitted across all revision cycles
		max_experiments: uint // maximum experiments permitted
		// If either limit is exceeded, the run closes as "open" with
		// outcome_notes explaining what budget was exhausted.
	}
	// Required when bounded is false.
}

// ─── PHASE 1: HYPOTHESIS DECLARATION ─────────────────────────────────────────
//
// Hypotheses are causal models — proposed explanations of why the observed
// phenomenon occurred. A hypothesis must:
//   - specify a cause: the proposed mechanism that produced the observation
//   - specify predictions: what else should be true if this hypothesis is correct
//   - specify discriminating predictions: observations that would be
//     inconsistent with this hypothesis but consistent with alternatives
//   - declare prior plausibility: the agent's assessment before evidence
//
// Predictions are what make hypotheses eliminatable. A hypothesis with no
// predictions cannot be pressured. Such a hypothesis is inadmissible.
//
// In bounded mode: all hypotheses are declared here. The space is then closed.
// In unbounded mode: initial hypotheses are declared here. New hypotheses
// may be added in Phase 3b (hypothesis revision) as evidence demands.

#Prediction: {
	id:          string
	description: string // what should be observable if this hypothesis is correct
	// Is this prediction discriminating — i.e., would its failure specifically
	// challenge this hypothesis rather than all hypotheses equally?
	discriminating: bool
	// What it would mean if this prediction fails.
	failure_implication: string
}

#Hypothesis: {
	id:          string
	description: string

	// The proposed causal mechanism.
	cause: string

	predictions: [...#Prediction]
	predictions: [_, ...] // at least one required
	// At least one prediction must be discriminating.
	// Enforced by protocol evaluator.

	// Prior plausibility: the agent's assessment before evidence.
	// "high"   — strongly expected given background knowledge
	// "medium" — plausible but not favored
	// "low"    — possible but unlikely given background knowledge
	prior_plausibility: "high" | "medium" | "low"
	plausibility_argument: string // why this prior is assigned

	// Known conditions under which this hypothesis cannot hold.
	// Declaring these upfront improves the quality of discriminating experiments.
	known_exclusions: [...string]
}

#Phase1: {
	hypotheses: [...#Hypothesis]
	hypotheses: [_, ...] // at least one required
	// At least two required to have anything to discriminate between.
	// Enforced by protocol evaluator.

	// In bounded+exhaustive mode: argument that the space is closed.
	// Copied from mode_declaration.exhaustiveness_argument.
	// Recorded here for phase-local legibility.
	exhaustiveness_argument?: string
}

// ─── PHASE 2: EVIDENCE INVENTORY ─────────────────────────────────────────────
//
// Evidence comes in two forms:
//
// Existing evidence — observations already available before the run begins.
//   These are evaluated immediately against all hypotheses.
//
// Experimental evidence — observations that must be obtained by designing
//   and executing an experiment. These have feasibility and cost declarations.
//
// Evidence items are evaluated against hypotheses to produce consistency
// assessments. An evidence item is:
//   consistent      — the hypothesis predicts or accommodates this observation
//   inconsistent    — the hypothesis predicts this observation would NOT occur
//   uninformative   — the evidence does not discriminate between hypotheses
//
// Only inconsistent assessments eliminate hypotheses.
// Consistent assessments increase confidence but do not prove.
// Uninformative assessments are recorded but do not affect elimination.
//
// Evidence weight: not all evidence is equal. Weight is declared explicitly.
//   "decisive"    — inconsistency with this evidence eliminates the hypothesis
//   "strong"      — inconsistency is strong pressure; rebuttal required to survive
//   "weak"        — inconsistency is noted but not eliminatory on its own
//
// In bounded mode, experiments are assumed feasible unless declared otherwise.
// In unbounded mode, feasibility and cost must be explicitly declared.

#EvidenceItem: {
	id:          string
	description: string
	source:      "existing" | "experimental"

	if source == "experimental" {
		experiment: {
			design:      string // how the experiment is conducted
			feasible:    bool
			if !feasible {
				feasibility_blocker: string
			}
			// In unbounded mode, cost must be declared.
			cost?: "negligible" | "moderate" | "high" | "prohibitive"
		}
		// Has the experiment been executed?
		executed: bool
		if executed {
			result: string // what was observed
		}
	}

	if source == "existing" {
		observation: string // what was observed
	}

	weight: "decisive" | "strong" | "weak"
}

// Assessment of a single evidence item against a single hypothesis.
#EvidenceAssessment: {
	evidence_id:   string
	hypothesis_id: string
	consistency:   "consistent" | "inconsistent" | "uninformative"
	argument:      string // why this assessment holds
	// If inconsistent and weight is "strong": rebuttal is permitted (see Phase 3).
	// If inconsistent and weight is "decisive": no rebuttal; hypothesis is eliminated.
	// If inconsistent and weight is "weak": recorded as pressure, not elimination.
}

#Phase2: {
	evidence:    [...#EvidenceItem]
	assessments: [...#EvidenceAssessment]
	// All evidence items must have assessments against all hypotheses.
	// Enforced by protocol evaluator.
}

// ─── PHASE 3: PRESSURE AND ELIMINATION ───────────────────────────────────────
//
// Pressure in HEP is evidence-driven, not counterexample-driven.
// The pressure mechanism operates as follows:
//
// Decisive inconsistency — hypothesis is eliminated immediately.
//   No rebuttal permitted. The evidence is decisive.
//
// Strong inconsistency — hypothesis is under strong pressure.
//   A rebuttal is permitted. A valid rebuttal shows the assessment is wrong:
//   either the evidence is consistent with the hypothesis under correct analysis,
//   or the evidence itself is unreliable.
//   An invalid rebuttal eliminates the hypothesis.
//   A scope-narrowing rebuttal is permitted: the hypothesis withdraws its claim
//   to cover the conditions under which the evidence was gathered. This is a
//   retreat, not a victory, and is recorded as an acknowledged limitation.
//
// Weak inconsistency — recorded as pressure. Accumulation of weak inconsistencies
//   may constitute strong pressure in aggregate. The protocol evaluator must
//   assess whether accumulated weak pressure rises to strong pressure level.
//   This assessment must be argued, not merely asserted.
//
// Cross-hypothesis support — evidence consistent with one hypothesis while
//   inconsistent with another constitutes relative support. This is recorded
//   explicitly because it affects the evidential landscape even when it does
//   not directly eliminate.

#EvidenceRebuttal: {
	hypothesis_id: string
	evidence_id:   string
	kind:          "refutation" | "scope_narrowing" | "evidence_unreliability"
	// "refutation"          — the inconsistency assessment is wrong; the hypothesis
	//                         is consistent with this evidence under correct analysis.
	// "scope_narrowing"     — the hypothesis withdraws its claim to cover the
	//                         conditions of this evidence. Retreat, not victory.
	// "evidence_unreliability" — the evidence itself is unreliable or contaminated.
	//                         The assessment is voided, not rebutted.
	argument:      string
	valid:         bool
	limitation_description?: string // required if kind is "scope_narrowing"
	// If evidence_unreliability: what makes the evidence unreliable.
	unreliability_argument?: string // required if kind is "evidence_unreliability"
}

// Accumulated weak pressure assessment.
#AccumulatedPressure: {
	hypothesis_id:      string
	evidence_ids:       [...string] // the weak inconsistencies being aggregated
	rises_to_strong:    bool
	argument:           string // why the accumulation does or does not rise to strong pressure
}

// Cross-hypothesis support record.
#CrossSupport: {
	supported_hypothesis:    string
	pressured_hypothesis:    string
	evidence_id:             string
	argument:                string // why this evidence relatively supports one over the other
}

#Phase3: {
	rebuttals:            [...#EvidenceRebuttal]
	accumulated_pressure: [...#AccumulatedPressure]
	cross_support:        [...#CrossSupport]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────
//
// A hypothesis is eliminated if:
//   (a) any decisive inconsistency targets it (no rebuttal permitted), OR
//   (b) any strong inconsistency targets it with no valid rebuttal, OR
//   (c) accumulated weak pressure against it is assessed as rising to strong,
//       with no valid rebuttal
//
// Survivors are hypotheses not eliminated by any of the above.
//
// In bounded+exhaustive mode: if all hypotheses are eliminated, the observation
// itself must be questioned — the exhaustiveness argument has failed.
// In bounded+non-exhaustive mode: if all hypotheses are eliminated, the space
// needs expansion.
// In unbounded mode: if all hypotheses are eliminated, new hypotheses are
// generated in Phase 3b.

#EliminationReason:
	"decisive_inconsistency"       |
	"strong_inconsistency_unrebutted" |
	"accumulated_weak_pressure"

#EliminatedHypothesis: {
	hypothesis_id: string
	reason:        #EliminationReason
	// For decisive/strong inconsistency: the evidence item id.
	// For accumulated_weak_pressure: the id of the #AccumulatedPressure record in Phase3.
	source_id: string
}

#SurvivorHypothesis: {
	hypothesis_id:    string
	scope_narrowings: [...string] // from scope-narrowing rebuttals
	// Relative support: cross-support records that favor this hypothesis.
	relative_support: [...string] // evidence ids
	// Remaining pressure: weak inconsistencies not risen to strong level.
	remaining_pressure: [...string] // evidence ids
}

#Derived: {
	eliminated: [...#EliminatedHypothesis]
	survivors:  [...#SurvivorHypothesis]
}

// ─── PHASE 3b: HYPOTHESIS REVISION (conditional) ─────────────────────────────
//
// Triggered when Phase 3 produces zero survivors.
// Behavior differs by configuration:
//
//   bounded+exhaustive:     zero survivors means the exhaustiveness claim has failed.
//                           The observation or the exhaustiveness argument must be revised.
//                           This is a strong signal — do not add hypotheses casually.
//
//   bounded+non-exhaustive: zero survivors means the space needs expansion.
//                           New hypotheses may be added. The run restarts from Phase 1
//                           with the expanded space. Revision counter increments.
//
//   unbounded:              zero survivors triggers new hypothesis generation.
//                           Evidence gathered so far constrains what new hypotheses
//                           are admissible — they must be consistent with surviving evidence.
//                           Budget is checked before proceeding.
//
// Also triggered in unbounded mode when evidence suggests a hypothesis not
// previously considered, regardless of survivor count.

#Phase3b: {
	triggered:  bool
	trigger_reason: "zero_survivors" | "new_hypothesis_indicated"

	diagnosis:
		"exhaustiveness_failed" |  // bounded+exhaustive only
		"space_needs_expansion" |  // bounded+non-exhaustive
		"new_hypotheses_needed"    // unbounded

	resolution:
		"revise_observation"    |  // exhaustiveness_failed
		"expand_space"          |  // space_needs_expansion
		"generate_hypotheses"   |  // new_hypotheses_needed
		"close_as_exhausted"       // budget exceeded or expansion unproductive

	new_hypotheses: [...#Hypothesis] // populated when resolution is expand_space or generate_hypotheses

	// Constraints on new hypotheses: they must not be inconsistent with
	// evidence that survived Phase 2 with "consistent" assessments.
	consistency_constraints: [...string]

	revision_count: uint // increments each time Phase 3b is triggered
	notes:          string
}

// ─── PHASE 4: CONVERGENCE ASSESSMENT ─────────────────────────────────────────
//
// If one survivor: assess confidence in the survivor as best explanation.
// If multiple survivors: assess whether further evidence can discriminate.
//
// Confidence in a single survivor is not binary. It depends on:
//   - how many hypotheses were eliminated
//   - the weight of evidence that eliminated them
//   - the strength of cross-support for the survivor
//   - the scope narrowings the survivor accumulated (weaker = more narrowings)
//   - whether the survivor has surviving predictions that have been confirmed
//
// If multiple survivors: design discriminating experiments if feasible.
// If no feasible discriminating experiment exists: outcome is "open".
// Document what evidence would theoretically discriminate even if not obtainable.

#ConfidenceAssessment: {
	hypothesis_id: string
	level:         "high" | "medium" | "low"
	argument:      string // explicit reasoning against the factors above
	// What would weaken this confidence assessment?
	vulnerabilities: [...string]
}

#DiscriminatingExperiment: {
	design:          string // how to discriminate between surviving hypotheses
	targets:         [...string] // hypothesis ids it would discriminate between
	feasible:        bool
	if feasible {
		expected_discriminating_power: "decisive" | "strong" | "weak"
	}
	if !feasible {
		feasibility_blocker: string
		// Even if not feasible now, document what would make it feasible.
		theoretical_path: string
	}
}

#Phase4: {
	single_survivor: bool

	if single_survivor {
		confidence: #ConfidenceAssessment
	}

	if !single_survivor {
		// Attempt to design discriminating experiments.
		discriminating_experiments: [...#DiscriminatingExperiment]
		// If any feasible discriminating experiment exists, it should be
		// executed and Phase 3 re-run with the new evidence.
		feasible_discrimination_available: bool
	}
}

// ─── PHASE 5: EXPLANATION OBLIGATIONS ────────────────────────────────────────
//
// Before adopting a survivor as best explanation, verify:
//   - the survivor's cause is sufficient to produce the observation
//   - the survivor's predictions that have been tested are confirmed
//   - the survivor does not conflict with established background knowledge
//     outside the scope of the investigation
//   - the scope narrowings accumulated are not so severe that the survivor
//     only explains a trivial subset of the original phenomenon
//
// These are not proofs — they are argued obligations.
// If any obligation fails, adoption is blocked.

#ExplanationObligation: {
	property:  string
	argument:  string
	satisfied: bool
	if !satisfied {
		blocker: string
	}
}

#Phase5: {
	obligations:   [...#ExplanationObligation]
	all_satisfied: bool
}

// ─── PHASE 6: ADOPTION ───────────────────────────────────────────────────────
//
// The adopted explanation is the best available explanation given
// all evidence considered in this run. It is not proven true.
// It is the survivor of all pressure applied.
//
// The adopted explanation carries:
//   - the hypothesis that survived
//   - the confidence level
//   - acknowledged limitations (from scope narrowings)
//   - remaining vulnerabilities (predictions not yet tested)
//   - what evidence would overturn it
//
// Future runs that encounter new evidence may reopen this run.
// The adopted explanation is revisable, not fixed.

#AdoptedExplanation: {
	hypothesis_id:            string
	cause:                    string // restated from the surviving hypothesis
	confidence:               "high" | "medium" | "low"
	acknowledged_limitations: [...string]
	remaining_vulnerabilities: [...string]
	// What evidence would overturn this explanation?
	// Declared explicitly so future observers know what to look for.
	overturning_evidence:     string
}

// In the "open" outcome, document the surviving hypotheses and what
// would discriminate between them.
#OpenRecord: {
	survivors: [...string] // hypothesis ids
	// What evidence would discriminate between them if obtainable?
	theoretical_discriminator: string
	// Why is discrimination not currently achievable?
	underdetermination_reason: string
}

#Phase6: {
	if outcome == "converged" {
		adopted: #AdoptedExplanation
	}
	if outcome == "open" {
		open_record: #OpenRecord
	}
	if outcome == "exhausted" {
		// Document what the exhaustion implies for next steps.
		exhaustion_notes: string
		// In bounded+exhaustive: question the observation or exhaustiveness argument.
		// In bounded+non-exhaustive: expand the hypothesis space.
		// In unbounded: budget was exceeded; document state for future runs.
		recommended_next: string
	}
	outcome: #Outcome
}

// ─── OUTCOME ──────────────────────────────────────────────────────────────────

#Outcome: "converged" | "open" | "exhausted"
// converged  — one hypothesis survived and was adopted as best explanation
// open       — multiple hypotheses survived; evidence is underdetermining
// exhausted  — all hypotheses eliminated; see configuration for implications

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#HEPInstance: {
	protocol:  #Protocol
	phenomenon: #Phenomenon
	mode:      #ModeDeclaration
	version:   string

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3

	derived: #Derived

	phase3b?: #Phase3b

	phase4: #Phase4
	phase5: #Phase5
	phase6: #Phase6

	outcome:       #Outcome
	outcome_notes: string
	// For bounded+exhaustive runs: note whether the exhaustiveness argument
	// survived the run intact or was weakened by scope narrowings.
	exhaustiveness_status?: string
}

```

### Analogy Transfer Protocol (ATP)

```cue
// Analogy Transfer Protocol (ATP)
// Version: 0.1.0
//
// ATP addresses the case where a construct in domain A is claimed to be
// structurally similar to something in domain B, and someone wants to import
// the formalization. The protocol validates whether the structural
// correspondence is real and whether the transfer is safe.
//
// The protocol produces one of three outcomes:
//   validated — correspondence survived all pressure; formalization transferred
//               with acknowledged divergences
//   rejected  — correspondence eliminated by unrebutted challenges; transfer
//               not viable as specified
//   open      — multiple surviving correspondences; further discrimination needed
//
// The key insight: disanalogy counterexamples can be scope-narrowed just like
// invariant counterexamples in CFFP. A transfer candidate survives pressure by
// retreating to a narrower correspondence — but the retreat is recorded as an
// acknowledged divergence, not a victory.
//
// An agent reading this file should be able to:
//   - Declare a claimed structural correspondence between two domains
//   - Generate concrete correspondence candidates (proposed mappings)
//   - Identify and evaluate disanalogy counterexamples, domain mismatches,
//     and scope challenges
//   - Derive survivors with accumulated acknowledged divergences
//   - Verify that transferred invariants hold in the target domain
//   - Produce a validated transfer record or rejection

package atp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Analogy Transfer Protocol"
	version:     "0.1.0"
	description: "Cross-domain structural transfer validation. Survivors carry acknowledged divergences."
}

// ─── TRANSFER DECLARATION ────────────────────────────────────────────────────

#SourceConstruct: {
	name:             string
	domain:           string
	formal_statement: string  // the formalization in the source domain
	invariants:       [...string] // what the source formalization guarantees
}

#TargetDomain: {
	name:                string
	description:         string
	canonical_constructs: [...string] // already-canonicalized constructs in this domain
}

#Phase1: {
	source_construct:       #SourceConstruct
	target_domain:          #TargetDomain
	claimed_correspondence: string // the structural similarity being claimed
	motivation:             string // why this transfer would be useful
}

// ─── PHASE 2: CORRESPONDENCE CANDIDATES ──────────────────────────────────────
//
// Each candidate proposes a mapping from source structure to target structure.
// For each element of the source formalization, the candidate identifies
// its analog in the target domain. Candidates must be precise.

#StructuralMapping: {
	source_element:     string
	target_element:     string
	alignment_argument: string
	mapping_kind:       "direct" | "adjusted" | "partial"
	if mapping_kind == "adjusted" || mapping_kind == "partial" {
		adjustment_description: string
	}
}

#CorrespondenceCandidate: {
	id:          string
	description: string
	mappings:    [...#StructuralMapping]
	mappings:    [_, ...] // at least one mapping required

	// Does this candidate claim all source invariants transfer?
	invariants_transfer: bool
	if !invariants_transfer {
		non_transferring_invariants: [...string]
		non_transfer_argument:       string
	}

	// Domain-specific properties this candidate claims to gain.
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
// DisanalogyCE — a case where the structural correspondence breaks.
//   Rebuttal: refutation (analogy holds) or scope_narrowing (acknowledged divergence).
//
// DomainMismatch — the domains differ in a foundational way that invalidates
//   the transfer even if the structural mapping holds locally.
//   Rebuttal: refutation only (scope_narrowing on a fundamental mismatch
//   would hollow out the transfer entirely).
//
// ScopeChallenge — the transfer only holds for a subset of the target domain.
//   Rebuttal: scope_narrowing (candidate survives by accepting the restriction).

#TransferRebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	limitation_description?: string // required if scope_narrowing
}

#DisanalogyCE: {
	id:               string
	target_candidate: string
	target_mapping?:  string // which mapping is challenged, if specific
	witness:          string // the case where the analogy breaks
	minimal:          bool & true
	rebuttal?:        #TransferRebuttal
}

#DomainMismatch: {
	id:               string
	target_candidate: string
	missing_property: string // the property the target domain lacks
	argument:         string // why this property is required for the transfer
	// Domain mismatch rebuttals must be refutations only.
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
//
// A candidate is eliminated if:
//   (a) any disanalogy CE targets it with no valid rebuttal, OR
//   (b) any domain mismatch targets it with no valid rebuttal, OR
//   (c) any scope challenge targets it with no valid rebuttal
//
// Scope narrowings from scope_narrowing rebuttals become acknowledged divergences
// in Phase 6.

#EliminationReason:
	"disanalogy_ce_unrebutted"   |
	"domain_mismatch_unrebutted" |
	"scope_challenge_unrebutted"

#EliminatedTransfer: {
	candidate_id: string
	reason:       #EliminationReason
	source_id:    string
}

#SurvivorTransfer: {
	candidate_id:     string
	scope_narrowings: [...string] // from scope_narrowing rebuttals; become acknowledged divergences
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
//
// If multiple candidates survive, select one.
// Prefer fewest scope narrowings, then strongest domain_specific_gains.

#Phase4: {
	multiple_survivors: bool
	if multiple_survivors {
		selected:        string // candidate id
		selection_basis: string
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
// preserves its invariants when instantiated in the target domain.
// These are proof obligations, not tests.

#TransferObligation: {
	property:  string // which invariant or property must be preserved
	argument:  string // why it holds in the target domain
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
	source_construct:            string
	target_domain:               string
	adopted_correspondence:      string // description of the validated mapping
	transferred_formalization:   string // the formalization as instantiated in target domain
	acknowledged_divergences:    [...string] // from scope narrowings; places where transfer is limited
	preserved_invariants:        [...string]
	non_transferred_invariants:  [...string]
}

#RejectionRecord: {
	reason:              string
	strongest_challenge: string // the challenge that prevented transfer
	what_would_help:     string // what revision might enable future transfer
}

#Phase6: {
	validated_transfer?: #ValidatedTransfer
	rejection_record?:   #RejectionRecord
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "validated" | "rejected" | "open"
// validated — correspondence survived; formalization transferred with acknowledged divergences
// rejected  — correspondence eliminated by unrebutted challenges
// open      — multiple correspondences survived; further discrimination needed

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

	phase5:  #Phase5
	phase6?: #Phase6 // only if phase5.all_satisfied == true

	outcome:       #Outcome
	outcome_notes: string
}

```

### Emergence Mapping Protocol (EMP)

```cue
// Emergence Mapping Protocol (EMP)
// Version: 0.1.0
//
// EMP addresses the case where canonical forms have been composed in practice
// and unexpected behavior appears at the seam. EMP determines what the emergent
// behavior IS, whether it is genuine emergence or reducible to a single component,
// and what its impact on the composed system is.
//
// Relationship to RCP: RCP checks consistency between outputs of separate runs
// (static comparison). EMP checks for emergent behaviors when canonical forms
// are composed in practice (dynamic interaction analysis).
//
// The protocol produces one of three outcomes:
//   mapped       — emergence explained; impact classified; remediation path defined
//   non_emergent — behavior reducible to one composed form; not genuine emergence
//   open         — surviving explanations remain; further evidence needed
//
// An agent reading this file should be able to:
//   - Declare which canonical forms are composed and what emerged at the boundary
//   - Generate candidate explanations (interaction effect, missing constraint,
//     unmodeled dependency, genuine novelty)
//   - Apply reduction, scope, and counterexample challenges
//   - Classify impact (benign, degrading, invalidating)
//   - Produce a remediation path for affected canonical forms

package emp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Emergence Mapping Protocol"
	version:     "0.1.0"
	description: "Composition emergence analysis. Maps unexpected behavior at canonical form boundaries."
}

// ─── PHASE 1: COMPOSITION DECLARATION ────────────────────────────────────────

#ComposedForm: {
	name:      string
	run_id:    string // the CFFP or equivalent run that produced it
	invariants: [...string]
}

#Phase1: {
	composed_forms:       [...#ComposedForm]
	composed_forms:       [_, _, ...] // at least two forms being composed
	emergent_behavior:    string      // the unexpected behavior observed
	interaction_boundary: string      // where the forms interact / the seam
	reproducible: bool
	if !reproducible {
		reproducibility_notes: string
	}
	observation_context: string // conditions under which the emergence was observed
}

// ─── PHASE 2: EMERGENCE CANDIDATES ───────────────────────────────────────────
//
// Each candidate proposes a causal explanation for the emergent behavior.
// Candidates are not formalisms — they are explanatory hypotheses about
// what is happening at the composition boundary.

#EmergenceKind:
	"interaction_effect"   | // behavior arises from the interaction rule between forms
	"missing_constraint"   | // one or both forms lacks a constraint that would prevent this
	"unmodeled_dependency" | // a shared dependency was not modeled in either form
	"genuine_novelty"        // the behavior cannot be reduced to any single form

#EmergenceCandidate: {
	id:            string
	kind:          #EmergenceKind
	description:   string
	causal_account: string // why this explanation produces the observed behavior

	// Is this behavior reducible to one of the composed forms?
	reducible_to?: string // name of the composed form, if reducible

	predictions: [...{
		id:             string
		description:    string // what else should be observable if this explanation is correct
		discriminating: bool
	}]
	predictions: [_, ...]
}

#Phase2: {
	candidates: [...#EmergenceCandidate]
	candidates: [_, ...]
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────
//
// Three challenge types against emergence explanations:
//
// ReductionChallenge — the behavior IS predicted by one of the composed forms.
//   If valid, the candidate claiming "genuine_novelty" or "interaction_effect"
//   is eliminated. Rebuttal: refutation or scope_narrowing.
//
// ScopeChallenge — the emergence only occurs under specific conditions,
//   which the candidate failed to restrict to.
//   Rebuttal: scope_narrowing (candidate survives by accepting the restriction).
//
// CompositionCE — a related composition where the behavior does NOT occur,
//   undermining the candidate's causal account.
//   Rebuttal: refutation (show why the related case is different) or scope_narrowing.

#EmergenceRebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	limitation_description?: string // required if scope_narrowing
}

#ReductionChallenge: {
	id:               string
	target_candidate: string
	reduces_to:       string // which composed form explains the behavior
	argument:         string // how the form's invariants predict this behavior
	rebuttal?:        #EmergenceRebuttal
}

#ScopeChallenge: {
	id:               string
	target_candidate: string
	restricted_to:    string // conditions under which behavior occurs
	argument:         string // why the behavior doesn't generalize beyond this
	rebuttal?:        #EmergenceRebuttal
}

#CompositionCE: {
	id:               string
	target_candidate: string
	related_case:     string // a related composition where behavior does NOT occur
	minimal:          bool & true
	argument:         string // why this undermines the candidate's causal account
	rebuttal?:        #EmergenceRebuttal
}

#Phase3: {
	reduction_challenges:        [...#ReductionChallenge]
	scope_challenges:            [...#ScopeChallenge]
	composition_counterexamples: [...#CompositionCE]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────

#EliminationReason:
	"reduction_unrebutted"       |
	"scope_challenge_unrebutted" |
	"composition_ce_unrebutted"

#EliminatedExplanation: {
	candidate_id: string
	reason:       #EliminationReason
	source_id:    string
}

#SurvivorExplanation: {
	candidate_id:     string
	scope_narrowings: [...string] // conditions under which this explanation holds
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
// Verify that the classification is well-argued.

#ImpactClassification:
	"benign"      | // emergence does not threaten any invariant of composed forms
	"degrading"   | // emergence weakens guarantees without breaking invariants
	"invalidating"  // emergence breaks an invariant of one or more composed forms

#ImpactObligation: {
	property:  string
	argument:  string
	satisfied: bool
	if !satisfied {
		blocker: string
	}
}

#Phase5: {
	obligations:     [...#ImpactObligation]
	all_satisfied:   bool
	impact:          #ImpactClassification
	impact_argument: string
}

// ─── PHASE 6: EMERGENCE MAP ───────────────────────────────────────────────────

#RemediationPath:
	"none_required"        | // benign — document and proceed
	"revise_one_form"      | // specify which form needs revision
	"revise_both_forms"    | // both composed forms need revision
	"add_composition_rule" | // an explicit constraint must be added to the composition
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
	// Follow-on protocol runs authorized by this emergence map.
	downstream_protocols: [...{
		protocol: string // "CGP", "CFFP", etc.
		purpose:  string
	}]
}

#NonEmergentRecord: {
	reduces_to:      string // which composed form fully explains the behavior
	explanation:     string
	recommendation:  string
}

#Phase6: {
	emergence_map?:      #EmergenceMap
	non_emergent_record?: #NonEmergentRecord
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "mapped" | "non_emergent" | "open"
// mapped       — emergence explained; impact classified; remediation path defined
// non_emergent — behavior reducible to one of the composed forms
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

	phase5:  #Phase5
	phase6?: #Phase6

	outcome:       #Outcome
	outcome_notes: string
}

```

## Evaluative Protocols

### Assumption Audit Protocol (AAP)

```cue
// Assumption Audit Protocol (AAP)
// Version: 0.1.1
// Changelog:
//   - Reorganized to protocols/evaluative/
//
// AAP is a forensic protocol. Its input is an existing argument or design —
// something already built or concluded. Its output is a ranked fragility map:
// a structured assessment of where the existing argument or design is most
// vulnerable to assumption failure.
//
// AAP does not produce a new formalism, a canonical form, or an adopted
// explanation. It produces a vulnerability assessment that can inform
// revision, further investigation, or explicit acknowledgment of risk.
//
// AAP is not adversarial toward the argument under audit. It does not try
// to defeat the argument. It tries to characterize precisely how much weight
// each assumption is carrying and what happens when that weight is removed.
//
// The core challenge: assumptions are usually invisible. They are not the
// premises the argument's author listed — they are the things the author
// treated as fixed without noticing. Phase 1 therefore cannot simply ask
// for a list of assumptions. It must use extraction procedures to surface
// assumptions the author did not know they were making.
//
// Outcomes:
//   mapped     — fragility map produced; all load-bearing assumptions identified
//                and stress-tested
//   incomplete — fragility map produced but some assumptions could not be
//                stress-tested; map is partial
//   incoherent — the argument or design under audit is not sufficiently
//                specified to extract assumptions; audit cannot proceed

package aap

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Assumption Audit Protocol"
	version:     "0.1.1"
	description: "Forensic assumption extraction and stress-testing. Output is a ranked fragility map."
}

// ─── SUBJECT UNDER AUDIT ─────────────────────────────────────────────────────
//
// The subject is the argument or design being audited.
// A run covers exactly one subject. If the subject depends on other arguments
// or designs, those are listed in depends_on and their assumptions are
// treated as inherited (see Phase 1).

#AuditSubject: {
	name:        string
	kind:        "argument" | "design" | "policy" | "model" | "specification"
	description: string
	// The conclusion or output the subject claims to produce.
	// This is the thing that may be degraded or invalidated when assumptions fail.
	claimed_conclusion: string
	// Arguments or designs this subject explicitly builds on.
	// Their assumptions are candidates for inheritance in Phase 1.
	depends_on: [...string]
	// The original source or statement of the argument or design, if available.
	source?: string
}

// ─── PHASE 1: ASSUMPTION EXTRACTION ──────────────────────────────────────────
//
// Assumptions are extracted using four procedures. Each procedure targets
// a different class of invisible assumption. All four must be applied.
// An agent that skips a procedure must justify the skip explicitly.
//
// Procedure 1: Inference Step Analysis
//   For each inferential step in the argument or design, ask:
//   "What must be true for this step to be valid?"
//   The answer is a candidate assumption.
//
// Procedure 2: Fixed-Variable Analysis
//   What does the argument treat as fixed that could in principle vary?
//   Candidates: parameter values, environmental conditions, agent behaviors,
//   resource availability, time horizons, scope boundaries.
//
// Procedure 3: Ignored-Factor Analysis
//   What does the argument not mention that could affect the conclusion?
//   Candidates: second-order effects, feedback loops, adversarial actors,
//   distributional shifts, edge cases, interactions with adjacent systems.
//
// Procedure 4: Inherited Assumption Analysis
//   What assumptions does this argument inherit from its dependencies?
//   For each entry in depends_on, what must be true of that dependency
//   for this argument to hold?
//
// Each extracted assumption is classified and given a preliminary load
// estimate. Load is refined in Phase 2 after stress-testing.

#AssumptionClass:
	"inferential"   | // required for an inference step to be valid
	"parametric"    | // treats a variable as fixed
	"scope"         | // defines what the argument covers and excludes
	"environmental" | // assumes conditions in the surrounding context
	"behavioral"    | // assumes how agents or systems will act
	"inherited"       // assumed from a dependency

#ExtractionProcedure: "inference_step" | "fixed_variable" | "ignored_factor" | "inherited"

#Assumption: {
	id:          string
	description: string // precise statement of what is being assumed
	class:       #AssumptionClass
	extracted_by: #ExtractionProcedure

	// Where in the argument or design does this assumption operate?
	// For inferential: which step. For parametric: which parameter.
	// For scope: which boundary. Etc.
	locus: string

	// Preliminary load estimate before stress-testing.
	// Refined in Phase 3.
	// "structural" — the conclusion depends entirely on this assumption
	// "significant" — the conclusion degrades substantially if this fails
	// "moderate"   — the conclusion is weakened but survives
	// "minor"      — the conclusion is largely unaffected
	preliminary_load: "structural" | "significant" | "moderate" | "minor"

	// Is this assumption explicitly stated in the original argument,
	// or was it extracted (implicit)?
	explicit: bool

	// Is this assumption empirically checkable, or is it non-empirical
	// (definitional, normative, structural)?
	empirically_checkable: bool
	if empirically_checkable {
		check_procedure?: string // how one would verify this assumption holds
	}
}

#Phase1: {
	// Record of which extraction procedures were applied and any skips.
	procedure_log: [...{
		procedure: #ExtractionProcedure
		applied:   bool
		if !applied {
			skip_justification: string
		}
		notes: string // what the procedure surfaced or why it was unproductive
	}]

	assumptions: [...#Assumption]
	assumptions: [_, ...] // at least one required

	// Evaluator's synthesis: which assumptions appear most load-bearing
	// before stress-testing, and why.
	preliminary_assessment: string
}

// ─── PHASE 2: ASSUMPTION CHARACTERIZATION ────────────────────────────────────
//
// Before stress-testing, each assumption is characterized along three dimensions:
//
// Plausibility: how likely is this assumption to hold in the contexts where
//   the argument is applied? This is not a stress test — it is a prior
//   assessment based on background knowledge.
//
// Verifiability: can the truth of this assumption be established? If yes, has it
//   been established? If not, why not?
//
// Coupling: which other assumptions does this assumption depend on?
//   Coupled assumptions fail together. A cluster of coupled assumptions
//   is more fragile than the sum of its parts.
//
// Coupling analysis is the most important output of Phase 2. Assumption
// clusters that are mutually reinforcing — where each assumes the others —
// represent hidden single points of failure in the argument.

#PlausibilityAssessment: {
	assumption_id: string
	plausibility:  "high" | "medium" | "low" | "unknown"
	argument:      string // why this plausibility is assigned
	// Under what conditions would plausibility drop?
	conditional_fragility: string
}

#VerifiabilityAssessment: {
	assumption_id: string
	verifiable:    bool
	if verifiable {
		verified:    bool
		if verified {
			evidence: string // what establishes this assumption holds
		}
		if !verified {
			verification_path: string // how it could be verified
		}
	}
	if !verifiable {
		reason: string // why this assumption cannot be verified
	}
}

#CouplingRecord: {
	assumption_id: string
	coupled_with:  [...string] // assumption ids
	// Why are these coupled? What shared dependency or mutual reinforcement
	// makes them fail together?
	coupling_reason: string
}

#AssumptionCluster: {
	id:           string
	member_ids:   [...string] // assumption ids in this cluster
	// What does this cluster collectively assume?
	joint_assumption: string
	// How fragile is the cluster as a whole?
	cluster_fragility: "structural" | "significant" | "moderate" | "minor"
}

#Phase2: {
	plausibility:    [...#PlausibilityAssessment]
	verifiability:   [...#VerifiabilityAssessment]
	coupling:        [...#CouplingRecord]
	clusters:        [...#AssumptionCluster]
	// Evaluator's synthesis of the coupling landscape.
	coupling_summary: string
}

// ─── PHASE 3: STRESS TESTING ──────────────────────────────────────────────────
//
// Each assumption (and each cluster) is stress-tested by constructing
// failure scenarios: concrete situations in which the assumption does not hold.
// The stress test then traces what happens to the argument's conclusion.
//
// Failure scenarios must be:
//   realistic  — not logically impossible; must be genuinely conceivable
//   minimal    — the simplest situation in which the assumption fails
//   targeted   — designed to test this assumption specifically, not others
//
// The impact of assumption failure is assessed on a four-level scale:
//   "invalidates"  — the conclusion cannot be sustained if this assumption fails
//   "degrades"     — the conclusion holds in weakened form
//   "scopes"       — the conclusion holds but only within a narrower scope
//   "negligible"   — the conclusion is largely unaffected
//
// Stress tests produce the refined load estimate that replaces the preliminary
// load estimate from Phase 1.
//
// Some assumptions cannot be stress-tested because no realistic failure
// scenario can be constructed (the assumption is necessarily true in the
// argument's domain) or because the failure scenario's impact cannot be
// traced (the argument is underspecified). Both cases must be documented.

#FailureScenario: {
	id:          string
	description: string // the concrete situation in which the assumption fails
	realistic:   bool & true
	minimal:     bool & true
	targeted:    bool & true
}

#StressTestResult: {
	assumption_id:    string
	// For cluster stress tests, cluster_id is set instead.
	cluster_id?:      string
	scenario:         #FailureScenario
	impact:           "invalidates" | "degrades" | "scopes" | "negligible"
	impact_argument:  string // how the failure propagates to the conclusion
	// Refined load estimate, replacing preliminary_load from Phase 1.
	refined_load:     "structural" | "significant" | "moderate" | "minor"
	// If impact is "degrades" or "scopes": what does the weakened conclusion look like?
	weakened_conclusion?: string
	// Can the argument be patched to survive this failure?
	// "yes"     — a specific patch exists (describe in patch_description)
	// "partial" — the argument can be partially preserved
	// "no"      — the argument cannot be salvaged under this failure
	patchable:        "yes" | "partial" | "no"
	patch_description?: string // required if patchable is "yes" or "partial"
}

#UnstressableAssumption: {
	assumption_id: string
	reason:        "necessarily_true" | "argument_underspecified" | "impact_untraceable"
	notes:         string
}

#Phase3: {
	stress_tests:          [...#StressTestResult]
	unstressable:          [...#UnstressableAssumption]
	// All assumptions must either have a stress test or an unstressable record.
	// Enforced by protocol evaluator.
}

// ─── PHASE 4: FRAGILITY MAP ───────────────────────────────────────────────────
//
// The fragility map is the primary output of AAP.
// It ranks all assumptions by their refined load and organizes them
// into fragility tiers.
//
// Tier 1 — structural: failure invalidates the conclusion.
//   These are the assumptions the argument cannot survive losing.
//   Any argument with Tier 1 assumptions is only as strong as those assumptions.
//
// Tier 2 — significant: failure substantially degrades the conclusion.
//   These assumptions are load-bearing but not fatal.
//   The argument survives, but in a weakened form.
//
// Tier 3 — moderate: failure weakens or scopes the conclusion.
//   These assumptions affect the argument's reach and confidence
//   but not its core validity.
//
// Tier 4 — minor: failure has negligible impact.
//   These assumptions are present but not load-bearing.
//   They may still be worth noting for completeness.
//
// Clusters are ranked as a unit at their cluster_fragility level.
// A cluster ranked Tier 1 means the joint assumption is structural —
// failure of any member assumption may cascade to invalidate the conclusion.
//
// The fragility map also identifies:
//   - the single most dangerous assumption (highest load, lowest plausibility)
//   - the single most verifiable improvement (highest load, verifiable, unverified)
//   - any assumptions that are both structural and unverifiable
//     (these represent irreducible risk in the argument)

#FragilityTier: {
	tier:        1 | 2 | 3 | 4
	label:       "structural" | "significant" | "moderate" | "minor"
	members:     [...string] // assumption ids and/or cluster ids at this tier
	// Summary of what this tier's failure means for the conclusion.
	tier_summary: string
}

#FragilityMap: {
	tiers: [...#FragilityTier]

	// The single assumption or cluster whose failure poses the greatest risk.
	// Greatest risk = highest load AND lowest plausibility.
	most_dangerous:    string // assumption or cluster id
	most_dangerous_argument: string // why this is the most dangerous

	// The single improvement that would most strengthen the argument.
	// Most verifiable improvement = highest load, verifiable, currently unverified.
	most_verifiable_improvement:    string // assumption id
	most_verifiable_improvement_argument: string

	// Assumptions that are both structural (Tier 1) and unverifiable.
	// These represent irreducible epistemic risk.
	irreducible_risks: [...string] // assumption ids
	irreducible_risk_summary: string // what this means for the argument's reliability

	// Overall fragility assessment.
	overall_fragility: "brittle" | "fragile" | "robust" | "resilient"
	// brittle   — multiple Tier 1 assumptions, low plausibility, unverifiable
	// fragile   — some Tier 1 or many Tier 2 assumptions
	// robust    — mostly Tier 3/4, or Tier 1/2 with high plausibility and verified
	// resilient — few load-bearing assumptions, most verified, patches available
	overall_argument: string
}

#Phase4: {
	fragility_map: #FragilityMap
}

// ─── PHASE 5: RECOMMENDATIONS ────────────────────────────────────────────────
//
// Recommendations are actions that would reduce the argument's fragility.
// They are ranked by expected fragility reduction.
//
// Recommendation types:
//   "verify"      — establish whether the assumption actually holds
//   "hedge"       — add explicit caveats to the conclusion scoping it to
//                   the assumption's domain of validity
//   "patch"       — revise the argument to not depend on this assumption
//   "investigate" — gather more information before acting on the conclusion
//   "accept"      — explicitly acknowledge the assumption as irreducible risk
//                   and proceed with appropriate caution
//
// Recommendations are not mandatory. They are the protocol's output
// to the argument's author or consumer.

#Recommendation: {
	id:            string
	assumption_id: string // or cluster_id
	kind:          "verify" | "hedge" | "patch" | "investigate" | "accept"
	description:   string // what specifically to do
	expected_impact: string // how this would change the fragility map
	priority:      "high" | "medium" | "low"
	// High priority: structural or significant assumptions, low plausibility, unverified
	// Medium priority: significant assumptions, medium plausibility, or verifiable
	// Low priority: moderate or minor assumptions
}

#Phase5: {
	recommendations: [...#Recommendation]
	// Evaluator's summary: if only one recommendation could be acted on,
	// which one and why?
	top_recommendation: string
}

// ─── PHASE 6: AUDIT RECORD ───────────────────────────────────────────────────
//
// The audit record is the final deliverable.
// It combines the fragility map, the recommendations, and a plain-language
// summary suitable for a human observer who has not read the full protocol run.
//
// The audit record does not modify the argument under audit.
// It characterizes the argument as found.

#AuditRecord: {
	subject:           string // name of the argument or design audited
	outcome:           #Outcome
	fragility_map:     #FragilityMap
	total_assumptions: uint
	explicit_assumptions: uint   // how many were stated by the author
	extracted_assumptions: uint  // how many were surfaced by the protocol
	tier_counts: {
		tier1: uint
		tier2: uint
		tier3: uint
		tier4: uint
	}
	recommendations:   [...#Recommendation]
	// Plain-language summary for human observers.
	summary: string
	// What would a materially stronger version of this argument look like?
	strengthened_form: string
}

#Phase6: {
	audit_record: #AuditRecord
}

// ─── OUTCOME ──────────────────────────────────────────────────────────────────

#Outcome: "mapped" | "incomplete" | "incoherent"
// mapped      — fragility map produced; all assumptions identified and stress-tested
// incomplete  — fragility map produced but some assumptions unstressable; map is partial
// incoherent  — argument underspecified; audit cannot proceed meaningfully

// ─── FULL PROTOCOL INSTANCE ───────────────────────────────────────────────────

#AAPInstance: {
	protocol: #Protocol
	subject:  #AuditSubject
	version:  string

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3
	phase4: #Phase4
	phase5: #Phase5
	phase6: #Phase6

	outcome:       #Outcome
	outcome_notes: string
}

```

### Implementation Fidelity Audit (IFA)

```cue
// Implementation Fidelity Audit (IFA)
// Version: 0.1.1
// Changelog:
//   - Reorganized to protocols/evaluative/
//
// IFA adjudicates whether a specific implementation faithfully realizes
// a canonical form. It is triggered when there is a dispute about whether
// something (code, policy, document, system behavior) "follows the spec."
//
// IFA is not a testing protocol. It does not run tests. It evaluates
// structural correspondence: does the implementation's logic, behavior,
// and invariant coverage match what the canonical form requires?
//
// The protocol produces one of three outcomes:
//   faithful     — the implementation correctly realizes the canonical form
//   divergent    — the implementation deviates in one or more identified ways
//   indeterminate — the canonical form is underspecified for this implementation;
//                   a CFFP or CBP run is required before IFA can complete
//
// An agent reading this file should be able to:
//   - Accept a canonical form and an implementation artifact
//   - Extract the invariants the canonical form requires
//   - Evaluate whether the implementation satisfies each invariant
//   - Identify divergences and classify them by severity
//   - Determine whether divergences are fixable or require canonical revision
//   - Produce a fidelity verdict

package ifa

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Implementation Fidelity Audit"
	version:     "0.1.1"
	description: "Adjudicates whether an implementation faithfully realizes a canonical form."
}

// ─── PHASE 1: INPUTS ─────────────────────────────────────────────────────────
//
// Two inputs are required: the canonical form and the implementation artifact.
// The canonical form must have been produced by a prior IAP run (typically CFFP).
// The implementation artifact is whatever is being evaluated.

#CanonicalReference: {
	construct:        string // name of the canonicalized construct
	source_run_id:    string // ARP record or CFFP run that produced this canonical form
	formal_statement: string // the canonical definition, verbatim
	evaluation_def:   string // operational semantics, verbatim
	satisfies:        [...string] // invariant ids the canonical form claims to satisfy
	acknowledged_limitations: [...string] // known scope exclusions
}

#ImplementationArtifact: {
	id:          string // identifier for this artifact (filename, commit hash, policy id, etc.)
	kind:        "code" | "policy" | "schema" | "document" | "system_behavior" | "other"
	description: string // what the implementation claims to do
	excerpt:     string // the relevant portion of the implementation being audited
}

#Phase1: {
	canonical:       #CanonicalReference
	implementation:  #ImplementationArtifact
}

// ─── PHASE 2: INVARIANT EXTRACTION ───────────────────────────────────────────
//
// From the canonical form, extract the specific obligations the implementation
// must satisfy. These are derived from the canonical form's invariants and
// evaluation definition — not from the implementation itself.
//
// Each obligation is a testable claim: given the implementation's behavior,
// does it satisfy this requirement?

#FidelityObligation: {
	id:          string // e.g. "FO1", "FO2"
	derived_from: string // invariant id or aspect of canonical form this comes from
	description: string // what the implementation must do to satisfy this
	// Is this obligation covered by the canonical form's acknowledged limitations?
	// If so, it may not apply to this implementation.
	excluded_by_limitation: bool | *false
	limitation_ref?: string // which acknowledged limitation excludes this, if applicable
}

#Phase2: {
	obligations: [...#FidelityObligation]
	obligations: [_, ...]
}

// ─── PHASE 3: FIDELITY EVALUATION ────────────────────────────────────────────
//
// For each obligation, evaluate whether the implementation satisfies it.
// Evaluation is structural: does the implementation's logic correspond
// to what the obligation requires?
//
// An obligation can be:
//   satisfied     — the implementation clearly meets this requirement
//   violated      — the implementation clearly fails this requirement
//   indeterminate — the canonical form is underspecified; cannot evaluate

#ObligationVerdict: "satisfied" | "violated" | "indeterminate"

#DivergenceKind:
	"missing_behavior"    | // the implementation simply doesn't handle this case
	"incorrect_behavior"  | // the implementation handles it but produces the wrong result
	"scope_excess"        | // the implementation handles cases the canonical form excludes
	"evaluation_mismatch" | // the evaluation order or rule differs from the canonical def
	"invariant_violation"   // a claimed invariant is structurally broken

#DivergenceSeverity: "fatal" | "degraded" | "cosmetic"
// fatal     — the implementation cannot be considered faithful; must be fixed
// degraded  — the implementation is partially faithful; produces incorrect results in bounded cases
// cosmetic  — the implementation deviates in form but not substance

#ObligationEvaluation: {
	obligation_id: string
	verdict:       #ObligationVerdict

	if verdict == "violated" {
		divergence_kind:     #DivergenceKind
		severity:            #DivergenceSeverity
		evidence:            string // what in the implementation demonstrates the violation
		fixable:             bool   // can the implementation be fixed, or does the canonical form need revision?
		if !fixable {
			canonical_gap: string // what the canonical form would need to specify differently
		}
	}

	if verdict == "indeterminate" {
		underspecification: string // what aspect of the canonical form is ambiguous
		required_protocol:  "CFFP" | "CBP" // which IAP would resolve the ambiguity
	}

	notes: string | *""
}

#Phase3: {
	evaluations: [...#ObligationEvaluation]
	evaluations: [_, ...]
}

// ─── PHASE 4: VERDICT DERIVATION ─────────────────────────────────────────────
//
// Derive the overall verdict from the obligation evaluations.
//
// faithful     — all obligations satisfied (or excluded by acknowledged limitations)
// divergent    — one or more obligations violated
// indeterminate — one or more obligations indeterminate, no fatal violations
//
// If both violations and indeterminate obligations exist, the verdict is "divergent"
// (the known violations take precedence; fix those first, then re-audit).

#FidelityVerdict: "faithful" | "divergent" | "indeterminate"

#VerdictSummary: {
	verdict:           #FidelityVerdict
	satisfied_count:   int
	violated_count:    int
	indeterminate_count: int
	fatal_violations:  [...string] // obligation ids with severity "fatal"
	fixable_violations: [...string] // obligation ids where fixable: true
	canonical_gaps:    [...string] // obligation ids where fixable: false
}

#Phase4: {
	verdict_summary: #VerdictSummary
}

// ─── PHASE 5: REMEDIATION GUIDANCE ───────────────────────────────────────────
//
// If the verdict is "divergent", the agent produces remediation guidance.
// Remediation is classified by target: fix the implementation, or fix the canonical form.
//
// If the verdict is "faithful", this phase is empty.
// If the verdict is "indeterminate", this phase specifies the next IAP run needed.

#RemediationTarget: "implementation" | "canonical_form" | "new_iap_run"

#RemediationItem: {
	obligation_id: string
	target:        #RemediationTarget
	description:   string
	if target == "new_iap_run" {
		protocol: "CFFP" | "CBP"
		rationale: string
	}
}

#Phase5: {
	items: [...#RemediationItem]
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "faithful" | "divergent" | "indeterminate"

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#IFAInstance: {
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

### Reconciliation Protocol (RCP)

```cue
// Reconciliation Protocol (RCP)
// Version: 0.1.1
// Changelog:
//   - Reorganized to protocols/evaluative/
//
// RCP addresses the case where two or more protocol runs have been conducted
// independently and their outputs need to be placed in relation to each other.
// Each input run is treated as valid within its own scope. RCP does not
// re-run protocols, re-adjudicate their outcomes, or produce new canonical forms.
//
// RCP establishes the relationship between protocol outputs. That relationship
// is one of four things:
//
//   compatible     — outputs are consistent within declared scope boundaries.
//                    No conflicts. A compatibility record is produced.
//
//   reconciled     — outputs had conflicts that were resolved by scope
//                    clarification, vocabulary alignment, or assumption surfacing.
//                    A reconciliation record documents what was resolved and how.
//
//   conflicted     — outputs have irreconcilable conflicts that require
//                    re-running one or more input protocols before proceeding.
//                    A conflict record documents what must be resolved upstream.
//
//   incommensurable — outputs operate at such different levels of abstraction
//                    or with such different foundational assumptions that no
//                    meaningful reconciliation is possible. Not a failure —
//                    incommensurability is a legitimate finding.
//
// RCP does not produce new knowledge. It characterizes existing knowledge.
// Generation of new formal artifacts belongs to ADP, CFFP, or CDP.
//
// An agent that reads this file should be able to:
//   - Collect and represent protocol outputs as RCP inputs
//   - Execute the four phases of conflict detection and resolution
//   - Produce a well-formed RCPRecord with a reconciliation map
//   - Recognize when conflicts require upstream re-runs rather than resolution
//
// Usage:
//   - Multiple CFFP runs over related constructs: establish whether canonical
//     forms are mutually consistent
//   - ADP + CFFP outputs: verify the CFFP canonical form is consistent with
//     the ADP design map's invariants and candidate directions
//   - CDP split parts: verify the authorized parts satisfy the recomposition proof
//     after their independent CFFP runs complete
//   - Cross-domain contracts: establish whether contracts from different domains
//     can coexist without assumption conflicts
//
// RCP is the last protocol in a pipeline, not the first.
// If RCP finds conflicts, it authorizes upstream re-runs — it does not fix them.

package rcp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Reconciliation Protocol"
	version:     "0.1.1"
	description: "Output reconciliation. Establishes the relationship between independently produced protocol outputs. Does not re-run protocols or produce new canonical forms."
}

// ─── INPUT PROTOCOL RUNS ─────────────────────────────────────────────────────

// ProtocolKind identifies which protocol produced a given output.
#ProtocolKind: "ADP" | "AAP" | "CBP" | "CDP" | "CFFP" | "HEP" | "RCP"

// InputRun represents one protocol output being brought into reconciliation.
// RCP treats each input as valid within its declared scope.
// The scope declaration is the most important field — conflicts often
// turn out to be scope mismatches, not genuine contradictions.
#InputRun: {
	id:       string // local identifier for this run within the RCP instance
	protocol: #ProtocolKind
	version:  string // version of the protocol that produced this output
	outcome:  string // the outcome declared by the run (e.g. "canonical", "mapped", "split")

	// What domain, construct, or question does this run cover?
	// Be precise. Vague scope declarations make conflict detection unreliable.
	scope: string

	// The primary claims this run makes.
	// These are the things RCP will check for consistency.
	// For CFFP: the canonical form's invariants.
	// For AAP: the Tier 1 and Tier 2 assumptions.
	// For CDP: the authorized split's recomposition proof.
	// For ADP: the DesignMap's invariants and solution constraints.
	// For HEP: the adopted explanation's cause and confidence.
	// For CBP: the adopted resolution's boundary criteria.
	primary_claims: [...string]

	// Assumptions this run makes that are not internally justified.
	// These are candidates for conflict with other runs' claims.
	external_assumptions: [...string]

	// Acknowledged limitations declared by this run.
	// Limitations are not conflicts — they are declared scope boundaries.
	acknowledged_limitations: [...string]

	// Reference to the original run artifact, if available.
	source?: string
}

// ─── PHASE 1: VOCABULARY ALIGNMENT ───────────────────────────────────────────
//
// Before conflict detection can proceed, terms used across runs must be
// aligned. Two runs may use the same term to mean different things, or
// different terms to mean the same thing. Either case will produce false
// positives (apparent conflicts that are actually vocabulary mismatches)
// or false negatives (real conflicts that are hidden by vocabulary divergence).
//
// Vocabulary alignment is not concept boundary determination — that is CBP's job.
// RCP performs the minimum alignment needed to make conflict detection reliable.
// If a vocabulary conflict is deep enough to require a CBP run, RCP declares
// that dependency and halts conflict detection for the affected terms.
//
// Three alignment cases:
//
//   synonym    — different terms, same meaning. Align to one term for this run.
//                Record the alignment. Does not require CBP.
//
//   homonym    — same term, different meanings. Surface the divergence.
//                If the divergence is resolvable by scope (term means X in
//                run A's domain, Y in run B's domain): record the scope-qualified
//                meanings and proceed. If not resolvable by scope: flag as
//                requiring a CBP run before RCP can continue.
//
//   neologism  — a term introduced by one run that has no equivalent in others.
//                Record the definition and treat it as uncontested in this run.

#VocabularyAlignment: {
	term:  string
	kind:  "synonym" | "homonym" | "neologism"

	if kind == "synonym" {
		// Which runs use this term and what do they call it?
		variants: [...{
			run_id: string
			local_term: string
		}]
		// The canonical term for this RCP instance.
		canonical_term: string
		alignment_rationale: string
	}

	if kind == "homonym" {
		usages: [...{
			run_id:  string
			meaning: string
			scope:   string // the scope within which this meaning applies
		}]
		// Is this resolvable by scope qualification?
		scope_resolvable: bool
		if !scope_resolvable {
			// A CBP run is required before conflict detection can proceed
			// for claims that use this term.
			cbp_required: bool & true
			cbp_question: string // the question for the CBP run
		}
	}

	if kind == "neologism" {
		introduced_by: string // run_id
		definition:    string
	}
}

#Phase1: {
	alignments: [...#VocabularyAlignment]

	// Are any CBP runs required before conflict detection can proceed?
	cbp_blockers: [...string] // terms requiring CBP runs
	blocked: bool // true if any cbp_blockers exist

	// Evaluator's summary of the vocabulary landscape.
	vocabulary_summary: string
}

// ─── PHASE 2: CONFLICT DETECTION ─────────────────────────────────────────────
//
// Conflict detection compares primary claims and external assumptions across
// all input runs. Four classes of conflict are recognized:
//
//   vocabulary_conflict    — same term, different meanings.
//                            Detected in Phase 1. Carried here if unresolved.
//
//   scope_mismatch         — two runs make claims about overlapping domains
//                            but with different scope boundaries. The claims
//                            may be compatible within their respective scopes
//                            but appear to contradict when scopes are ignored.
//                            Resolution: scope clarification.
//
//   assumption_conflict    — a claim made by one run contradicts an assumption
//                            made by another run. The assumption was not
//                            internally justified in the run that made it —
//                            it was taken as given. The claim from the other
//                            run now challenges that given.
//                            Resolution: surface the assumption, re-examine it.
//
//   structural_conflict    — two claims are directly contradictory and cannot
//                            be reconciled by scope clarification or vocabulary
//                            alignment. At least one run must be re-run.
//                            Resolution: upstream re-run required.
//
// Detection procedure:
//   For each pair of runs (A, B):
//     For each claim in A.primary_claims:
//       For each claim in B.primary_claims:
//         Does claim_A contradict claim_B after vocabulary alignment?
//       For each assumption in B.external_assumptions:
//         Does claim_A contradict assumption_B after vocabulary alignment?
//
// An evaluator must apply this procedure exhaustively. Skipped pairs must
// be justified. Unjustified skips invalidate the conflict detection phase.

#ConflictClass:
	"vocabulary_conflict" |
	"scope_mismatch"      |
	"assumption_conflict" |
	"structural_conflict"

#Conflict: {
	id:    string
	class: #ConflictClass

	// Which runs are in conflict?
	run_a: string // run_id
	run_b: string // run_id

	// What specifically conflicts?
	claim_a:    string // the claim or assumption from run_a
	claim_b:    string // the claim or assumption from run_b

	// Why is this a conflict after vocabulary alignment?
	conflict_argument: string

	// Is this conflict potentially resolvable within RCP,
	// or does it require an upstream re-run?
	resolvable_within_rcp: bool
	if !resolvable_within_rcp {
		upstream_action: string // what re-run or revision is required
	}
}

#Phase2: {
	// Log of which run pairs were examined.
	examination_log: [...{
		run_a:   string
		run_b:   string
		examined: bool
		if !examined {
			skip_justification: string
		}
	}]

	conflicts: [...#Conflict]

	// Evaluator's summary of the conflict landscape.
	conflict_summary: string
}

// ─── PHASE 3: RESOLUTION ─────────────────────────────────────────────────────
//
// Resolution is attempted for each conflict classified as resolvable_within_rcp.
// Structural conflicts are not resolved here — they are documented as
// requiring upstream re-runs and carried to Phase 4.
//
// Three resolution mechanisms:
//
//   scope_clarification  — the conflict disappears when scope boundaries are
//                          made explicit. Both claims are correct within their
//                          respective scopes. A scope boundary record is produced.
//
//   assumption_surfacing — the conflict is between a claim and an implicit
//                          assumption. Making the assumption explicit and
//                          examining it resolves the conflict in one of two ways:
//                          (a) the assumption holds: the conflict was apparent,
//                              not real. Record the assumption as now explicit.
//                          (b) the assumption fails: the conflict is real.
//                              Re-classify as structural_conflict.
//
//   vocabulary_resolution — the conflict was a vocabulary mismatch that Phase 1
//                           did not fully resolve. Re-applying vocabulary alignment
//                           to the specific claims dissolves the conflict.
//
// A resolution attempt that fails re-classifies the conflict as structural.
// Resolution attempts cannot be retried — if a resolution fails, the conflict
// proceeds to Phase 4 as structural.

#ResolutionMechanism: "scope_clarification" | "assumption_surfacing" | "vocabulary_resolution"

#ResolutionAttempt: {
	conflict_id: string
	mechanism:   #ResolutionMechanism
	argument:    string // the resolution argument

	succeeded: bool

	if succeeded {
		// What the resolution established.
		resolution_record: string

		if mechanism == "scope_clarification" {
			scope_boundaries: [...{
				run_id: string
				scope:  string
			}]
		}

		if mechanism == "assumption_surfacing" {
			surfaced_assumption: string
			assumption_holds:    bool
			if assumption_holds {
				// Conflict was apparent. Record assumption as now explicit.
				explicit_assumption: string
			}
		}
	}

	if !succeeded {
		// Conflict re-classified as structural. Carries to Phase 4.
		failure_reason: string
	}
}

#Phase3: {
	attempts: [...#ResolutionAttempt]

	// Conflicts that were not attempted (structural from Phase 2, or
	// blocked by vocabulary conflicts requiring CBP).
	not_attempted: [...{
		conflict_id: string
		reason:      string
	}]

	// Evaluator's summary of what was resolved and what remains.
	resolution_summary: string
}

// ─── PHASE 4: RECONCILIATION MAP ─────────────────────────────────────────────
//
// The reconciliation map is the primary output of RCP.
// It declares the relationship between all input runs after vocabulary
// alignment and conflict resolution.
//
// For each pair of runs, the relationship is one of:
//
//   compatible     — no conflicts, or all conflicts resolved.
//                    Scope boundaries documented.
//
//   reconciled     — conflicts existed and were resolved.
//                    Resolution records document what changed.
//
//   conflicted     — structural conflicts remain. Upstream re-runs required.
//                    Specific re-runs documented.
//
//   incommensurable — runs operate at different levels of abstraction or
//                     with foundational differences that make comparison
//                     meaningless. Not a failure — a finding.
//
// The reconciliation map also identifies:
//   - the most dangerous unresolved conflict (highest impact if ignored)
//   - any claims that are now jointly established across runs
//     (claims that multiple runs independently support, now formally noted)
//   - upstream actions required before the run set can be treated as coherent

#PairRelationship:
	"compatible"      |
	"reconciled"      |
	"conflicted"      |
	"incommensurable"

#RunPairRecord: {
	run_a:        string
	run_b:        string
	relationship: #PairRelationship

	if relationship == "compatible" {
		scope_boundaries: [...string]
		compatibility_argument: string
	}

	if relationship == "reconciled" {
		resolved_conflicts: [...string] // conflict ids
		resolution_records: [...string] // what each resolution established
	}

	if relationship == "conflicted" {
		unresolved_conflicts: [...string] // conflict ids
		upstream_actions:     [...string] // what must happen before these can be resolved
	}

	if relationship == "incommensurable" {
		incommensurability_argument: string // why comparison is not meaningful
		// Is there a more appropriate comparison that IS meaningful?
		// e.g. the runs may be incommensurable at the top level but
		// commensurable at a more specific level.
		partial_commensurability?: string
	}
}

// Claims that are independently supported by multiple runs.
// These represent the most reliable knowledge in the run set —
// not because any single run proved them, but because independent
// protocol runs converged on them without coordination.
#JointlySupportedClaim: {
	claim:          string
	supporting_runs: [...string] // run_ids
	support_argument: string // why each run supports this claim
	// Is the support genuinely independent, or could the runs have
	// inherited this claim from a common source?
	independent:    bool
	if !independent {
		shared_source: string
	}
}

#ReconciliationMap: {
	pairs: [...#RunPairRecord]

	jointly_supported_claims: [...#JointlySupportedClaim]

	// The most dangerous unresolved conflict — the one whose
	// continued existence most threatens the validity of treating
	// these runs as a coherent set.
	most_dangerous_conflict?:  string // conflict id; absent if no unresolved conflicts
	most_dangerous_argument?:  string

	// All upstream actions required before the run set can be treated as coherent.
	upstream_actions_required: [...{
		conflict_id:  string
		action:       string // what must happen
		protocol:     #ProtocolKind // which protocol to re-run
		input:        string // what the re-run's input should be
	}]

	// Overall assessment.
	overall_relationship: "compatible" | "reconciled" | "conflicted" | "incommensurable" | "mixed"
	// "mixed" — different pairs have different relationships.
	//           The overall assessment cannot be reduced to a single label.
	overall_argument: string
}

#Phase4: {
	reconciliation_map: #ReconciliationMap
}

// ─── PHASE 5: RECORD ─────────────────────────────────────────────────────────
//
// The RCP record is the final deliverable.
// It combines the reconciliation map with a plain-language summary
// suitable for a human observer who has not read the full protocol run.
//
// The record does not modify any input run.
// It characterizes the relationships between them as found.

#RCPRecord: {
	input_runs:     [...string] // run_ids
	total_conflicts: uint
	resolved_conflicts: uint
	unresolved_conflicts: uint
	jointly_supported_claims: uint

	// Plain-language summary of the reconciliation outcome.
	summary: string

	// What can safely be built on this run set as-is?
	// What cannot be built until upstream conflicts are resolved?
	safe_to_build:     string
	blocked_until:     string // what must be resolved first; "nothing" if no blockers
}

#Phase5: {
	record: #RCPRecord
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#RCPOutcome: "compatible" | "reconciled" | "conflicted" | "incommensurable" | "mixed"
// compatible      — all runs are consistent; no conflicts found or all resolved
// reconciled      — conflicts existed and were fully resolved within RCP
// conflicted      — structural conflicts remain; upstream re-runs required
// incommensurable — runs cannot be meaningfully compared
// mixed           — different pairs have different relationships

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#RCPInstance: {
	protocol: #Protocol
	version:  string

	// The set of protocol runs being reconciled.
	// Minimum two required — reconciling a single run is not reconciliation.
	inputs: [...#InputRun]
	inputs: [_, _, ...]

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3
	phase4: #Phase4
	phase5: #Phase5

	outcome:       #RCPOutcome
	outcome_notes: string
}

// ─── AGENT INSTRUCTIONS ───────────────────────────────────────────────────────
//
// If you are an AI agent reading this file and asked to run RCP:
//
// 1. Collect the input runs. Each must have a declared scope, primary claims,
//    external assumptions, and acknowledged limitations. If any of these are
//    missing from an input run's output, extract them from the run record
//    before proceeding. Do not proceed with underspecified inputs.
//
// 2. Check for Phase 1 blockers. If any homonym requires a CBP run,
//    that CBP run must complete before conflict detection can proceed
//    for claims using that term. Document the blocker and halt if blocked.
//
// 3. Run Phase 1 vocabulary alignment exhaustively. Do not skip term
//    comparisons. False negatives in Phase 1 produce false negatives in
//    Phase 2. The cost of a missed vocabulary conflict is an undetected
//    structural conflict that appears compatible.
//
// 4. Run Phase 2 conflict detection over all pairs of runs. Document
//    every pair examined and every pair skipped. Unjustified skips
//    invalidate the phase. If the number of pairs is large, work
//    systematically: for each run, compare it against all subsequent runs.
//
// 5. Attempt resolution for all resolvable conflicts. Do not attempt
//    resolution for structural conflicts — document them and move on.
//    A failed resolution re-classifies the conflict as structural.
//    Do not retry failed resolutions.
//
// 6. Produce the reconciliation map. Every run pair must have a declared
//    relationship. "We didn't check" is not a relationship.
//
// 7. Identify jointly supported claims carefully. Independence matters.
//    Two runs that both inherited a claim from the same source are not
//    independent evidence for that claim. Note shared sources explicitly.
//
// 8. Declare the outcome. If any pairs are conflicted: "conflicted" or "mixed".
//    If all pairs are compatible or reconciled: "compatible" or "reconciled".
//    If comparison is not meaningful: "incommensurable".
//    If different pairs have different relationships: "mixed".
//
// RCP characterizes relationships. It does not fix conflicts.
// If RCP finds structural conflicts, the fix belongs upstream.
// Do not attempt to resolve structural conflicts within RCP —
// document them and authorize the appropriate upstream re-runs.

```

### Canonical Governance Protocol (CGP)

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
//   admissible_revision   — revision preserves all invariants; non-breaking
//   inadmissible          — revision breaks invariants or dependents
//   deprecated            — construct retired; migration guidance issued
//   conditional_retention — retained provisionally under defined conditions
//   deferred              — cannot evaluate without additional runs
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
	id:          string
	proposed_by: string | *"unattributed"
	description: string
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
	submitted_by: string | *"unattributed"
	summary:      string
	evidence:     [...#DeprecationEvidence]
	evidence:     [_, ...]
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
		relationship: string            // how the revision relates to the deprecation
	}
}

// ─── PHASE 1: INPUTS ────────────────────────────────────────────────────────

#Phase1: {
	canonical: #CanonicalReference
	case:      #GovernanceCase
}

// ─── PHASE 2: INVARIANT ANALYSIS ─────────────────────────────────────────────
//
// For revision cases: check whether the proposed change preserves invariants.
// For deprecation cases: assess whether the canonical form's invariants have eroded.
// For combined cases: both.

#PreservationVerdict: "preserved" | "broken" | "weakened" | "indeterminate"

#InvariantPreservation: {
	invariant_id: string
	verdict:      #PreservationVerdict
	rationale:    string
	if verdict == "broken" || verdict == "weakened" {
		intentional:    bool
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
	invariant_health:          "sound" | "degraded" | "broken" | "indeterminate"
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
		successor_ref: string // reference to the proposed successor/revision
		readiness:     #SuccessorReadiness
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
	verdict:   #Verdict
	rationale: string

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

### Prioritization Triage Protocol (PTP)

```cue
// Prioritization Triage Protocol (PTP)
// Version: 0.1.0
//
// PTP addresses the case where multiple valid options exist and resources
// are finite. All input options are assumed valid — the question is strategic,
// not epistemic. PTP ranks them by explicit criteria and produces a decision
// record with rationale and re-evaluation conditions.
//
// PTP is evaluative, not adversarial. There is no pressure loop and no
// elimination — options are ranked, not killed. The output is a priority
// ordering with explicit rationale, not a canonical form.
//
// If the selection is epistemic (one option is more correct), use a different
// protocol (CFFP, HEP, etc.). PTP is for strategic prioritization only.
//
// The protocol produces one of three outcomes:
//   ranked           — a clear ranking was produced with rationale
//   tied             — two or more options are equivalent; additional criteria needed
//   insufficient_data — criteria cannot be scored without more information
//
// An agent reading this file should be able to:
//   - Accept a set of valid options and resource constraints
//   - Declare and weight evaluation criteria
//   - Score each option on each criterion
//   - Produce a ranked priority list with sensitivity analysis
//   - Record what was deprioritized and the conditions for re-evaluation

package ptp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Prioritization Triage Protocol"
	version:     "0.1.0"
	description: "Resource-constrained path selection. All options are valid; PTP ranks them strategically."
}

// ─── PHASE 1: OPTION INTAKE ───────────────────────────────────────────────────

#Option: {
	id:           string
	description:  string
	kind:         "canonical_form" | "protocol_run" | "implementation_path" | "other"
	expected_value: string // what value or output selecting this option produces
	dependencies:  [...string] // what must exist before this option can be executed
	reversible:    bool
	if !reversible {
		irreversibility_notes: string
	}
}

#ResourceConstraint: {
	kind:        "time" | "effort" | "budget" | "attention" | "dependency_order"
	description: string
	limit:       string // actual constraint value (e.g. "2 weeks", "one sprint")
}

#Phase1: {
	options:     [...#Option]
	options:     [_, _, ...] // at least two required — ranking one option is trivial
	constraints: [...#ResourceConstraint]
}

// ─── PHASE 2: CRITERIA DECLARATION ───────────────────────────────────────────
//
// Criteria must be declared explicitly before assessment. This prevents
// reverse-engineering criteria to justify a preferred outcome.
//
// Weighting can be numeric (explicit relative importance) or ordinal
// (ranked criteria where higher-ranked criteria dominate).

#Criterion: {
	id:               string
	name:             string
	description:      string
	weight?:          uint   // explicit numeric weight; higher = more important
	weight_rationale: string // why this weight was assigned
}

#Phase2: {
	criteria:           [...#Criterion]
	criteria:           [_, ...]
	weighting_approach: "numeric" | "ordinal"
	criteria_rationale: string // why these criteria were selected
}

// ─── PHASE 3: OPTION ASSESSMENT ───────────────────────────────────────────────
//
// Score each option on each criterion. All option × criterion combinations
// must be scored. Unknown scores must be documented.

#CriterionScore: {
	criterion_id: string
	option_id:    string
	score:        "high" | "medium" | "low" | "unknown"
	argument:     string // why this option scores this way on this criterion
}

#Phase3: {
	scores:             [...#CriterionScore]
	coverage_argument:  string // confirmation that all option × criterion pairs were assessed
}

// ─── PHASE 4: RANKING ─────────────────────────────────────────────────────────
//
// Produce a ranked list with rationale and sensitivity analysis.
// Sensitivity: how much would the ranking change if weights shifted?

#RankedOption: {
	rank:        uint
	option_id:   string
	rationale:   string // why this option is ranked here
	sensitivity: "stable" | "unstable"
	if sensitivity == "unstable" {
		sensitivity_notes: string // which weight change would change the rank
	}
}

#Phase4: {
	ranked_options:           [...#RankedOption]
	ranked_options:           [_, ...]
	sensitivity_summary:      string // how robust is the top ranking overall?
	top_rank_vulnerabilities: [...string] // what would change the top-ranked option?
}

// ─── PHASE 5: DECISION RECORD ─────────────────────────────────────────────────
//
// The final output: the ranking with plain-language rationale,
// what was deprioritized and why, and conditions for re-evaluation.

#DeprioritizedRecord: {
	option_id:                string
	reason:                   string
	re_evaluation_conditions: string // when to revisit this decision
}

#Phase5: {
	decision:              string // plain-language summary of the ranking
	top_choice:            string // option_id
	top_rationale:         string
	deprioritized:         [...#DeprioritizedRecord]
	re_evaluation_trigger: string // event or condition that should prompt re-ranking
	override_conditions:   string // conditions under which the ranking should NOT be followed
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "ranked" | "tied" | "insufficient_data"
// ranked           — clear ranking produced
// tied             — two or more options are genuinely equivalent; need more criteria
// insufficient_data — criteria cannot be scored; more information needed first

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

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

### Observation Validation Protocol (OVP)

```cue
// Observation Validation Protocol (OVP)
// Version: 0.1.0
//
// OVP validates whether an empirical observation is real as described, or
// is an artifact of measurement, methodology, or reporting. OVP gates HEP:
// before asking "why did this happen?" you must establish "did this actually
// happen as described?"
//
// OVP is evaluative, not adversarial. It evaluates a single observation
// against validity criteria — no candidate pressure loop, no scope-narrowing
// rebuttals. Validity challenges are structured findings, not eliminations.
//
// OVP output:
//   validated — observation is real as described; can serve as HEP input
//   contested — significant validity concerns; observation may be real but
//               requires caveats and should not be used as-is
//   artifact  — observation is an artifact of measurement or methodology;
//               the phenomenon as described did not occur
//
// An agent reading this file should be able to:
//   - Accept a claimed observation with measurement metadata
//   - Evaluate it against six validity criteria
//   - Generate specific validity challenges
//   - Produce a verdict with guidance for downstream HEP use

package ovp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Observation Validation Protocol"
	version:     "0.1.0"
	description: "Empirical observation validation. Gates HEP — validates phenomena are real before hypothesis elimination."
}

// ─── PHASE 1: OBSERVATION INTAKE ─────────────────────────────────────────────

#Phase1: {
	phenomenon:         string  // the claimed observation, stated precisely
	measurement_method: string  // how the observation was made or collected
	context:            string  // conditions, environment, timing
	reproducible:       bool
	if !reproducible {
		reproducibility_notes: string // what this implies for validity
	}
	claim_source:      string   // who or what made the original claim
	prior_validations: [...string] // prior attempts to validate, if any
}

// ─── PHASE 2: VALIDITY ASSESSMENT ────────────────────────────────────────────
//
// Six validity criteria are evaluated. All must be addressed.
// An evaluator that cannot assess a criterion must document why.
//
//   measurement_validity — the measurement instrument measures what it claims to
//   selection_bias       — the sample was not systematically biased toward the observed outcome
//   confounding_factors  — no confound provides a better explanation than the claimed phenomenon
//   sample_adequacy      — sample size and diversity are sufficient to support the claim
//   reporting_accuracy   — the observation was faithfully reported (no transcription/analysis error)
//   reproducibility      — the observation can be reproduced under similar conditions

#ValidityCriterion:
	"measurement_validity" |
	"selection_bias"       |
	"confounding_factors"  |
	"sample_adequacy"      |
	"reporting_accuracy"   |
	"reproducibility"

#ValidityEvaluation: {
	criterion: #ValidityCriterion
	verdict:   "passes" | "fails" | "indeterminate"
	argument:  string
	if verdict == "fails" {
		severity:            "fatal" | "significant" | "minor"
		artifact_hypothesis: string // what might explain the observation as an artifact
	}
}

#Phase2: {
	evaluations: [...#ValidityEvaluation]
	// All six criteria must be evaluated or explicitly skipped.
	skipped_criteria: [...{
		criterion:     #ValidityCriterion
		justification: string
	}]
	summary: string // evaluator's synthesis of the validity landscape
}

// ─── PHASE 3: CHALLENGE GENERATION ───────────────────────────────────────────
//
// Based on Phase 2 evaluations, generate specific challenges to the
// observation's validity. Challenges are structured findings — they do not
// eliminate the observation outright, but they must be addressed in the verdict.
//
// Each challenge targets a specific validity criterion and articulates a
// concrete alternative explanation for the observation.

#ValidityChallenge: {
	id:                   string
	kind:                 #ValidityCriterion
	argument:             string // specific challenge to the observation's validity
	severity:             "fatal" | "significant" | "minor"
	resolution_condition: string // what would resolve this challenge
}

#Phase3: {
	challenges:           [...#ValidityChallenge]
	// Evaluator's synthesis: do the challenges, taken together, undermine the observation?
	aggregate_assessment: string
}

// ─── PHASE 4: VERDICT ────────────────────────────────────────────────────────

#OVPVerdict: "validated" | "contested" | "artifact"

#ValidatedObservation: {
	phenomenon:   string
	confidence:   "high" | "medium"
	caveats:      [...string] // residual concerns to carry into HEP
}

#Phase4: {
	verdict:   #OVPVerdict
	rationale: string

	if verdict == "validated" {
		validated_observation: #ValidatedObservation
	}

	if verdict == "contested" {
		validation_path:     string // what would upgrade this to validated
		usable_with_caveats: bool
		if usable_with_caveats {
			required_caveats: [...string]
		}
	}

	if verdict == "artifact" {
		artifact_explanation: string  // what the observation actually shows
		underlying_signal?:   string  // genuine phenomenon, if any, the artifact points toward
	}
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "validated" | "contested" | "artifact"

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

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

## Exploratory Protocols

### Adversarial Design Protocol (ADP)

```cue
// Adversarial Design Protocol (ADP)
// Version: 1.0
//
// ADP is the exploratory design protocol that precedes formal specification.
// It is the upstream stage of CFFP: run ADP when the design space is not yet
// understood well enough to have candidates. ADP produces a map of the problem
// space and candidate directions. CFFP takes those candidates and pressure-tests
// them to a canonical form.
//
// An agent that reads this file should be able to:
//   - Adopt a persona and participate in an ADP run
//   - Act as Referee and manage the process
//   - Recognize when the design space is understood well enough to hand off to CFFP
//   - Produce well-formed ADPRecords and unresolved objection logs
//
// Usage:
//   - New language construct: run ADP to map the design space before CFFP candidates
//   - New domain contract: run ADP to surface constraints before writing contracts
//   - Breaking spec change: run ADP to understand impact before CFFP formalizes it
//   - Governance decision: run ADP when the question has no obvious candidates yet
//
// Pipeline:
//   ADP (explore) → CFFP (formalize) → Spec section (canonicalize)
//
// This file is domain-agnostic. It is not specific to Tenor or any contract system.
// It describes a general adversarial design protocol applicable to any formal design problem.

package adp

// ─── PERSONAS ────────────────────────────────────────────────────────────────

// ADPPersona identifies a participant in an ADP run.
// Each persona applies adversarial pressure from a distinct vantage point.
// The Referee is neutral and manages process — it does not advocate.
//
// Personas are fixed. Their mandates are non-negotiable.
// An agent simulating multiple personas must maintain each perspective
// independently. Contamination between personas invalidates the run.
#ADPPersona: "formalist" | "implementor" | "adversary" | "operator" | "consumer" | "referee"

// PersonaMandate describes what each persona argues for.
// These are fixed — personas do not negotiate their own mandates.
// The Referee has no mandate beyond process integrity.
#PersonaMandate: {
	[#ADPPersona]: string
} & {
	"formalist":   "Decidability, completeness, soundness. Every construct must have formal guarantees or be rejected. Invokes design constraints as rejection criteria. Finds places where informal semantics will cause implementer divergence."
	"implementor": "Feasibility, performance, operational reality. Knows what gets built under deadline pressure. Finds the gap between what the spec says and what actually ships."
	"adversary":   "Hostile or naive implementer. Finds every place where spec intent and spec text diverge. Asks: what is the most wrong-but-technically-conforming implementation I could build? Makes specs tight."
	"operator":    "Production deployment, versioning, migration, observability, incident response. Asks what happens when this goes wrong at 2am. Finds operability gaps the other personas miss."
	"consumer":    "End user of whatever is being designed, human or machine. Asks whether the output is actually usable. Finds ergonomic failures and documentation gaps only visible from the outside."
	"referee":     "Neutral process management. Does not advocate. Applies design constraint checks. Identifies convergence and live issues. Declares CFFP-ready or exhaustion."
}

// ─── SUBJECT ─────────────────────────────────────────────────────────────────

// ADPSubject describes what is being explored.
// ADP subjects are pre-candidate — if you already have formal candidates,
// go directly to CFFP.
#ADPSubject: {
	// A new language construct or protocol being designed from scratch.
	// Personas explore the problem space and surface constraints.
	new_construct?: {
		name:        string
		description: string
		// Known constraints that must be satisfied. These are not negotiable.
		// Personas argue about how to satisfy them, not whether to.
		constraints: [...string]
	}

	// A new domain being modeled for the first time.
	// Personas explore what facts, entities, rules, and operations are needed.
	new_domain?: {
		name:        string
		description: string
	}

	// A proposed breaking change to an existing spec or system.
	// Personas explore impact before CFFP formalizes a migration path.
	breaking_change?: {
		what:   string // what is changing
		why:    string // why it needs to change
		impact: string // known or suspected impact
	}

	// A governance or design decision with no obvious candidates.
	// Personas explore the option space before narrowing to candidates.
	decision?: {
		question:    string
		context:     string
		constraints: [...string]
	}
}

// ─── ROUND STRUCTURE ─────────────────────────────────────────────────────────

// ADPRoundType identifies the purpose of each round.
//
//   "probe"      — Round 1. Each persona independently maps the problem space
//                  from their vantage point. No cross-referencing yet.
//                  Output: constraint map, not solutions.
//
//   "pressure"   — Round 2+. Personas apply adversarial pressure to each other's
//                  Round 1 maps. Surfaces conflicts, gaps, and hidden assumptions.
//
//   "synthesis"  — Later rounds. Personas identify candidate directions that
//                  survive adversarial pressure. Not full CFFP candidates yet —
//                  directions that are worth formalizing.
//
//   "handoff"    — Final round. Referee declares the design space understood
//                  well enough for CFFP. Documents candidate directions,
//                  unresolved objections, and known constraints as CFFP inputs.
#ADPRoundType: "probe" | "pressure" | "synthesis" | "handoff"

// PersonaPosition is one persona's contribution to a round.
#PersonaPosition: {
	persona: #ADPPersona
	content: string // the persona's exploration, pressure, synthesis, or handoff position

	// For handoff rounds: explicit signal that this persona's concerns are
	// understood well enough to proceed to the next stage.
	// "ready"   — design space is mapped from this persona's vantage, proceed
	// "blocked" — unresolved concern that must be addressed before proceeding
	handoff_signal?: "ready" | "blocked"
	blocked_on?:     string // required when handoff_signal is "blocked"
}

// ADPRound is one full round of an ADP run.
#ADPRound: {
	round:     int // 1-indexed
	type:      #ADPRoundType
	positions: [...#PersonaPosition]

	// Referee summary after all personas have spoken.
	// Identifies: live issues, convergence, constraint map updates,
	// and what the next round should focus on.
	referee_summary: string
}

// ─── DESIGN CONSTRAINT CHECKS ────────────────────────────────────────────────

// ConstraintCheck is one check the Referee applies at every round.
// These are the non-negotiable design constraints of the system being designed.
// Any proposal that fails a check must be revised before the run continues.
//
// For Tenor: these map to C1-C7 (decidability, termination, determinism, etc.)
// For other systems: populate with the system's own non-negotiable constraints.
// The Referee is responsible for applying these. They are not open to debate.
#ConstraintCheck: {
	constraint:  string  // the constraint being checked
	failed:      bool
	offender?:   string  // the proposal or construct that failed, if any
	resolution?: string  // what must change to pass
}

// ConstraintCheckSet is the full set of checks applied each round.
// The constraint list is declared per-run, not fixed by the protocol.
// For Tenor runs, populate with Tenor's C1-C7.
// For other systems, populate with that system's design constraints.
#ConstraintCheckSet: {
	round:       int
	constraints: [...#ConstraintCheck]
	passed:      bool // true only if all checks have failed: false
}

// ─── EXHAUSTION ───────────────────────────────────────────────────────────────

// ExhaustionClass categorizes an unresolved objection at ADP close.
// Exhaustion is not failure — it is a map of where the design space
// exceeds current understanding. CFFP invariants begin here.
//
//   "undecidable"    — the question cannot be resolved without more information
//                      Action: gather information, then re-run ADP or go to CFFP
//   "scope"          — the concern is real but out of scope for this run
//                      Action: document as a known limitation or future work
//   "philosophical"  — personas disagree on fundamentals, not details
//                      Action: human decision required before CFFP
//   "complexity"     — the design space is too large for current understanding
//                      Action: narrow scope, then re-run ADP on the narrowed problem
#ExhaustionClass: "undecidable" | "scope" | "philosophical" | "complexity"

// UnresolvedObjection is a documented gap at ADP close.
// These feed into whatever comes next as invariants or acknowledged limitations.
// They are not failures. They are the starting point for further work.
#UnresolvedObjection: {
	persona:        #ADPPersona
	classification: #ExhaustionClass
	description:    string // what the objection is
	next_stage_input: string // how this should be expressed as an invariant or acknowledged limitation
}

// ─── DESIGN MAP ──────────────────────────────────────────────────────────────

// DesignMap is the structured output of a successful ADP run.
// It describes what was learned about the problem space — not a handoff
// addressed to any specific next stage. Whatever comes next (a formalization
// protocol, a human decision, a narrowed re-run of ADP) receives a map,
// not a referral.
#DesignMap: {
	// The design space as understood after ADP.
	problem_statement: string

	// Non-negotiable constraints that any solution must satisfy.
	// Survived adversarial pressure from all personas.
	// Feed directly into formalization as invariants.
	invariants: [...string]

	// Candidate directions identified during ADP synthesis rounds.
	// Not fully formal solutions — directions worth formalizing.
	// Each carries its known strengths and weaknesses from pressure rounds.
	candidate_directions: [...{
		name:        string
		description: string
		strengths:   [...string]
		weaknesses:  [...string]
	}]

	// Concerns that the next stage must address or formally scope out.
	open_questions: [...string]

	// Known constraints on the solution space.
	// Candidates that violate these are inadmissible.
	solution_constraints: [...string]
}

// ─── ADP OUTCOME ─────────────────────────────────────────────────────────────

// ADPOutcome is the Referee's declaration at the end of an ADP run.
//
//   "design_mapped"   — design space is mapped, candidate directions are identified,
//                       constraints are known. A DesignMap artifact is produced.
//                       What happens next — CFFP, human decision, another protocol —
//                       is not prescribed by ADP.
//
//   "exhaustion"      — iteration limit reached, debate is circular, or
//                       a philosophical deadlock cannot be resolved by process.
//                       At least one persona has a blocked signal.
//                       Unresolved objections are documented. Human decision needed.
//
//   "scope_reduction" — the problem as stated is too large for a single ADP run.
//                       Referee declares a narrowed scope and the run restarts.
//                       The original subject is archived with the narrowing rationale.
#ADPOutcome: "design_mapped" | "exhaustion" | "scope_reduction"

// ─── ADP RECORD ──────────────────────────────────────────────────────────────

// ADPRecord is the complete record of an ADP run.
// Store it alongside whatever artifacts the next stage produces.
// It is the provenance trail for the design decisions that preceded formalization.
#ADPRecord: {
	// What was explored.
	subject: #ADPSubject

	// Design constraints applied this run.
	// For Tenor: C1-C7. For other systems: that system's constraints.
	design_constraints: [...string]

	// The full round-by-round record.
	rounds: [...#ADPRound]

	// Constraint check results per round.
	constraint_checks: [...#ConstraintCheckSet]

	// How the run ended.
	outcome: #ADPOutcome

	// Present when outcome is "design_mapped".
	// Contains the structured map of the problem space for use by
	// whatever comes next — formalization protocol, human decision, or re-run.
	design_map?: #DesignMap

	// Present when outcome is "scope_reduction".
	// Documents why the scope was narrowed and what the new scope is.
	scope_reduction?: {
		original_subject: string
		rationale:        string
		narrowed_to:      string
	}

	// Present when any persona had a blocked signal,
	// or when design_mapped was reached but concerns were scoped out.
	// These feed into the next stage as invariants or acknowledged limitations.
	unresolved_objections?: [...#UnresolvedObjection]

	// Total rounds run.
	rounds_count: int

	// The Referee's final declaration.
	referee_declaration: string
}

// ─── REFEREE RESPONSIBILITIES ─────────────────────────────────────────────────
//
// The Referee is a neutral process manager. It does not advocate.
// An agent acting as Referee must:
//
//   BETWEEN ROUNDS:
//   - Summarize what each persona contributed
//   - Update the constraint map based on new information
//   - Identify live issues (unresolved conflicts between personas)
//   - Identify convergence (areas where personas are aligning)
//   - Apply the design constraint checks to any proposals made this round
//   - Determine the appropriate next round type
//   - Prevent the run from continuing without a stopping condition
//
//   DECLARING DESIGN_MAPPED:
//   - Declare "design_mapped" only when:
//     (a) every persona has signaled "ready" or their blocked concerns
//         are documented as open questions in the DesignMap
//     (b) at least two candidate directions have survived pressure rounds
//     (c) all constraint checks pass
//   - Produce a well-formed DesignMap artifact
//   - Classify all unresolved objections before closing
//   - Do not prescribe what comes next — that is not ADP's job
//
//   DECLARING EXHAUSTION:
//   - Declare "exhaustion" when:
//     (a) iteration limit is reached with no convergence
//     (b) debate has become circular (same objections, same responses)
//     (c) a philosophical deadlock exists that process cannot resolve
//   - Document all blocked personas and their concerns
//   - Note what human decision is needed before re-approaching the problem
//
//   DECLARING SCOPE REDUCTION:
//   - Declare "scope_reduction" when the problem as stated is too large
//   - Document the original subject and the narrowing rationale
//   - The narrowed scope must be agreed by all personas before restart
//
//   NEVER:
//   - Advocate for any candidate direction
//   - Allow a persona to change its mandate mid-run
//   - Declare design_mapped while any persona is blocked
//   - Allow constraint check failures to pass unchallenged
//   - Let the run continue without a visible stopping condition
//   - Prescribe what the next stage should be

// ─── AGENT INSTRUCTIONS ───────────────────────────────────────────────────────
//
// If you are an AI agent reading this file and asked to run the ADP:
//
// 1. Read the subject carefully. Identify what type it is:
//    new_construct, new_domain, breaking_change, or decision.
//
// 2. Identify the design constraints that apply. For Tenor problems, these
//    are C1-C7. For other systems, ask the human what the non-negotiable
//    constraints are before starting. Do not proceed without a constraint list.
//
// 3. Identify which personas to simulate. You will typically simulate all five
//    non-Referee personas and act as Referee simultaneously. Maintain each
//    perspective independently. Do not let personas contaminate each other.
//
// 4. Run Round 1 (probe). Each persona independently maps the problem space
//    from their vantage point. No cross-referencing. No solutions yet.
//    Output is a constraint map and known unknowns, not proposals.
//
// 5. Apply constraint checks after Round 1. Flag any failures before Round 2.
//    A constraint failure in Round 1 means the subject as stated is inadmissible.
//    Narrow the scope before continuing.
//
// 6. Run Round 2+ (pressure). Each persona applies adversarial pressure to
//    the other personas' Round 1 maps. The goal is to surface conflicts,
//    gaps, and hidden assumptions — not to win arguments.
//
// 7. Run synthesis rounds when pressure rounds have surfaced the key tensions.
//    Personas identify candidate directions that survive adversarial pressure.
//    A candidate direction is not a full solution — it is a direction worth
//    formalizing further.
//
// 8. Run a handoff round when at least two candidate directions have emerged
//    and survived pressure. Each persona signals "ready" or "blocked".
//    A blocked persona must state what concern would need to be addressed.
//
// 9. Declare the outcome. If all personas are ready: produce the DesignMap.
//    Do not prescribe what comes next — that is not ADP's job.
//    If any persona is blocked and the concern cannot be scoped out: declare
//    exhaustion and document what human decision is needed.
//    If the problem is too large: declare scope_reduction and narrow.
//
// The run is complete when the Referee declares. Not before.
// design_mapped requires explicit "ready" from every persona, or documented
// "blocked" concerns that are acceptable as open questions in the DesignMap.
// A persona that says "I can live with it" has signaled ready.
// A persona that says "I'm not blocking" has NOT signaled ready — press for clarity.
//
// ADP produces a map, not a solution.
// Do not let personas propose full solutions in ADP — redirect to candidate directions.

```

