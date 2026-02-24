// Revision Proposal Protocol (RPP)
// Version: 0.1.0
//
// RPP adjudicates whether a proposed change to a canonical form is admissible.
// It is triggered when someone claims a canonical construct isn't wrong, but
// could be improved — and when that claim needs formal evaluation.
//
// RPP is not a redesign protocol. It does not produce a new canonical form
// from scratch. It evaluates a specific, bounded revision against the existing
// canonical form and produces a ruling on whether the revision:
//   - preserves all existing invariants
//   - introduces no new failure modes
//   - is strictly non-breaking with respect to all known dependents
//
// The protocol produces one of three outcomes:
//   admissible    — the revision preserves all invariants and is non-breaking; adopt it
//   inadmissible  — the revision breaks one or more invariants or dependents; reject it
//   deferred      — the revision may be valid but cannot be evaluated without additional
//                   runs (e.g., the dependent landscape is incomplete)
//
// An agent reading this file should be able to:
//   - Accept a canonical form and a proposed revision
//   - Enumerate all invariants the canonical form satisfies
//   - Evaluate whether the revision satisfies each invariant
//   - Identify all known dependents and assess breaking impact
//   - Produce a ruling with rationale

package rpp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Revision Proposal Protocol"
	version:     "0.1.0"
	description: "Adjudicates whether a proposed revision to a canonical form is admissible."
}

// ─── PHASE 1: INPUTS ─────────────────────────────────────────────────────────

#CanonicalReference: {
	construct:        string
	source_run_id:    string
	formal_statement: string
	evaluation_def:   string
	satisfies:        [...string]
	acknowledged_limitations: [...string]
}

#RevisionProposal: {
	id:          string
	proposed_by: string | *"unattributed"
	description: string // plain-language description of what is being changed and why

	// The proposed replacement for the canonical form's fields.
	// Only changed fields need to be specified. Unchanged fields are inherited.
	changes: {
		formal_statement?: string
		evaluation_def?:   string
		add_invariants?:   [...string]
		remove_invariants?: [...string]
		add_limitations?:  [...string]
		remove_limitations?: [...string]
	}

	// What is the stated motivation for the revision?
	motivation: string

	// Does the proposer claim this is non-breaking?
	claims_non_breaking: bool
}

#Phase1: {
	canonical: #CanonicalReference
	proposal:  #RevisionProposal
}

// ─── PHASE 2: INVARIANT PRESERVATION CHECK ───────────────────────────────────
//
// For each invariant the canonical form satisfies, evaluate whether the
// proposed revision preserves it. A revision that removes an invariant must
// provide a justification — otherwise it is automatically inadmissible.
//
// New invariants proposed by the revision are evaluated as additions:
// they must be satisfiable by the revised form and not contradict existing invariants.

#PreservationVerdict: "preserved" | "broken" | "weakened" | "indeterminate"
// preserved     — the revision satisfies this invariant as strongly as the original
// broken        — the revision violates this invariant
// weakened      — the revision satisfies the invariant but less strongly (scope reduction)
// indeterminate — cannot evaluate without additional runs

#InvariantPreservation: {
	invariant_id: string
	verdict:      #PreservationVerdict
	rationale:    string

	if verdict == "broken" || verdict == "weakened" {
		// Is this intentional? (e.g., the proposer is deliberately narrowing scope)
		intentional: bool
		if intentional {
			justification: string
		}
	}
}

#NewInvariantEvaluation: {
	invariant_id:  string
	description:   string
	satisfiable:   bool
	contradicts:   [...string] // existing invariant ids this would contradict, if any
	rationale:     string
}

#Phase2: {
	preservation_checks: [...#InvariantPreservation]
	preservation_checks: [_, ...]
	new_invariant_evaluations: [...#NewInvariantEvaluation]
}

// ─── PHASE 3: DEPENDENT IMPACT ASSESSMENT ────────────────────────────────────
//
// Who depends on this canonical form? For each known dependent, assess whether
// the revision would break it. A "break" is any change that causes a dependent
// to violate its own invariants or produce incorrect behavior.
//
// If the dependent landscape is incomplete — i.e., there are known unknowns —
// the run may be deferred.

#Dependent: {
	id:          string // construct name, run_id, or system identifier
	kind:        "canonical_construct" | "implementation" | "protocol_run" | "other"
	description: string
}

#DependentImpact: {
	dependent_id: string
	breaking:     bool
	rationale:    string
	if breaking {
		severity:    "fatal" | "degraded"
		description: string
	}
}

#Phase3: {
	known_dependents: [...#Dependent]
	impact_assessments: [...#DependentImpact]

	// Are there dependents that could not be assessed?
	incomplete_landscape: bool
	if incomplete_landscape {
		unknown_dependents: string // description of what is unknown and why
	}
}

// ─── PHASE 4: RULING ─────────────────────────────────────────────────────────
//
// Synthesize Phase 2 and Phase 3 into a ruling.
//
// admissible   — all invariants preserved (or intentionally relaxed with justification),
//                no breaking dependent impacts
// inadmissible — one or more invariants broken without justification, or breaking impact
//                on one or more dependents
// deferred     — indeterminate invariant evaluations or incomplete dependent landscape;
//                cannot rule without additional information

#RulingVerdict: "admissible" | "inadmissible" | "deferred"

#Ruling: {
	verdict:          #RulingVerdict
	rationale:        string

	if verdict == "inadmissible" {
		blocking_reasons: [...string] // what specifically makes this inadmissible
	}

	if verdict == "deferred" {
		required_before_ruling: [...string] // what runs or information are needed
	}

	if verdict == "admissible" {
		// What does the revised canonical form look like?
		revised_statement:    string
		revised_evaluation:   string
		revised_satisfies:    [...string]
		revised_limitations:  [...string]
	}
}

#Phase4: {
	ruling: #Ruling
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "admissible" | "inadmissible" | "deferred"

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#RPPInstance: {
	protocol: #Protocol
	version:  string

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3
	phase4: #Phase4

	outcome:       #Outcome
	outcome_notes: string
}
