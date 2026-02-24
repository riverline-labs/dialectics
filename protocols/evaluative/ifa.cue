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
