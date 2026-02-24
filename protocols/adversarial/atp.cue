// Analogy Transfer Protocol (ATP)
// Version: 0.1.0
//
// ATP addresses the case where a construct in domain A is claimed to be
// structurally similar to something in domain B, and someone wants to import
// the formalization. The protocol validates whether the structural
// correspondence is real and whether the transfer is safe.
//
// The protocol produces one of three outcomes:
//   validated — correspondence survived all pressure; formalization transferred
//               with acknowledged divergences
//   rejected  — correspondence eliminated by unrebutted challenges; transfer
//               not viable as specified
//   open      — multiple surviving correspondences; further discrimination needed
//
// The key insight: disanalogy counterexamples can be scope-narrowed just like
// invariant counterexamples in CFFP. A transfer candidate survives pressure by
// retreating to a narrower correspondence — but the retreat is recorded as an
// acknowledged divergence, not a victory.
//
// An agent reading this file should be able to:
//   - Declare a claimed structural correspondence between two domains
//   - Generate concrete correspondence candidates (proposed mappings)
//   - Identify and evaluate disanalogy counterexamples, domain mismatches,
//     and scope challenges
//   - Derive survivors with accumulated acknowledged divergences
//   - Verify that transferred invariants hold in the target domain
//   - Produce a validated transfer record or rejection

package atp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Analogy Transfer Protocol"
	version:     "0.1.0"
	description: "Cross-domain structural transfer validation. Survivors carry acknowledged divergences."
}

// ─── TRANSFER DECLARATION ────────────────────────────────────────────────────

#SourceConstruct: {
	name:             string
	domain:           string
	formal_statement: string  // the formalization in the source domain
	invariants:       [...string] // what the source formalization guarantees
}

#TargetDomain: {
	name:                string
	description:         string
	canonical_constructs: [...string] // already-canonicalized constructs in this domain
}

#Phase1: {
	source_construct:       #SourceConstruct
	target_domain:          #TargetDomain
	claimed_correspondence: string // the structural similarity being claimed
	motivation:             string // why this transfer would be useful
}

// ─── PHASE 2: CORRESPONDENCE CANDIDATES ──────────────────────────────────────
//
// Each candidate proposes a mapping from source structure to target structure.
// For each element of the source formalization, the candidate identifies
// its analog in the target domain. Candidates must be precise.

#StructuralMapping: {
	source_element:     string
	target_element:     string
	alignment_argument: string
	mapping_kind:       "direct" | "adjusted" | "partial"
	if mapping_kind == "adjusted" || mapping_kind == "partial" {
		adjustment_description: string
	}
}

#CorrespondenceCandidate: {
	id:          string
	description: string
	mappings:    [...#StructuralMapping]
	mappings:    [_, ...] // at least one mapping required

	// Does this candidate claim all source invariants transfer?
	invariants_transfer: bool
	if !invariants_transfer {
		non_transferring_invariants: [...string]
		non_transfer_argument:       string
	}

	// Domain-specific properties this candidate claims to gain.
	domain_specific_gains: [...string]
}

#Phase2: {
	candidates: [...#CorrespondenceCandidate]
	candidates: [_, ...]
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────
//
// Three challenge types — same rebuttal mechanics as CFFP:
//
// DisanalogyCE — a case where the structural correspondence breaks.
//   Rebuttal: refutation (analogy holds) or scope_narrowing (acknowledged divergence).
//
// DomainMismatch — the domains differ in a foundational way that invalidates
//   the transfer even if the structural mapping holds locally.
//   Rebuttal: refutation only (scope_narrowing on a fundamental mismatch
//   would hollow out the transfer entirely).
//
// ScopeChallenge — the transfer only holds for a subset of the target domain.
//   Rebuttal: scope_narrowing (candidate survives by accepting the restriction).

#TransferRebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	limitation_description?: string // required if scope_narrowing
}

#DisanalogyCE: {
	id:               string
	target_candidate: string
	target_mapping?:  string // which mapping is challenged, if specific
	witness:          string // the case where the analogy breaks
	minimal:          bool & true
	rebuttal?:        #TransferRebuttal
}

#DomainMismatch: {
	id:               string
	target_candidate: string
	missing_property: string // the property the target domain lacks
	argument:         string // why this property is required for the transfer
	// Domain mismatch rebuttals must be refutations only.
	rebuttal?: {
		argument: string
		valid:    bool
	}
}

