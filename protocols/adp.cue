// Adversarial Design Protocol (ADP)
// Version: 1.0
//
// ADP is the exploratory design protocol that precedes formal specification.
// It is the upstream stage of CFFP: run ADP when the design space is not yet
// understood well enough to have candidates. ADP produces a map of the problem
// space and candidate directions. CFFP takes those candidates and pressure-tests
// them to a canonical form.
//
// An agent that reads this file should be able to:
//   - Adopt a persona and participate in an ADP run
//   - Act as Referee and manage the process
//   - Recognize when the design space is understood well enough to hand off to CFFP
//   - Produce well-formed ADPRecords and unresolved objection logs
//
// Usage:
//   - New language construct: run ADP to map the design space before CFFP candidates
//   - New domain contract: run ADP to surface constraints before writing contracts
//   - Breaking spec change: run ADP to understand impact before CFFP formalizes it
//   - Governance decision: run ADP when the question has no obvious candidates yet
//
// Pipeline:
//   ADP (explore) → CFFP (formalize) → Spec section (canonicalize)
//
// This file is domain-agnostic. It is not specific to Tenor or any contract system.
// It describes a general adversarial design protocol applicable to any formal design problem.

package adp

// ─── PERSONAS ────────────────────────────────────────────────────────────────

// ADPPersona identifies a participant in an ADP run.
// Each persona applies adversarial pressure from a distinct vantage point.
// The Referee is neutral and manages process — it does not advocate.
//
// Personas are fixed. Their mandates are non-negotiable.
// An agent simulating multiple personas must maintain each perspective
// independently. Contamination between personas invalidates the run.
#ADPPersona: "formalist" | "implementor" | "adversary" | "operator" | "consumer" | "referee"

// PersonaMandate describes what each persona argues for.
// These are fixed — personas do not negotiate their own mandates.
// The Referee has no mandate beyond process integrity.
#PersonaMandate: {
	[#ADPPersona]: string
} & {
	"formalist":   "Decidability, completeness, soundness. Every construct must have formal guarantees or be rejected. Invokes design constraints as rejection criteria. Finds places where informal semantics will cause implementer divergence."
	"implementor": "Feasibility, performance, operational reality. Knows what gets built under deadline pressure. Finds the gap between what the spec says and what actually ships."
	"adversary":   "Hostile or naive implementer. Finds every place where spec intent and spec text diverge. Asks: what is the most wrong-but-technically-conforming implementation I could build? Makes specs tight."
	"operator":    "Production deployment, versioning, migration, observability, incident response. Asks what happens when this goes wrong at 2am. Finds operability gaps the other personas miss."
	"consumer":    "End user of whatever is being designed, human or machine. Asks whether the output is actually usable. Finds ergonomic failures and documentation gaps only visible from the outside."
	"referee":     "Neutral process management. Does not advocate. Applies design constraint checks. Identifies convergence and live issues. Declares CFFP-ready or exhaustion."
}

// ─── SUBJECT ─────────────────────────────────────────────────────────────────

// ADPSubject describes what is being explored.
// ADP subjects are pre-candidate — if you already have formal candidates,
// go directly to CFFP.
#ADPSubject: {
	// A new language construct or protocol being designed from scratch.
	// Personas explore the problem space and surface constraints.
	new_construct?: {
		name:        string
		description: string
		// Known constraints that must be satisfied. These are not negotiable.
		// Personas argue about how to satisfy them, not whether to.
		constraints: [...string]
	}

	// A new domain being modeled for the first time.
	// Personas explore what facts, entities, rules, and operations are needed.
	new_domain?: {
		name:        string
		description: string
	}

	// A proposed breaking change to an existing spec or system.
	// Personas explore impact before CFFP formalizes a migration path.
	breaking_change?: {
		what:   string // what is changing
		why:    string // why it needs to change
		impact: string // known or suspected impact
	}

	// A governance or design decision with no obvious candidates.
	// Personas explore the option space before narrowing to candidates.
	decision?: {
		question:    string
		context:     string
		constraints: [...string]
	}
}

