// Deprecation Judgment Protocol (DJP)
// Version: 0.1.0
//
// DJP formally adjudicates whether a canonical construct should be deprecated.
// It is triggered when evidence accumulates that a canonical form — though
// internally valid — is no longer fit for purpose: it fails in practice,
// has been superseded by a superior alternative, or has generated more
// acknowledged limitations than it was worth.
//
// DJP is not a replacement protocol. It does not design the successor.
// It produces a deprecation verdict and, if the verdict is "deprecated",
// a deprecation notice that specifies the migration path.
//
// The protocol produces one of three outcomes:
//   deprecated    — the construct is formally deprecated; migration guidance issued
//   retained      — the construct survives; the case for deprecation was insufficient
//   conditional   — the construct is retained provisionally, subject to defined conditions;
//                   if conditions are not met by a specified point, deprecation is automatic
//
// Deprecation is not failure. A construct that served its purpose and is now
// superseded by a better one has done its job. Document the transition cleanly.
//
// An agent reading this file should be able to:
//   - Accept a canonical form and a deprecation case
//   - Evaluate the evidence for and against deprecation
//   - Assess whether a superior alternative exists and is ready
//   - Evaluate the migration burden on known dependents
//   - Produce a deprecation verdict with rationale and guidance

package djp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Deprecation Judgment Protocol"
	version:     "0.1.0"
	description: "Formally adjudicates whether a canonical construct should be deprecated."
}

// ─── PHASE 1: INPUTS ─────────────────────────────────────────────────────────

#CanonicalReference: {
	construct:        string
	source_run_id:    string
	formal_statement: string
	evaluation_def:   string
	satisfies:        [...string]
	acknowledged_limitations: [...string]
	// When was this form canonicalized?
	canonicalized_at: string // ISO 8601 or version reference
}

// The case for deprecation — what evidence is being offered?
#DeprecationCase: {
	submitted_by: string | *"unattributed"
	summary:      string // plain-language summary of why deprecation is proposed

	// What evidence is offered?
	evidence: [...#DeprecationEvidence]
	evidence: [_, ...] // at least one piece of evidence required

	// Is a successor being proposed?
	successor_proposed: bool
	successor_ref?: string // run_id or construct name of the proposed successor
}

#EvidenceKind:
	"practical_failure"    | // the construct fails in documented real cases
	"invariant_erosion"    | // acknowledged limitations have grown to undermine the construct's purpose
	"superior_alternative" | // a better construct exists and is ready
	"design_space_shift"   | // the problem the construct was designed for has changed
	"implementation_burden"  // the construct is too difficult to implement correctly

#DeprecationEvidence: {
	kind:        #EvidenceKind
	description: string
	severity:    "compelling" | "suggestive" | "weak"
	// For practical failures: what broke?
	failure_cases?: [...string]
	// For invariant erosion: which acknowledged limitations are implicated?
	limitation_refs?: [...string]
}

#Phase1: {
	canonical: #CanonicalReference
	case:      #DeprecationCase
}

// ─── PHASE 2: EVIDENCE EVALUATION ────────────────────────────────────────────
//
// Evaluate each piece of evidence. Is it valid? Does it actually support
// the deprecation case, or does it merely suggest the construct needs revision?
//
// A key distinction: evidence that supports revision (RPP) vs. evidence that
// supports deprecation (DJP). The agent must make this distinction explicit.

#EvidenceEvaluation: {
	evidence_index: int // 0-indexed position in case.evidence
	valid:          bool
	rationale:      string

	// Does this evidence support deprecation specifically, or merely revision?
	supports_deprecation: bool
	if !supports_deprecation && valid {
		revision_suggestion: string // what RPP should address instead
	}
}

#Phase2: {
	evaluations: [...#EvidenceEvaluation]
	evaluations: [_, ...]

	// Summary: how much of the evidence is valid and supports deprecation?
	compelling_count:  int
	suggestive_count:  int
	weak_count:        int
	revision_redirects: int // count of valid evidence that supports RPP, not DJP
}

// ─── PHASE 3: SUCCESSOR READINESS ────────────────────────────────────────────
//
// If a successor is proposed, evaluate whether it is ready to assume the
// deprecated construct's obligations. A deprecated construct without a
// ready successor is a gap — not a clean deprecation.
//
// Readiness requires:
//   - The successor has its own canonical form (via CFFP or equivalent)
//   - The successor satisfies all invariants the deprecated construct satisfied
//     (or explicitly supersedes them with stronger ones)
//   - A migration path exists for all known dependents

#SuccessorReadiness: {
	evaluated: bool

	if evaluated {
		has_canonical_form:    bool
		canonical_run_id?:     string
		covers_all_invariants: bool
		invariant_gaps:        [...string] // invariant ids not covered by successor
		migration_path_exists: bool
		migration_description?: string
		ready:                 bool // overall readiness assessment
	}
}

#Phase3: {
	successor_readiness: #SuccessorReadiness
}

// ─── PHASE 4: DEPENDENT IMPACT ────────────────────────────────────────────────
//
// Who depends on this construct? What is the cost of deprecation to each?
// This is a burden assessment, not a blocker — high migration burden informs
// the deprecation notice but does not prevent deprecation if the case is strong.

#MigrationBurden: "trivial" | "moderate" | "significant" | "unknown"

#DependentMigration: {
	dependent_id:  string
	kind:          "canonical_construct" | "implementation" | "protocol_run" | "other"
	burden:        #MigrationBurden
	description:   string
	blocker:       bool // is this dependent blocked from migrating without additional work?
	blocker_notes?: string
}

#Phase4: {
	known_dependents:    [...#DependentMigration]
	total_burden:        "trivial" | "moderate" | "significant" | "unknown"
	blocked_dependents:  [...string] // dependent ids that are blocked
}

// ─── PHASE 5: VERDICT ────────────────────────────────────────────────────────
//
// Synthesize the evidence evaluation, successor readiness, and dependent impact
// into a verdict.
//
// deprecated  — evidence is compelling, successor is ready (or construct has no dependents),
//               migration path exists
// retained    — evidence is insufficient, or successor is not ready, or case is RPP not DJP
// conditional — evidence is suggestive but not compelling, OR successor is not yet ready;
//               retain with conditions and a re-evaluation trigger

#Verdict: "deprecated" | "retained" | "conditional"

#DeprecationNotice: {
	construct:           string
	reason:              string // concise deprecation rationale
	successor?:          string // name of successor construct, if any
	migration_guidance:  string
	effective_at:        string // when this deprecation takes effect (version, date, or event)
}

#RetentionRationale: {
	primary_reason: string
	recommendations: [...string] // what should happen instead (RPP, more evidence, etc.)
}

#ConditionalRetention: {
	conditions: [...string] // what must be true to avoid deprecation
	re_evaluation_trigger: string // when/how to re-run DJP
	provisional_expiry: string // after which automatic deprecation may proceed
}

#Phase5: {
	verdict: #Verdict

	deprecation_notice?:   #DeprecationNotice   // if verdict == "deprecated"
	retention_rationale?:  #RetentionRationale  // if verdict == "retained"
	conditional_retention?: #ConditionalRetention // if verdict == "conditional"
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "deprecated" | "retained" | "conditional"

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#DJPInstance: {
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
