// Construct Decomposition Protocol (CDP)
// Version: 0.1.1
//
// Changes from 0.1.0:
//   - Reorganized to protocols/adversarial/
//
// CDP addresses the case where a construct exhibits incoherence that cannot
// be resolved by candidate selection or invariant revision within CFFP.
// Specifically: when the construct is secretly two (or more) distinct things
// that have been conflated, and no single formalism can satisfy all intended
// invariants simultaneously because those invariants belong to different things.
//
// CDP takes incoherence evidence as input and produces either:
//   split     — a validated partition of the construct into coherent parts,
//               each ready for an independent CFFP run
//   unified   — the construct is actually coherent; the apparent incoherence
//               has a different diagnosis (see outcome_notes)
//   open      — the incoherence is real but no valid split was found;
//               the boundary needs revision or the construct needs reframing
//
// The output of a successful CDP run is not a canonical form.
// It is a set of named, bounded sub-constructs and a recomposition proof,
// which together authorize independent CFFP runs on each part.
//
// CDP does not canonicalize. CFFP canonicalizes.
// CDP only establishes that independent canonicalization is warranted and safe.
//
// Relationship to CFFP:
//   CDP is typically triggered by a CFFP run that reached outcome "open"
//   with phase3b.diagnosis == "construct_incoherent". The CFFP instance
//   that triggered this run should be recorded in triggered_by.
//   CDP output authorizes new CFFP runs; it does not replace them.

package cdp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Construct Decomposition Protocol"
	version:     "0.1.1"
	description: "Incoherence-driven construct splitting. Parts must be more coherent than the whole."
}

// ─── CONSTRUCT UNDER DECOMPOSITION ───────────────────────────────────────────

#Construct: {
	name:        string
	description: string
	// The CFFP instance id that diagnosed this construct as incoherent, if any.
	// May be empty if decomposition was initiated directly.
	triggered_by?: string
}

// ─── PHASE 1: INCOHERENCE EVIDENCE ───────────────────────────────────────────
//
// Before proposing any split, the incoherence must be documented precisely.
// Vague claims of confusion are not admissible. The evidence must be one
// of the recognized incoherence forms below.
//
// An agent must populate at least one piece of evidence before proceeding.
// Multiple evidence items strengthen the case for decomposition and
// constrain which splits are admissible.
//
// If no evidence can be produced, the construct may not actually be incoherent.
// Close the run as "unified" and return to CFFP with revised candidates.

// A pair of invariants that cannot be simultaneously satisfied by any
// single formalism. The conflict must be demonstrated, not merely asserted.
#InvariantConflict: {
	invariant_a:   string // invariant id or description
	invariant_b:   string // invariant id or description
	demonstration: string // why no single formalism can satisfy both
}

// A partition of the construct's known cases into two sets such that
// no single evaluation rule covers both sets correctly.
// The sets must be exhaustive over the known cases and mutually exclusive.
#BehavioralPartition: {
	set_a: {
		description: string // what cases fall here
		behavior:    string // how the construct behaves in these cases
	}
	set_b: {
		description: string
		behavior:    string
	}
	incompatibility: string // why no single rule covers both behaviors
}

// A composition failure that only manifests in certain contexts,
// suggesting the construct behaves as different things in different roles.
#ContextualCompositionFailure: {
	context_a: {
		description:  string
		composes_with: string // what it successfully composes with here
	}
	context_b: {
		description:   string
		fails_with:    string // what it fails to compose with here
		failure_reason: string
	}
	implication: string // why this suggests two distinct constructs
}

