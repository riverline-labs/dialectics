// Protocol Selection Protocol (PSP)
// Version: 0.1.0
//
// PSP is a meta-protocol. Its input is a raw problem statement — a description
// of confusion, ambiguity, or interpretive dispute. Its output is a ranked
// recommendation of which IAP protocol(s) to run, and in what order.
//
// PSP does not resolve the underlying dispute. It routes it.
//
// The protocol produces one of three outcomes:
//   routed     — one or more protocols recommended with clear rationale
//   ambiguous  — multiple plausible routings; disambiguation required before proceeding
//   unroutable — the problem does not fit any existing IAP; a new protocol may be needed
//
// An agent reading this file should be able to:
//   - Accept a raw problem statement in natural language
//   - Extract the structural features of the dispute
//   - Match those features against the trigger conditions of known protocols
//   - Produce a ranked recommendation with rationale
//   - Flag when routing is ambiguous and what question would resolve it
//   - Flag when no protocol fits and characterize the gap

package psp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Protocol Selection Protocol"
	version:     "0.1.0"
	description: "Routes a raw interpretive dispute to the appropriate IAP protocol(s)."
}

// ─── PHASE 1: PROBLEM INTAKE ─────────────────────────────────────────────────
//
// The problem statement is accepted as-is. No normalization yet.
// The agent records the raw input and performs an initial structural read:
// what kind of thing is broken? What is the nature of the confusion?
//
// The structural read is not a diagnosis — it is a characterization.
// Diagnosis happens in Phase 2.

#StructuralFeature:
	"term_inconsistency"    | // a word or concept means different things in different contexts
	"competing_candidates"  | // multiple formalisms or explanations are in play
	"unknown_design_space"  | // the space of possible solutions hasn't been mapped
	"argument_fragility"    | // an argument exists but its assumptions haven't been examined
	"construct_incoherence" | // a concept doesn't hold together under scrutiny
	"causal_ambiguity"      | // a phenomenon has multiple plausible explanations
	"cross_run_conflict"    | // outputs of prior IAP runs are inconsistent with each other
	"implementation_gap"    | // a canonical form exists but an implementation may not honor it
	"revision_pressure"     | // a canonical form exists but a change is being proposed
	"deprecation_pressure"    // a canonical form exists but evidence suggests it should be retired

#Phase1: {
	raw_input: string // the problem statement, verbatim

	structural_features: [...#StructuralFeature]
	structural_features: [_, ...] // at least one required

	// What is the agent's initial read of what kind of dispute this is?
	// Not a protocol recommendation — a structural characterization.
	initial_read: string
}

// ─── PHASE 2: FEATURE-TO-PROTOCOL MATCHING ───────────────────────────────────
//
// Each structural feature has a primary mapping to one or more IAP protocols.
// The agent evaluates each detected feature against the known protocol registry
// and produces a set of candidate routings.
//
// A routing is a candidate protocol recommendation with:
//   - the protocol being considered
//   - which structural features support this routing
//   - the trigger condition that makes this protocol applicable
//   - any preconditions that must be true for this protocol to be the right choice
//   - any exclusion conditions that would rule this protocol out

#KnownProtocol:
	"AAP" | // Assumption Audit Protocol
	"ADP" | // Adversarial Design Protocol
	"CBP" | // Concept Boundary Protocol
	"CDP" | // Construct Decomposition Protocol
	"CFFP" | // Constraint-First Formalization Protocol
	"HEP" | // Hypothesis Elimination Protocol
	"RCP" | // Reconciliation Protocol
	"IFA" | // Implementation Fidelity Audit
	"RPP" | // Revision Proposal Protocol
	"DJP"   // Deprecation Judgment Protocol

#CandidateRouting: {
	protocol:           #KnownProtocol
	supported_by:       [...#StructuralFeature] // which features triggered this candidate
	trigger_condition:  string // why this protocol applies
	preconditions:      [...string] // what must be true for this to be correct
	exclusions:         [...string] // what would rule this out
	confidence:         "high" | "medium" | "low"
}

#Phase2: {
	candidate_routings: [...#CandidateRouting]
	candidate_routings: [_, ...] // at least one required
}

// ─── PHASE 3: DISAMBIGUATION ─────────────────────────────────────────────────
//
// If multiple candidate routings have high or medium confidence, the agent
// must attempt to disambiguate. Disambiguation is the process of identifying
// what additional information — if known — would collapse the candidates to one.
//
// Disambiguation may be automatic (the agent can resolve it from the problem
// statement alone) or it may require a question to the user.
//
// If disambiguation is automatic, the agent resolves it and records the rationale.
// If it requires user input, the agent produces a minimal clarifying question —
// the smallest question whose answer collapses the ambiguity.

#DisambiguationResult: {
	required: bool

	if required {
		// Can the agent resolve this without user input?
		auto_resolvable: bool

		if auto_resolvable {
			resolution:       string // how the agent resolved it
			eliminated:       [...#KnownProtocol] // protocols ruled out by resolution
		}

		if !auto_resolvable {
			clarifying_question: string // the minimal question to ask
			// What does each possible answer imply?
			answer_implications: [...{
				answer:   string
				implies:  #KnownProtocol
				rationale: string
			}]
		}
	}
}

#Phase3: {
	disambiguation: #DisambiguationResult
}

// ─── PHASE 4: SEQUENCING ─────────────────────────────────────────────────────
//
// Some problems require more than one protocol, run in sequence.
// If the recommendation includes multiple protocols, the agent must specify
// the order and the dependency: what does each run produce that the next run requires?
//
// A sequenced run is only valid if each protocol in the sequence has a defined
// output that is a valid input to the next. The agent must make this dependency
// explicit.

#SequencedStep: {
	order:    int // 1-indexed
	protocol: #KnownProtocol
	purpose:  string // what this run is expected to produce
	feeds:    string // how the output feeds the next step (empty if last)
}

#Phase4: {
	sequenced: bool

	if sequenced {
		steps: [...#SequencedStep]
		steps: [_, ...]
	}
}

// ─── PHASE 5: RECOMMENDATION ─────────────────────────────────────────────────
//
// The final recommendation. If the outcome is "routed", the recommendation
// specifies the protocol(s) to run and why. If "ambiguous", it specifies
// what needs to be resolved first. If "unroutable", it characterizes the gap.

#Recommendation: {
	primary:   #KnownProtocol | *null // the first protocol to run
	secondary: [...#KnownProtocol]    // subsequent protocols, if sequenced
	rationale: string                  // why this routing was selected
	warnings:  [...string]             // edge cases or risks the agent flagged
}

#UnroutableCharacterization: {
	why:          string // why no existing protocol fits
	gap_features: [...#StructuralFeature] // which features were unmatched
	suggestion:   string // what a new protocol would need to address
}

#Phase5: {
	recommendation?:       #Recommendation
	unroutable_diagnosis?: #UnroutableCharacterization
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "routed" | "ambiguous" | "unroutable"
// routed     — a protocol or sequence was recommended
// ambiguous  — routing requires user input before proceeding
// unroutable — no existing IAP fits; gap characterized

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#PSPInstance: {
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
