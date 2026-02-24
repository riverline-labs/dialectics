// Reconciliation Protocol (RCP)
// Version: 0.1.1
// Changelog:
//   - Reorganized to protocols/evaluative/
//
// RCP addresses the case where two or more protocol runs have been conducted
// independently and their outputs need to be placed in relation to each other.
// Each input run is treated as valid within its own scope. RCP does not
// re-run protocols, re-adjudicate their outcomes, or produce new canonical forms.
//
// RCP establishes the relationship between protocol outputs. That relationship
// is one of four things:
//
//   compatible     — outputs are consistent within declared scope boundaries.
//                    No conflicts. A compatibility record is produced.
//
//   reconciled     — outputs had conflicts that were resolved by scope
//                    clarification, vocabulary alignment, or assumption surfacing.
//                    A reconciliation record documents what was resolved and how.
//
//   conflicted     — outputs have irreconcilable conflicts that require
//                    re-running one or more input protocols before proceeding.
//                    A conflict record documents what must be resolved upstream.
//
//   incommensurable — outputs operate at such different levels of abstraction
//                    or with such different foundational assumptions that no
//                    meaningful reconciliation is possible. Not a failure —
//                    incommensurability is a legitimate finding.
//
// RCP does not produce new knowledge. It characterizes existing knowledge.
// Generation of new formal artifacts belongs to ADP, CFFP, or CDP.
//
// An agent that reads this file should be able to:
//   - Collect and represent protocol outputs as RCP inputs
//   - Execute the four phases of conflict detection and resolution
//   - Produce a well-formed RCPRecord with a reconciliation map
//   - Recognize when conflicts require upstream re-runs rather than resolution
//
// Usage:
//   - Multiple CFFP runs over related constructs: establish whether canonical
//     forms are mutually consistent
//   - ADP + CFFP outputs: verify the CFFP canonical form is consistent with
//     the ADP design map's invariants and candidate directions
//   - CDP split parts: verify the authorized parts satisfy the recomposition proof
//     after their independent CFFP runs complete
//   - Cross-domain contracts: establish whether contracts from different domains
//     can coexist without assumption conflicts
//
// RCP is the last protocol in a pipeline, not the first.
// If RCP finds conflicts, it authorizes upstream re-runs — it does not fix them.

package rcp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Reconciliation Protocol"
	version:     "0.1.1"
	description: "Output reconciliation. Establishes the relationship between independently produced protocol outputs. Does not re-run protocols or produce new canonical forms."
}

// ─── INPUT PROTOCOL RUNS ─────────────────────────────────────────────────────

// ProtocolKind identifies which protocol produced a given output.
#ProtocolKind: "ADP" | "AAP" | "CBP" | "CDP" | "CFFP" | "HEP" | "RCP"

// InputRun represents one protocol output being brought into reconciliation.
// RCP treats each input as valid within its declared scope.
// The scope declaration is the most important field — conflicts often
// turn out to be scope mismatches, not genuine contradictions.
#InputRun: {
	id:       string // local identifier for this run within the RCP instance
	protocol: #ProtocolKind
	version:  string // version of the protocol that produced this output
	outcome:  string // the outcome declared by the run (e.g. "canonical", "mapped", "split")

	// What domain, construct, or question does this run cover?
	// Be precise. Vague scope declarations make conflict detection unreliable.
	scope: string

	// The primary claims this run makes.
	// These are the things RCP will check for consistency.
	// For CFFP: the canonical form's invariants.
	// For AAP: the Tier 1 and Tier 2 assumptions.
	// For CDP: the authorized split's recomposition proof.
	// For ADP: the DesignMap's invariants and solution constraints.
	// For HEP: the adopted explanation's cause and confidence.
	// For CBP: the adopted resolution's boundary criteria.
	primary_claims: [...string]

	// Assumptions this run makes that are not internally justified.
	// These are candidates for conflict with other runs' claims.
	external_assumptions: [...string]

	// Acknowledged limitations declared by this run.
	// Limitations are not conflicts — they are declared scope boundaries.
	acknowledged_limitations: [...string]

	// Reference to the original run artifact, if available.
	source?: string
}