#IncoherenceEvidence: {
	invariant_conflicts:           [...#InvariantConflict]
	behavioral_partitions:         [...#BehavioralPartition]
	contextual_composition_failures: [...#ContextualCompositionFailure]

	// At least one evidence item required across all three lists.
	// Enforced by protocol evaluator — CUE cannot express cross-list minimums directly.
	evidence_summary: string // evaluator's synthesis of why this construct is incoherent
}

#Phase1: {
	evidence: #IncoherenceEvidence
}

// ─── PHASE 2: SPLIT CANDIDATES ───────────────────────────────────────────────
//
// A split candidate proposes a partition of the construct into named parts.
// Each part must:
//   - have a name and description precise enough to seed a CFFP run
//   - have a declared boundary: the criterion that determines which cases
//     belong to this part and not others
//   - claim a set of invariants it satisfies (which may differ from the
//     invariants the original construct claimed)
//   - not claim invariants that contradict those of sibling parts
//
// A split candidate must also provide a recomposition argument:
// a demonstration that the union of all parts covers the original construct's
// intended scope, and that the parts do not overlap.
//
// Two-way splits are the default. Three-or-more-way splits are permitted
// but require proportionally stronger recomposition arguments.
//
// A split candidate that cannot produce a recomposition argument is inadmissible.

#Part: {
	name:        string
	description: string

	// The criterion that determines membership in this part.
	// Must be precise enough that a given case can be unambiguously assigned.
	boundary_criterion: string

	// Invariants this part claims to satisfy.
	// These become the Phase 1 invariants of the subsequent CFFP run for this part.
	claimed_invariants: [...{
		id:          string
		description: string
		class:       "termination" | "determinism" | "decidability" | "soundness" |
		             "completeness" | "composability" | "analyzability"
	}]
	claimed_invariants: [_, ...] // at least one required

	// Known limitations of this part — cases it explicitly does not cover.
	// These must not overlap with what sibling parts cover.
	explicit_exclusions: [...string]
}

#RecompositionArgument: {
	// Argument that the union of all parts covers the original construct's intended scope.
	coverage: string
	// Argument that no case belongs to more than one part.
	non_overlap: string
	// Argument that the incoherence evidence from Phase 1 is fully explained
	// by the proposed boundary — i.e., each evidence item maps cleanly to
	// a distinction between parts.
	evidence_mapping: string
}

// A split candidate also carries a naturalness argument.
// This is the pressure point that has no direct equivalent in CFFP:
// a split can be formally valid (coverage holds, non-overlap holds,
// invariants are consistent) but draw the boundary in the wrong place,
// producing parts that are technically correct but semantically useless.
// The naturalness argument must address this directly.
#NaturalnessArgument: {
	argument: string // why this boundary is the *right* boundary, not just a valid one
	// What alternative boundaries were considered and rejected, and why.
	alternatives_considered: [...{
		boundary:       string
		rejection_reason: string
	}]
}

#SplitCandidate: {
	id:    string
	parts: [...#Part]
	parts: [_, _, ...] // at least two parts required

	recomposition: #RecompositionArgument
	naturalness:   #NaturalnessArgument

	// Anticipated failure modes of this split — ways the boundary might
	// turn out to be wrong or the parts might fail their subsequent CFFP runs.
	anticipated_failures: [...{
		description: string
		severity:    "fatal" | "degraded" | "ergonomic"
		// fatal     — would invalidate the split entirely
		// degraded  — would require boundary revision
		// ergonomic — correct but inconvenient in practice
	}]
}

#Phase2: {
	candidates: [...#SplitCandidate]
	candidates: [_, ...] // at least one required
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────
//
// Pressure against split candidates takes three forms:
//
// BoundaryCounterexample — a case that cannot be unambiguously assigned to
//   exactly one part under the proposed boundary criterion. Either the case
//   belongs to both parts (overlap violation) or neither (coverage violation).
//   A valid rebuttal shows the case is in fact unambiguously assigned,
//   or performs a scope narrowing that records the case as an explicit exclusion.
//
// RecompositionChallenge — a demonstration that the recomposition argument fails:
//   either coverage does not hold (some intended case falls outside all parts)
//   or non-overlap does not hold (some case belongs to multiple parts).
//   Recomposition challenges cannot be rebutted with scope narrowing —
//   they must be refuted or the split candidate is eliminated.
//
// NaturalnessChallenge — an argument that the boundary is drawn in the wrong place:
//   a demonstration that an alternative boundary would produce parts that are
//   strictly more useful, more coherent, or more compositionally sound.
//   A valid rebuttal shows the proposed boundary is preferable on stated criteria.
//   Naturalness challenges can be rebutted with a boundary defense argument.
//
// Composition failures against already-canonicalized constructs apply here
// as in CFFP: they are not rebuttable and eliminate the split candidate.

#BoundaryRebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	limitation_description?: string // required if kind is "scope_narrowing"
}

