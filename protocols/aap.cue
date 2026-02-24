// Assumption Audit Protocol (AAP)
// Version: 0.1.0
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
	version:     "0.1.0"
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
