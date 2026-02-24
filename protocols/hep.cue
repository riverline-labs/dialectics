// Hypothesis Elimination Protocol (HEP)
// Version: 0.1.0
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
	version:     "0.1.0"
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
	source_ids:    [...string] // evidence item ids that caused elimination
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