#ScopeChallenge: {
	id:               string
	target_candidate: string
	restricted_scope: string // the subset where the transfer holds
	argument:         string // why the transfer fails outside this scope
	rebuttal?:        #TransferRebuttal
}

#Phase3: {
	disanalogy_counterexamples: [...#DisanalogyCE]
	domain_mismatches:          [...#DomainMismatch]
	scope_challenges:           [...#ScopeChallenge]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────
//
// A candidate is eliminated if:
//   (a) any disanalogy CE targets it with no valid rebuttal, OR
//   (b) any domain mismatch targets it with no valid rebuttal, OR
//   (c) any scope challenge targets it with no valid rebuttal
//
// Scope narrowings from scope_narrowing rebuttals become acknowledged divergences
// in Phase 6.

#EliminationReason:
	"disanalogy_ce_unrebutted"   |
	"domain_mismatch_unrebutted" |
	"scope_challenge_unrebutted"

#EliminatedTransfer: {
	candidate_id: string
	reason:       #EliminationReason
	source_id:    string
}

#SurvivorTransfer: {
	candidate_id:     string
	scope_narrowings: [...string] // from scope_narrowing rebuttals; become acknowledged divergences
}

#Derived: {
	eliminated: [...#EliminatedTransfer]
	survivors:  [...#SurvivorTransfer]
}

// ─── PHASE 3b: REVISION (conditional) ────────────────────────────────────────

#Phase3b: {
	triggered:  bool
	diagnosis:  "correspondence_too_strong" | "candidates_too_weak" | "transfer_not_viable"
	resolution: "revise_correspondence" | "revise_candidates" | "close_as_rejected"
	notes:      string
}

// ─── PHASE 4: SELECTION (conditional) ────────────────────────────────────────
//
// If multiple candidates survive, select one.
// Prefer fewest scope narrowings, then strongest domain_specific_gains.

#Phase4: {
	multiple_survivors: bool
	if multiple_survivors {
		selected:        string // candidate id
		selection_basis: string
		alternatives_rejected: [...{
			candidate_id: string
			reason:       string
		}]
	}
	final_candidate: string
}

// ─── PHASE 5: TRANSFER OBLIGATIONS ───────────────────────────────────────────
//
// Before adopting the correspondence, verify that the imported formalization
// preserves its invariants when instantiated in the target domain.
// These are proof obligations, not tests.

#TransferObligation: {
	property:  string // which invariant or property must be preserved
	argument:  string // why it holds in the target domain
	satisfied: bool
	if !satisfied {
		blocker: string
	}
}

#Phase5: {
	obligations:   [...#TransferObligation]
	all_satisfied: bool
}

// ─── PHASE 6: VALIDATED TRANSFER OR REJECTION ────────────────────────────────

#ValidatedTransfer: {
	source_construct:            string
	target_domain:               string
	adopted_correspondence:      string // description of the validated mapping
	transferred_formalization:   string // the formalization as instantiated in target domain
	acknowledged_divergences:    [...string] // from scope narrowings; places where transfer is limited
	preserved_invariants:        [...string]
	non_transferred_invariants:  [...string]
}

#RejectionRecord: {
	reason:              string
	strongest_challenge: string // the challenge that prevented transfer
	what_would_help:     string // what revision might enable future transfer
}

#Phase6: {
	validated_transfer?: #ValidatedTransfer
	rejection_record?:   #RejectionRecord
}

// ─── OUTCOME ─────────────────────────────────────────────────────────────────

#Outcome: "validated" | "rejected" | "open"
// validated — correspondence survived; formalization transferred with acknowledged divergences
// rejected  — correspondence eliminated by unrebutted challenges
// open      — multiple correspondences survived; further discrimination needed

// ─── FULL PROTOCOL INSTANCE ──────────────────────────────────────────────────

#ATPInstance: {
	protocol: #Protocol
	version:  string

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3

	derived: #Derived

	phase3b?: #Phase3b

	phase4?: #Phase4 // only if len(derived.survivors) > 1

	phase5:  #Phase5
	phase6?: #Phase6 // only if phase5.all_satisfied == true

	outcome:       #Outcome
	outcome_notes: string
}