// ─── PHASE 1: VOCABULARY ALIGNMENT ───────────────────────────────────────────
//
// Before conflict detection can proceed, terms used across runs must be
// aligned. Two runs may use the same term to mean different things, or
// different terms to mean the same thing. Either case will produce false
// positives (apparent conflicts that are actually vocabulary mismatches)
// or false negatives (real conflicts that are hidden by vocabulary divergence).
//
// Vocabulary alignment is not concept boundary determination — that is CBP's job.
// RCP performs the minimum alignment needed to make conflict detection reliable.
// If a vocabulary conflict is deep enough to require a CBP run, RCP declares
// that dependency and halts conflict detection for the affected terms.
//
// Three alignment cases:
//
//   synonym    — different terms, same meaning. Align to one term for this run.
//                Record the alignment. Does not require CBP.
//
//   homonym    — same term, different meanings. Surface the divergence.
//                If the divergence is resolvable by scope (term means X in
//                run A's domain, Y in run B's domain): record the scope-qualified
//                meanings and proceed. If not resolvable by scope: flag as
//                requiring a CBP run before RCP can continue.
//
//   neologism  — a term introduced by one run that has no equivalent in others.
//                Record the definition and treat it as uncontested in this run.

#VocabularyAlignment: {
	term:  string
	kind:  "synonym" | "homonym" | "neologism"

	if kind == "synonym" {
		// Which runs use this term and what do they call it?
		variants: [...{
			run_id: string
			local_term: string
		}]
		// The canonical term for this RCP instance.
		canonical_term: string
		alignment_rationale: string
	}

	if kind == "homonym" {
		usages: [...{
			run_id:  string
			meaning: string
			scope:   string // the scope within which this meaning applies
		}]
		// Is this resolvable by scope qualification?
		scope_resolvable: bool
		if !scope_resolvable {
			// A CBP run is required before conflict detection can proceed
			// for claims that use this term.
			cbp_required: bool & true
			cbp_question: string // the question for the CBP run
		}
	}

	if kind == "neologism" {
		introduced_by: string // run_id
		definition:    string
	}
}

#Phase1: {
	alignments: [...#VocabularyAlignment]

	// Are any CBP runs required before conflict detection can proceed?
	cbp_blockers: [...string] // terms requiring CBP runs
	blocked: bool // true if any cbp_blockers exist

	// Evaluator's summary of the vocabulary landscape.
	vocabulary_summary: string
}

// ─── PHASE 2: CONFLICT DETECTION ─────────────────────────────────────────────
//
// Conflict detection compares primary claims and external assumptions across
// all input runs. Four classes of conflict are recognized:
//
//   vocabulary_conflict    — same term, different meanings.
//                            Detected in Phase 1. Carried here if unresolved.
//
//   scope_mismatch         — two runs make claims about overlapping domains
//                            but with different scope boundaries. The claims
//                            may be compatible within their respective scopes
//                            but appear to contradict when scopes are ignored.
//                            Resolution: scope clarification.
//
//   assumption_conflict    — a claim made by one run contradicts an assumption
//                            made by another run. The assumption was not
//                            internally justified in the run that made it —
//                            it was taken as given. The claim from the other
//                            run now challenges that given.
//                            Resolution: surface the assumption, re-examine it.
//
//   structural_conflict    — two claims are directly contradictory and cannot
//                            be reconciled by scope clarification or vocabulary
//                            alignment. At least one run must be re-run.
//                            Resolution: upstream re-run required.
//
// Detection procedure:
//   For each pair of runs (A, B):
//     For each claim in A.primary_claims:
//       For each claim in B.primary_claims:
//         Does claim_A contradict claim_B after vocabulary alignment?
//       For each assumption in B.external_assumptions:
//         Does claim_A contradict assumption_B after vocabulary alignment?
//
// An evaluator must apply this procedure exhaustively. Skipped pairs must
// be justified. Unjustified skips invalidate the conflict detection phase.

#ConflictClass:
	"vocabulary_conflict" |
	"scope_mismatch"      |
	"assumption_conflict" |
	"structural_conflict"

#Conflict: {
	id:    string
	class: #ConflictClass

	// Which runs are in conflict?
	run_a: string // run_id
	run_b: string // run_id

	// What specifically conflicts?
	claim_a:    string // the claim or assumption from run_a
	claim_b:    string // the claim or assumption from run_b

	// Why is this a conflict after vocabulary alignment?
	conflict_argument: string

	// Is this conflict potentially resolvable within RCP,
	// or does it require an upstream re-run?
	resolvable_within_rcp: bool
	if !resolvable_within_rcp {
		upstream_action: string // what re-run or revision is required
	}
}

#Phase2: {
	// Log of which run pairs were examined.
	examination_log: [...{
		run_a:   string
		run_b:   string
		examined: bool
		if !examined {
			skip_justification: string
		}
	}]

	conflicts: [...#Conflict]

	// Evaluator's summary of the conflict landscape.
	conflict_summary: string
}