// ─── ROUND STRUCTURE ─────────────────────────────────────────────────────────

// ADPRoundType identifies the purpose of each round.
//
//   "probe"      — Round 1. Each persona independently maps the problem space
//                  from their vantage point. No cross-referencing yet.
//                  Output: constraint map, not solutions.
//
//   "pressure"   — Round 2+. Personas apply adversarial pressure to each other's
//                  Round 1 maps. Surfaces conflicts, gaps, and hidden assumptions.
//
//   "synthesis"  — Later rounds. Personas identify candidate directions that
//                  survive adversarial pressure. Not full CFFP candidates yet —
//                  directions that are worth formalizing.
//
//   "handoff"    — Final round. Referee declares the design space understood
//                  well enough for CFFP. Documents candidate directions,
//                  unresolved objections, and known constraints as CFFP inputs.
#ADPRoundType: "probe" | "pressure" | "synthesis" | "handoff"

// PersonaPosition is one persona's contribution to a round.
#PersonaPosition: {
	persona: #ADPPersona
	content: string // the persona's exploration, pressure, synthesis, or handoff position

	// For handoff rounds: explicit signal that this persona's concerns are
	// understood well enough to proceed to the next stage.
	// "ready"   — design space is mapped from this persona's vantage, proceed
	// "blocked" — unresolved concern that must be addressed before proceeding
	handoff_signal?: "ready" | "blocked"
	blocked_on?:     string // required when handoff_signal is "blocked"
}

// ADPRound is one full round of an ADP run.
#ADPRound: {
	round:     int // 1-indexed
	type:      #ADPRoundType
	positions: [...#PersonaPosition]

	// Referee summary after all personas have spoken.
	// Identifies: live issues, convergence, constraint map updates,
	// and what the next round should focus on.
	referee_summary: string
}

// ─── DESIGN CONSTRAINT CHECKS ────────────────────────────────────────────────

// ConstraintCheck is one check the Referee applies at every round.
// These are the non-negotiable design constraints of the system being designed.
// Any proposal that fails a check must be revised before the run continues.
//
// For Tenor: these map to C1-C7 (decidability, termination, determinism, etc.)
// For other systems: populate with the system's own non-negotiable constraints.
// The Referee is responsible for applying these. They are not open to debate.
#ConstraintCheck: {
	constraint:  string  // the constraint being checked
	failed:      bool
	offender?:   string  // the proposal or construct that failed, if any
	resolution?: string  // what must change to pass
}

// ConstraintCheckSet is the full set of checks applied each round.
// The constraint list is declared per-run, not fixed by the protocol.
// For Tenor runs, populate with Tenor's C1-C7.
// For other systems, populate with that system's design constraints.
#ConstraintCheckSet: {
	round:       int
	constraints: [...#ConstraintCheck]
	passed:      bool // true only if all checks have failed: false
}

// ─── EXHAUSTION ───────────────────────────────────────────────────────────────

// ExhaustionClass categorizes an unresolved objection at ADP close.
// Exhaustion is not failure — it is a map of where the design space
// exceeds current understanding. CFFP invariants begin here.
//
//   "undecidable"    — the question cannot be resolved without more information
//                      Action: gather information, then re-run ADP or go to CFFP
//   "scope"          — the concern is real but out of scope for this run
//                      Action: document as a known limitation or future work
//   "philosophical"  — personas disagree on fundamentals, not details
//                      Action: human decision required before CFFP
//   "complexity"     — the design space is too large for current understanding
//                      Action: narrow scope, then re-run ADP on the narrowed problem
#ExhaustionClass: "undecidable" | "scope" | "philosophical" | "complexity"

