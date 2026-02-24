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
