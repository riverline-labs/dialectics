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
