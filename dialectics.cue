// dialectics.cue — The Dialectic Kernel
// Version: 0.1.0
//
// This file defines the formal theory of structured disagreement resolution.
// It contains zero domain-specific knowledge. It knows nothing about
// "formalism", "invariant", "hypothesis", or "canonical form".
// Those are protocol-layer concerns.
//
// What this file knows:
//   - The Rebuttal        — the atomic dialectic primitive
//   - The Challenge       — adversarial pressure with a rebuttal slot
//   - The Derivation      — mechanical survivor determination
//   - The Obligation Gate — proof requirements before adoption
//   - The Revision Loop   — zero-survivor feedback
//   - The Finding         — structured epistemic output
//   - Archetype contracts — what any adversarial/evaluative/exploratory protocol must satisfy
//   - Suite constraints   — what the protocol collection must satisfy as a whole
//
// Protocols are instantiations of the archetypes defined here.
// This file does NOT import from any protocol.
//
// An agent reading this file should be able to:
//   - Understand the shared logic across all adversarial protocols
//   - Verify that a new protocol satisfies its archetype contract
//   - Understand what "scope narrowing" means formally and why it matters
//   - Understand the obligation gate as the anti-shortcut mechanism
//   - Understand the revision loop as the self-correction mechanism

package dialectics

// ─── THE REBUTTAL ────────────────────────────────────────────────────────────
//
// The atomic dialectic primitive. Every adversarial protocol uses this.
//
// Two kinds:
//
//   "refutation"      — the pressure is incorrect given the candidate's formalism.
//                       The candidate's claim stands. The challenge is dismissed.
//                       Leaves no trace in the survivor record.
//
//   "scope_narrowing" — the pressure is correct. The candidate retreats from
//                       the case the challenge targets. The candidate survives,
//                       but the retreat is recorded as an acknowledged limitation.
//                       This is semantically distinct from refutation: the candidate
//                       did not defeat the pressure, it withdrew from it.
//
// A scope_narrowing rebuttal is always valid by definition — the candidate is
// conceding the point, not disputing it. valid: true must still be set explicitly
// to make the concession unambiguous.
//
// The distinction matters downstream: refutations leave no trace;
// scope_narrowings accumulate and become acknowledged limitations in the
// protocol's final output.

#Rebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	// Required when kind is "scope_narrowing": what scope was excluded.
	// This text becomes an entry in the survivor's scope_narrowings list.
	limitation_description?: string
}

// HEP extends #Rebuttal with "evidence_unreliability" for evidence-driven pressure.
// ATP and EMP use #Rebuttal directly.
// These extensions are declared at the protocol layer, not here.

// ─── THE CHALLENGE ───────────────────────────────────────────────────────────
//
// Targeted adversarial pressure against a candidate, with a rebuttal slot.
// Every adversarial protocol's Phase 3 is a collection of challenges.
// The challenge TYPES differ by protocol; the structure is the same.
//
// "minimal" is required for counterexample-type challenges where the challenge
// is a concrete case demonstrating a violation. It must be explicitly asserted
// true — a non-minimal counterexample is inadmissible.
//
// Challenges without a rebuttal slot (e.g., composition failures in CFFP)
// are protocol-specific extensions that omit the rebuttal field because
// they are structurally irrebuttable.

#Challenge: {
	id:               string
	target_candidate: string
	argument:         string
	minimal:          bool | *false // must be true for counterexample-type challenges
	rebuttal?:        #Rebuttal
}

// ─── THE DERIVATION ──────────────────────────────────────────────────────────
//
// Mechanical survivor determination. Populated after Phase 3.
// Must be populated before Phase 4 can proceed.
//
// A candidate is eliminated if ANY challenge targeting it has no valid rebuttal.
// Survivors are all candidates not eliminated by any challenge.
// A run with zero survivors proceeds to the revision loop, not to Phase 4.
//
// Elimination and survival are recorded explicitly — not inferred from comments.

#EliminationRecord: {
	candidate_id: string
	reason:       string // protocol-specific elimination reason
	source_id:    string // id of the challenge that caused elimination
}

#SurvivorRecord: {
	candidate_id:     string
	scope_narrowings: [...string] // from scope_narrowing rebuttals; become acknowledged limitations
}