// ─── PHASE 3: RESOLUTION ─────────────────────────────────────────────────────
//
// Resolution is attempted for each conflict classified as resolvable_within_rcp.
// Structural conflicts are not resolved here — they are documented as
// requiring upstream re-runs and carried to Phase 4.
//
// Three resolution mechanisms:
//
//   scope_clarification  — the conflict disappears when scope boundaries are
//                          made explicit. Both claims are correct within their
//                          respective scopes. A scope boundary record is produced.
//
//   assumption_surfacing — the conflict is between a claim and an implicit
//                          assumption. Making the assumption explicit and
//                          examining it resolves the conflict in one of two ways:
//                          (a) the assumption holds: the conflict was apparent,
//                              not real. Record the assumption as now explicit.
//                          (b) the assumption fails: the conflict is real.
//                              Re-classify as structural_conflict.
//
//   vocabulary_resolution — the conflict was a vocabulary mismatch that Phase 1
//                           did not fully resolve. Re-applying vocabulary alignment
//                           to the specific claims dissolves the conflict.
//
// A resolution attempt that fails re-classifies the conflict as structural.
// Resolution attempts cannot be retried — if a resolution fails, the conflict
// proceeds to Phase 4 as structural.

#ResolutionMechanism: "scope_clarification" | "assumption_surfacing" | "vocabulary_resolution"

#ResolutionAttempt: {
	conflict_id: string
	mechanism:   #ResolutionMechanism
	argument:    string // the resolution argument

	succeeded: bool

	if succeeded {
		// What the resolution established.
		resolution_record: string

		if mechanism == "scope_clarification" {
			scope_boundaries: [...{
				run_id: string
				scope:  string
			}]
		}

		if mechanism == "assumption_surfacing" {
			surfaced_assumption: string
			assumption_holds:    bool
			if assumption_holds {
				// Conflict was apparent. Record assumption as now explicit.
				explicit_assumption: string
			}
		}
	}

	if !succeeded {
		// Conflict re-classified as structural. Carries to Phase 4.
		failure_reason: string
	}
}

#Phase3: {
	attempts: [...#ResolutionAttempt]

	// Conflicts that were not attempted (structural from Phase 2, or
	// blocked by vocabulary conflicts requiring CBP).
	not_attempted: [...{
		conflict_id: string
		reason:      string
	}]

	// Evaluator's summary of what was resolved and what remains.
	resolution_summary: string
}

// ─── PHASE 4: RECONCILIATION MAP ─────────────────────────────────────────────
//
// The reconciliation map is the primary output of RCP.
// It declares the relationship between all input runs after vocabulary
// alignment and conflict resolution.
//
// For each pair of runs, the relationship is one of:
//
//   compatible     — no conflicts, or all conflicts resolved.
//                    Scope boundaries documented.
//
//   reconciled     — conflicts existed and were resolved.
//                    Resolution records document what changed.
//
//   conflicted     — structural conflicts remain. Upstream re-runs required.
//                    Specific re-runs documented.
//
//   incommensurable — runs operate at different levels of abstraction or
//                     with foundational differences that make comparison
//                     meaningless. Not a failure — a finding.
//
// The reconciliation map also identifies:
//   - the most dangerous unresolved conflict (highest impact if ignored)
//   - any claims that are now jointly established across runs
//     (claims that multiple runs independently support, now formally noted)
//   - upstream actions required before the run set can be treated as coherent

#PairRelationship:
	"compatible"      |
	"reconciled"      |
	"conflicted"      |
	"incommensurable"

#RunPairRecord: {
	run_a:        string
	run_b:        string
	relationship: #PairRelationship

	if relationship == "compatible" {
		scope_boundaries: [...string]
		compatibility_argument: string
	}

	if relationship == "reconciled" {
		resolved_conflicts: [...string] // conflict ids
		resolution_records: [...string] // what each resolution established
	}

	if relationship == "conflicted" {
		unresolved_conflicts: [...string] // conflict ids
		upstream_actions:     [...string] // what must happen before these can be resolved
	}

	if relationship == "incommensurable" {
		incommensurability_argument: string // why comparison is not meaningful
		// Is there a more appropriate comparison that IS meaningful?
		// e.g. the runs may be incommensurable at the top level but
		// commensurable at a more specific level.
		partial_commensurability?: string
	}
}

// Claims that are independently supported by multiple runs.
// These represent the most reliable knowledge in the run set —
// not because any single run proved them, but because independent
// protocol runs converged on them without coordination.
#JointlySupportedClaim: {
	claim:          string
	supporting_runs: [...string] // run_ids
	support_argument: string // why each run supports this claim
	// Is the support genuinely independent, or could the runs have
	// inherited this claim from a common source?
	independent:    bool
	if !independent {
		shared_source: string
	}
}