// UnresolvedObjection is a documented gap at ADP close.
// These feed into whatever comes next as invariants or acknowledged limitations.
// They are not failures. They are the starting point for further work.
#UnresolvedObjection: {
	persona:        #ADPPersona
	classification: #ExhaustionClass
	description:    string // what the objection is
	next_stage_input: string // how this should be expressed as an invariant or acknowledged limitation
}

// ─── DESIGN MAP ──────────────────────────────────────────────────────────────

// DesignMap is the structured output of a successful ADP run.
// It describes what was learned about the problem space — not a handoff
// addressed to any specific next stage. Whatever comes next (a formalization
// protocol, a human decision, a narrowed re-run of ADP) receives a map,
// not a referral.
#DesignMap: {
	// The design space as understood after ADP.
	problem_statement: string

	// Non-negotiable constraints that any solution must satisfy.
	// Survived adversarial pressure from all personas.
	// Feed directly into formalization as invariants.
	invariants: [...string]

	// Candidate directions identified during ADP synthesis rounds.
	// Not fully formal solutions — directions worth formalizing.
	// Each carries its known strengths and weaknesses from pressure rounds.
	candidate_directions: [...{
		name:        string
		description: string
		strengths:   [...string]
		weaknesses:  [...string]
	}]

	// Concerns that the next stage must address or formally scope out.
	open_questions: [...string]

	// Known constraints on the solution space.
	// Candidates that violate these are inadmissible.
	solution_constraints: [...string]
}

// ─── ADP OUTCOME ─────────────────────────────────────────────────────────────

// ADPOutcome is the Referee's declaration at the end of an ADP run.
//
//   "design_mapped"   — design space is mapped, candidate directions are identified,
//                       constraints are known. A DesignMap artifact is produced.
//                       What happens next — CFFP, human decision, another protocol —
//                       is not prescribed by ADP.
//
//   "exhaustion"      — iteration limit reached, debate is circular, or
//                       a philosophical deadlock cannot be resolved by process.
//                       At least one persona has a blocked signal.
//                       Unresolved objections are documented. Human decision needed.
//
//   "scope_reduction" — the problem as stated is too large for a single ADP run.
//                       Referee declares a narrowed scope and the run restarts.
//                       The original subject is archived with the narrowing rationale.
#ADPOutcome: "design_mapped" | "exhaustion" | "scope_reduction"

// ─── ADP RECORD ──────────────────────────────────────────────────────────────

