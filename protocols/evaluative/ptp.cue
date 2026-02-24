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