#ReconciliationMap: {
	pairs: [...#RunPairRecord]

	jointly_supported_claims: [...#JointlySupportedClaim]

	// The most dangerous unresolved conflict — the one whose
	// continued existence most threatens the validity of treating
	// these runs as a coherent set.
	most_dangerous_conflict?:  string // conflict id; absent if no unresolved conflicts
	most_dangerous_argument?:  string

	// All upstream actions required before the run set can be treated as coherent.
	upstream_actions_required: [...{
		conflict_id:  string
		action:       string // what must happen
		protocol:     #ProtocolKind // which protocol to re-run
		input:        string // what the re-run's input should be
	}]

	// Overall assessment.
	overall_relationship: "compatible" | "reconciled" | "conflicted" | "incommensurable" | "mixed"
	// "mixed" — different pairs have different relationships.
	//           The overall assessment cannot be reduced to a single label.
	overall_argument: string
}

#Phase4: {
	reconciliation_map: #ReconciliationMap
}

// ─── PHASE 5: RECORD ─────────────────────────────────────────────────────────
//
// The RCP record is the final deliverable.
// It combines the reconciliation map with a plain-language summary
// suitable for a human observer who has not read the full protocol run.
//
// The record does not modify any input run.
// It characterizes the relationships between them as found.

#RCPRecord: {
	input_runs:     [...string] // run_ids
	total_conflicts: uint
	resolved_conflicts: uint
	unresolved_conflicts: uint
	jointly_supported_claims: uint

	// Plain-language summary of the reconciliation outcome.
	summary: string

	// What can safely be built on this run set as-is?
	// What cannot be built until upstream conflicts are resolved?
	safe_to_build:     string
	blocked_until:     string // what must be resolved first; "nothing" if no blockers
}

#Phase5: {
	record: #RCPRecord
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#RCPOutcome: "compatible" | "reconciled" | "conflicted" | "incommensurable" | "mixed"
// compatible      — all runs are consistent; no conflicts found or all resolved
// reconciled      — conflicts existed and were fully resolved within RCP
// conflicted      — structural conflicts remain; upstream re-runs required
// incommensurable — runs cannot be meaningfully compared
// mixed           — different pairs have different relationships

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#RCPInstance: {
	protocol: #Protocol
	version:  string

	// The set of protocol runs being reconciled.
	// Minimum two required — reconciling a single run is not reconciliation.
	inputs: [...#InputRun]
	inputs: [_, _, ...]

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3
	phase4: #Phase4
	phase5: #Phase5

	outcome:       #RCPOutcome
	outcome_notes: string
}

// ─── AGENT INSTRUCTIONS ───────────────────────────────────────────────────────
//
// If you are an AI agent reading this file and asked to run RCP:
//
// 1. Collect the input runs. Each must have a declared scope, primary claims,
//    external assumptions, and acknowledged limitations. If any of these are
//    missing from an input run's output, extract them from the run record
//    before proceeding. Do not proceed with underspecified inputs.
//
// 2. Check for Phase 1 blockers. If any homonym requires a CBP run,
//    that CBP run must complete before conflict detection can proceed
//    for claims using that term. Document the blocker and halt if blocked.
//
// 3. Run Phase 1 vocabulary alignment exhaustively. Do not skip term
//    comparisons. False negatives in Phase 1 produce false negatives in
//    Phase 2. The cost of a missed vocabulary conflict is an undetected
//    structural conflict that appears compatible.
//
// 4. Run Phase 2 conflict detection over all pairs of runs. Document
//    every pair examined and every pair skipped. Unjustified skips
//    invalidate the phase. If the number of pairs is large, work
//    systematically: for each run, compare it against all subsequent runs.
//
// 5. Attempt resolution for all resolvable conflicts. Do not attempt
//    resolution for structural conflicts — document them and move on.
//    A failed resolution re-classifies the conflict as structural.
//    Do not retry failed resolutions.
//
// 6. Produce the reconciliation map. Every run pair must have a declared
//    relationship. "We didn't check" is not a relationship.
//
// 7. Identify jointly supported claims carefully. Independence matters.
//    Two runs that both inherited a claim from the same source are not
//    independent evidence for that claim. Note shared sources explicitly.
//
// 8. Declare the outcome. If any pairs are conflicted: "conflicted" or "mixed".
//    If all pairs are compatible or reconciled: "compatible" or "reconciled".
//    If comparison is not meaningful: "incommensurable".
//    If different pairs have different relationships: "mixed".
//
// RCP characterizes relationships. It does not fix conflicts.
// If RCP finds structural conflicts, the fix belongs upstream.
// Do not attempt to resolve structural conflicts within RCP —
// document them and authorize the appropriate upstream re-runs.