#BoundaryCounterexample: {
	id:               string
	target_candidate: string
	target_part?:     string // which part's boundary is challenged, if specific
	witness:          string // the case that cannot be unambiguously assigned
	violation:        "overlap" | "coverage_gap"
	minimal:          bool & true
	rebuttal?:        #BoundaryRebuttal
}

#RecompositionChallenge: {
	id:               string
	target_candidate: string
	challenges:       "coverage" | "non_overlap"
	argument:         string // demonstration that the recomposition argument fails
	// No rebuttal with scope narrowing permitted here.
	rebuttal?: {
		argument: string // must be a refutation, not a retreat
		valid:    bool
	}
}

#NaturalnessChallenge: {
	id:               string
	target_candidate: string
	alternative_boundary: string // the boundary being proposed as superior
	argument:         string     // why this boundary is strictly preferable
	rebuttal?: {
		argument: string // defense of the original boundary
		valid:    bool
	}
}

#CompositionFailure: {
	target_candidate: string
	target_part:      string // which part fails composition
	conflicts_with:   string // already-canonicalized construct
	violates:         string // invariant id or description
	description:      string
	// Not rebuttable.
}

#Phase3: {
	boundary_counterexamples:  [...#BoundaryCounterexample]
	recomposition_challenges:  [...#RecompositionChallenge]
	naturalness_challenges:    [...#NaturalnessChallenge]
	composition_failures:      [...#CompositionFailure]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────
//
// A split candidate is eliminated if:
//   (a) any boundary counterexample targets it with no valid rebuttal, OR
//   (b) any recomposition challenge targets it with no valid refutation, OR
//   (c) any composition failure targets any of its parts, OR
//   (d) any naturalness challenge targets it with no valid rebuttal
//       AND a surviving alternative split candidate addresses the same
//       incoherence evidence with a boundary the challenge endorses.
//
// Note: a naturalness challenge alone does not eliminate a candidate
// if no alternative candidate embodies the challenged boundary.
// It becomes a recorded limitation instead.

#EliminationReason:
	"boundary_counterexample_unrebutted" |
	"recomposition_challenge_unrefuted"  |
	"composition_failure"                |
	"naturalness_dominated"

#EliminatedSplit: {
	candidate_id: string
	reason:       #EliminationReason
	source_id:    string
}

#SurvivorSplit: {
	candidate_id:     string
	scope_narrowings: [...string] // from scope-narrowing boundary rebuttals
	naturalness_limitations: [...string] // from unrebutted naturalness challenges with no dominating alternative
}

#Derived: {
	eliminated: [...#EliminatedSplit]
	survivors:  [...#SurvivorSplit]
}

// ─── PHASE 3b: REVISION (conditional) ────────────────────────────────────────
//
// Triggered when Phase 3 produces zero survivors.
// Diagnosis determines restart point.

#Phase3b: {
	triggered:  bool
	diagnosis:  "evidence_insufficient" | "candidates_too_weak" | "construct_not_decomposable"
	resolution: "revise_evidence" | "revise_candidates" | "close_as_unified"
	// "close_as_unified" — the incoherence evidence did not survive pressure;
	//   the construct may be coherent after all. Return to CFFP.
	notes:      string
	max_revisions: uint // terminate and set outcome "open" if exceeded
}

// ─── PHASE 4: SPLIT SELECTION ─────────────────────────────────────────────────
//
// If multiple split candidates survive, select one.
// Unlike CFFP's collapse test, splits cannot generally be merged —
// two valid splits draw different boundaries, and merging them
// would produce an incoherent boundary.
//
// Selection is based on:
//   - fewest scope narrowings (broader coverage)
//   - fewest naturalness limitations
//   - strongest recomposition argument
//   - best alignment with incoherence evidence from Phase 1
//
// If an autonomous agent is running this protocol, it must apply these
// criteria in order and record its reasoning. A human observer should
// be able to reconstruct why the selected split was preferred.

#SplitSelection: {
	selected:         string // candidate id
	selection_basis:  string // explicit reasoning against the criteria above
	alternatives_rejected: [...{
		candidate_id: string
		reason:       string
	}]
}

#Phase4: {
	multiple_survivors: bool
	if multiple_survivors {
		selection: #SplitSelection
	}
	final_candidate: string // id of the split proceeding to Phase 5
}