#Derivation: {
	eliminated: [...#EliminationRecord]
	survivors:  [...#SurvivorRecord]
}

// ─── THE OBLIGATION GATE ─────────────────────────────────────────────────────
//
// Proof obligations that must be satisfied before a survivor is adopted.
// This is the anti-hallucination mechanism: a run cannot close as long as
// any obligation has satisfied: false.
//
// Obligations are argued, not tested. Each must have a prose argument
// that a reviewer can evaluate for soundness.

#Obligation: {
	property:  string
	argument:  string
	satisfied: bool
	if !satisfied {
		blocker: string
	}
}

#ObligationGate: {
	obligations:   [...#Obligation]
	all_satisfied: bool
}

// ─── THE REVISION LOOP ───────────────────────────────────────────────────────
//
// Zero-survivor feedback. Triggered when Phase 3 eliminates all candidates.
// Zero survivors is not failure — it means the problem is harder than assumed.
// The revision loop diagnoses WHY nothing survived and determines where to restart.
//
// Each protocol has its own diagnosis and resolution vocabulary.
// The abstract structure is the same across all adversarial protocols.

#RevisionLoop: {
	triggered:  bool
	diagnosis:  string // protocol-specific diagnosis enum
	resolution: string // protocol-specific resolution enum
	notes:      string
}

// ─── THE FINDING ─────────────────────────────────────────────────────────────
//
// Structured epistemic output. All protocol runs produce findings.
// Findings characterize what was learned, not what was built.

#FindingKind:
	"contradiction" | // two claims cannot both be true
	"gap"           | // something expected is missing
	"ambiguity"     | // a claim could mean multiple things
	"decision"      | // a choice was made with explicit rationale
	"dependency"    | // a relation between protocol outputs
	"risk"          | // a potential failure mode
	"limitation"      // a known scope boundary

#Finding: {
	kind:      #FindingKind
	content:   string
	severity?: "fatal" | "significant" | "minor"
	source?:   string
}

// ─── ARCHETYPE CONTRACTS ─────────────────────────────────────────────────────
//
// Every protocol belongs to exactly one archetype.
// The archetype contract specifies the MINIMUM structural elements required.
// Protocols may add domain-specific phases beyond the minimum.
//
// These are documentation contracts enforced by convention and suite review,
// not by CUE's type system across packages.

// Adversarial protocols: CFFP, CDP, CBP, HEP, ATP, EMP
#Adversarial: {
	has_candidates:      bool & true
	has_pressure:        bool & true
	has_derivation:      bool & true
	has_revision_loop:   bool & true
	has_selection:       bool & true
	has_obligation_gate: bool & true
	has_adoption:        bool & true
}

// Evaluative protocols: AAP, IFA, RCP, CGP, OVP, PTP
#Evaluative: {
	has_subject:    bool & true
	has_criteria:   bool & true
	has_assessment: bool & true
	has_verdict:    bool & true
}

// Exploratory protocols: ADP
#Exploratory: {
	has_subject:  bool & true
	has_rounds:   bool & true
	has_referee:  bool & true
	has_map:      bool & true
}

// ─── KNOWN PROTOCOLS ─────────────────────────────────────────────────────────

#KnownProtocol:
	"AAP" | "ADP" | "ATP" | "CBP" | "CDP" | "CFFP" | "CGP" |
	"EMP" | "HEP" | "IFA" | "OVP" | "PTP" | "RCP"

// ─── SUITE CONSTRAINTS ───────────────────────────────────────────────────────
//
// Invariants the protocol collection must maintain:
//
//   routing_complete     — governance/routing.cue covers every #KnownProtocol
//   recording_complete   — governance/recording.cue can project any run into a #Record
//   reachability_complete — every protocol has at least one known trigger

#SuiteConstraints: {
	routing_complete:      bool & true
	recording_complete:    bool & true
	reachability_complete: bool & true
}

// ─── RUN VALIDATION ──────────────────────────────────────────────────────────
//
// The minimum structure any protocol execution must satisfy.
// Every completed run must be projectable into a governance/recording.cue #Record.

#Run: {
	protocol_name:  #KnownProtocol
	run_id:         string
	version:        string
	started:        string  // ISO 8601
	completed?:     string  // ISO 8601 — absent if run is not yet complete
	outcome:        string  // protocol-specific outcome value
	outcome_notes:  string
	// Assertion that this run can be projected into a #Record.
	recordable:     bool & true
}