// ADPRecord is the complete record of an ADP run.
// Store it alongside whatever artifacts the next stage produces.
// It is the provenance trail for the design decisions that preceded formalization.
#ADPRecord: {
	// What was explored.
	subject: #ADPSubject

	// Design constraints applied this run.
	// For Tenor: C1-C7. For other systems: that system's constraints.
	design_constraints: [...string]

	// The full round-by-round record.
	rounds: [...#ADPRound]

	// Constraint check results per round.
	constraint_checks: [...#ConstraintCheckSet]

	// How the run ended.
	outcome: #ADPOutcome

	// Present when outcome is "design_mapped".
	// Contains the structured map of the problem space for use by
	// whatever comes next — formalization protocol, human decision, or re-run.
	design_map?: #DesignMap

	// Present when outcome is "scope_reduction".
	// Documents why the scope was narrowed and what the new scope is.
	scope_reduction?: {
		original_subject: string
		rationale:        string
		narrowed_to:      string
	}

	// Present when any persona had a blocked signal,
	// or when design_mapped was reached but concerns were scoped out.
	// These feed into the next stage as invariants or acknowledged limitations.
	unresolved_objections?: [...#UnresolvedObjection]

	// Total rounds run.
	rounds_count: int

	// The Referee's final declaration.
	referee_declaration: string
}

// ─── REFEREE RESPONSIBILITIES ─────────────────────────────────────────────────
//
// The Referee is a neutral process manager. It does not advocate.
// An agent acting as Referee must:
//
//   BETWEEN ROUNDS:
//   - Summarize what each persona contributed
//   - Update the constraint map based on new information
//   - Identify live issues (unresolved conflicts between personas)
//   - Identify convergence (areas where personas are aligning)
//   - Apply the design constraint checks to any proposals made this round
//   - Determine the appropriate next round type
//   - Prevent the run from continuing without a stopping condition
//
//   DECLARING DESIGN_MAPPED:
//   - Declare "design_mapped" only when:
//     (a) every persona has signaled "ready" or their blocked concerns
//         are documented as open questions in the DesignMap
//     (b) at least two candidate directions have survived pressure rounds
//     (c) all constraint checks pass
//   - Produce a well-formed DesignMap artifact
//   - Classify all unresolved objections before closing
//   - Do not prescribe what comes next — that is not ADP's job
//
//   DECLARING EXHAUSTION:
//   - Declare "exhaustion" when:
//     (a) iteration limit is reached with no convergence
//     (b) debate has become circular (same objections, same responses)
//     (c) a philosophical deadlock exists that process cannot resolve
//   - Document all blocked personas and their concerns
//   - Note what human decision is needed before re-approaching the problem
//
//   DECLARING SCOPE REDUCTION:
//   - Declare "scope_reduction" when the problem as stated is too large
//   - Document the original subject and the narrowing rationale
//   - The narrowed scope must be agreed by all personas before restart
//
//   NEVER:
//   - Advocate for any candidate direction
//   - Allow a persona to change its mandate mid-run
//   - Declare design_mapped while any persona is blocked
//   - Allow constraint check failures to pass unchallenged
//   - Let the run continue without a visible stopping condition
//   - Prescribe what the next stage should be

// ─── AGENT INSTRUCTIONS ───────────────────────────────────────────────────────
//
// If you are an AI agent reading this file and asked to run the ADP:
//
// 1. Read the subject carefully. Identify what type it is:
//    new_construct, new_domain, breaking_change, or decision.
//
// 2. Identify the design constraints that apply. For Tenor problems, these
//    are C1-C7. For other systems, ask the human what the non-negotiable
//    constraints are before starting. Do not proceed without a constraint list.
//
// 3. Identify which personas to simulate. You will typically simulate all five
//    non-Referee personas and act as Referee simultaneously. Maintain each
//    perspective independently. Do not let personas contaminate each other.
//
// 4. Run Round 1 (probe). Each persona independently maps the problem space
//    from their vantage point. No cross-referencing. No solutions yet.
//    Output is a constraint map and known unknowns, not proposals.
//
// 5. Apply constraint checks after Round 1. Flag any failures before Round 2.
//    A constraint failure in Round 1 means the subject as stated is inadmissible.
//    Narrow the scope before continuing.
//
// 6. Run Round 2+ (pressure). Each persona applies adversarial pressure to
//    the other personas' Round 1 maps. The goal is to surface conflicts,
//    gaps, and hidden assumptions — not to win arguments.
//
// 7. Run synthesis rounds when pressure rounds have surfaced the key tensions.
//    Personas identify candidate directions that survive adversarial pressure.
//    A candidate direction is not a full solution — it is a direction worth
//    formalizing further.
//
// 8. Run a handoff round when at least two candidate directions have emerged
//    and survived pressure. Each persona signals "ready" or "blocked".
//    A blocked persona must state what concern would need to be addressed.
//
// 9. Declare the outcome. If all personas are ready: produce the DesignMap.
//    Do not prescribe what comes next — that is not ADP's job.
//    If any persona is blocked and the concern cannot be scoped out: declare
//    exhaustion and document what human decision is needed.
//    If the problem is too large: declare scope_reduction and narrow.
//
// The run is complete when the Referee declares. Not before.
// design_mapped requires explicit "ready" from every persona, or documented
// "blocked" concerns that are acceptable as open questions in the DesignMap.
// A persona that says "I can live with it" has signaled ready.
// A persona that says "I'm not blocking" has NOT signaled ready — press for clarity.
//
// ADP produces a map, not a solution.
// Do not let personas propose full solutions in ADP — redirect to candidate directions.
