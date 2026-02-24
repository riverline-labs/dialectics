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
