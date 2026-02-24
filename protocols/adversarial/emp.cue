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