// ─── PHASE 5: CFFP READINESS OBLIGATIONS ─────────────────────────────────────
//
// Before authorizing CFFP runs on the parts, verify that each part
// is actually ready to be formalized independently.
//
// A part is CFFP-ready if:
//   - its boundary criterion is precise enough to seed Phase 1 invariants
//   - its claimed invariants are non-contradictory
//   - it has no unresolved composition obligations with already-canonicalized constructs
//   - the recomposition argument has survived all challenges
//
// If any part fails readiness, it must be refined before CFFP is authorized.
// Refinement does not restart the CDP run — it revises the part in place
// and re-evaluates readiness only.

#PartReadiness: {
	part_name:              string
	boundary_precise:       bool
	invariants_consistent:  bool
	composition_clear:      bool
	recomposition_survived: bool
	ready:                  bool // conjunction of above; evaluator sets this explicitly
	if !ready {
		blocking_issues: [...string]
	}
}

#Phase5: {
	readiness: [...#PartReadiness]
	all_ready: bool // must be true to proceed to Phase 6
}

// ─── PHASE 6: SPLIT AUTHORIZATION ────────────────────────────────────────────
//
// The authorized split is the output of CDP.
// It does not define canonical forms — it authorizes the CFFP runs that will.
//
// Each authorized part carries:
//   - its name and boundary criterion (for the CFFP construct definition)
//   - its claimed invariants (for the CFFP Phase 1 invariants)
//   - its acknowledged limitations (from scope narrowings and naturalness limitations)
//   - a note on what it depends on (for the CFFP depends_on field)
//
// The recomposition proof is preserved as a joint invariant that both
// subsequent CFFP runs must respect: neither canonical form, once produced,
// may be revised in a way that breaks coverage or introduces overlap.

#AuthorizedPart: {
	name:               string
	boundary_criterion: string
	seed_invariants: [...{
		id:          string
		description: string
		class:       "termination" | "determinism" | "decidability" | "soundness" |
		             "completeness" | "composability" | "analyzability"
	}]
	acknowledged_limitations: [...string]
	depends_on: [...string] // already-canonicalized constructs this part composes with
}

#RecompositionProof: {
	coverage_argument:   string
	non_overlap_argument: string
	// Joint invariant: both CFFP runs must preserve this.
	joint_invariant:     string
}

#Phase6: {
	authorized_parts:    [...#AuthorizedPart]
	authorized_parts:    [_, _, ...] // at least two
	recomposition_proof: #RecompositionProof
	// Instructions for the subsequent CFFP runs.
	cffp_instructions:   string
}

// ─── OUTCOME ──────────────────────────────────────────────────────────────────

#Outcome: "split" | "unified" | "open"
// split   — authorized parts produced; CFFP runs authorized
// unified — construct is coherent; return to CFFP with revised candidates
// open    — incoherence confirmed but no valid split found; boundary needs work

// ─── FULL PROTOCOL INSTANCE ───────────────────────────────────────────────────

#CDPInstance: {
	protocol:  #Protocol
	construct: #Construct
	version:   string

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3

	derived: #Derived

	phase3b?: #Phase3b

	phase4?: #Phase4 // only if len(derived.survivors) > 1

	phase5: #Phase5
	phase6?: #Phase6 // only if phase5.all_ready == true

	outcome:       #Outcome
	outcome_notes: string
}
