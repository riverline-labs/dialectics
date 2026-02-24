// Concept Boundary Protocol (CBP)
// Version: 0.1.0
//
// CBP addresses the case where a term is being used inconsistently across
// contexts — meaning different things to different people, in different
// domains, or in different phases of the same argument. The protocol
// determines whether the term should be:
//
//   sharpened — one precise concept is identified that accounts for all
//               legitimate usages; variant usages are diagnosed as errors
//               or metaphors, not distinct concepts
//
//   split     — the term covers two or more genuinely distinct concepts
//               that have been conflated; each is named and bounded,
//               and the original term is either retired or assigned to one
//
//   retired   — the term is so contaminated by conflicting usage that no
//               sharpening or split can recover it; it should be replaced
//               entirely by new vocabulary
//
// CBP is related to CDP (Construct Decomposition Protocol) but starts
// from a different place. CDP starts with behavioral incoherence — a
// construct that works differently in different situations. CBP starts
// from linguistic/semantic incoherence — a term that means different
// things in different contexts. A successful CBP split may authorize
// CDP runs if the resulting concepts need formal decomposition, or
// CFFP runs if they need formalization.
//
// On naming:
// CBP must handle the naming of split concepts. This is the most
// subjective judgment in the protocol and cannot be fully formalized.
// The protocol handles naming by requiring candidates to propose names,
// requiring those names to survive a naming pressure phase, and recording
// the rationale for the selected names explicitly. The protocol evaluator
// must apply naming criteria (distinctness, non-prejudging, coverage) but
// the final selection is a judgment call that must be documented.
//
// Outcomes:
//   sharpened  — one precise definition adopted; variant usages diagnosed
//   split      — two or more named concepts authorized; vocabulary map produced
//   retired    — term retired; replacement vocabulary recommended
//   open       — no satisfactory resolution found; term remains contested

package cbp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Concept Boundary Protocol"
	version:     "0.1.0"
	description: "Usage-driven concept boundary determination. Output is a sharpened definition or a named split."
}

// ─── TERM UNDER INVESTIGATION ─────────────────────────────────────────────────

#TermUnderInvestigation: {
	term:        string // the exact term or phrase being investigated
	domain:      string // the field, codebase, discourse, or context where this matters
	// Why is this investigation being conducted now?
	// What problem does the inconsistent usage cause?
	motivation:  string
	// Are there already competing formal definitions in the literature or codebase?
	prior_definitions: [...{
		source:     string
		definition: string
		notes:      string
	}]
}

// ─── PHASE 1: USAGE INVENTORY ─────────────────────────────────────────────────
//
// Before proposing any definition, all known usages of the term must be
// collected and documented. A usage is a concrete instance of the term
// being used, with enough context to determine what the user meant by it.
//
// Usages are the evidence base for CBP. Everything that follows is
// constrained by the usage inventory. A definition that cannot account
// for the usages is inadmissible. A split that does not cover the usages
// is invalid.
//
// Usage collection uses three procedures:
//
// Procedure 1: Contextual Sampling
//   Collect representative usages from across the domain. Aim for
//   diversity of context, author, and apparent meaning.
//
// Procedure 2: Edge Case Elicitation
//   Actively seek usages that seem to strain or contradict each other.
//   The goal is to find the cases that would most stress any proposed definition.
//
// Procedure 3: Expert Probe
//   If available, ask domain experts: "What does this term mean?" and
//   "Is X a case of this term?" Compare answers for divergence.
//   If experts agree, note the consensus. If they diverge, record both.
//
// Each usage is classified by its apparent semantic intent.

#UsageIntent:
	"technical"     | // used as a precise technical term
	"colloquial"    | // used loosely or informally
	"metaphorical"  | // used by analogy or extension
	"contested"     | // speaker is aware of definitional dispute
	"ambiguous"       // intent cannot be determined from context

#Usage: {
	id:      string
	source:  string // where this usage was found (document, speaker, codebase, etc.)
	excerpt: string // the actual usage in context
	// What did the user apparently mean by this term here?
	apparent_meaning: string
	intent:           #UsageIntent
	// Is this usage consistent with other usages, or does it diverge?
	diverges_from: [...string] // usage ids this one is inconsistent with
	// Is this a core usage (clearly central to the term's identity)
	// or a peripheral usage (possibly metaphorical or derived)?
	centrality: "core" | "peripheral"
}

#Phase1: {
	procedure_log: [...{
		procedure: "contextual_sampling" | "edge_case_elicitation" | "expert_probe"
		applied:   bool
		if !applied {
			skip_justification: string
		}
		notes: string
	}]

	usages: [...#Usage]
	usages: [_, ...] // at least one required

	// Evaluator's synthesis: what is the pattern of divergence?
	// Are there clearly distinct semantic clusters, or is the divergence diffuse?
	divergence_summary: string

	// Preliminary diagnosis before candidates are proposed.
	preliminary_diagnosis: "likely_sharpening" | "likely_split" | "likely_retirement" | "unclear"
}

// ─── PHASE 2: CANDIDATE RESOLUTIONS ──────────────────────────────────────────
//
// Candidates are proposed resolutions to the boundary question.
// There are three kinds:
//
// SharpeningCandidate — proposes one precise definition that covers all
//   core usages. Must explain how peripheral and divergent usages are
//   diagnosed (error, metaphor, domain-specific extension, etc.).
//   Must not simply exclude inconvenient usages without diagnosis.
//
// SplitCandidate — proposes two or more named concepts.
//   Each concept gets a name, a definition, and a boundary criterion.
//   The candidate must show how all usages are covered by the split.
//   Naming is required: unnamed concepts are inadmissible.
//   The candidate must also propose a disposition for the original term:
//   retired, assigned to one concept, or retained as an umbrella term.
//
// RetirementCandidate — proposes that the term be retired entirely.
//   Must propose replacement vocabulary (at least one replacement term
//   with a definition). Must show the replacement vocabulary covers
//   all core usages. Retirement without replacement is inadmissible.
//
// All candidates must address all core usages. Peripheral usages should
// be addressed but a candidate may diagnose them as out of scope with justification.

#UsageCoverage: {
	usage_id:  string
	covered:   bool
	if covered {
		explanation: string // how this candidate covers this usage
	}
	if !covered {
		diagnosis: string // why this usage is excluded (error, metaphor, out of scope)
		diagnosis_kind: "error" | "metaphor" | "domain_extension" | "out_of_scope"
	}
}

// Naming criteria for split concepts:
//   Distinctness   — the names must not suggest the same thing
//   Non-prejudging — the names must not presuppose the outcome of future CFFP/CDP runs
//   Coverage       — the names must reflect what their concepts actually cover
//   Memorability   — the names should be usable in practice without confusion
// These criteria are applied in Phase 3 naming pressure.

#ConceptName: {
	proposed_name:   string
	naming_rationale: string // argument that this name satisfies naming criteria
	// What prior terms or concepts might this name be confused with?
	confusion_risks: [...string]
	// How are those confusion risks mitigated?
	confusion_mitigations: [...string]
}

#SharpeningCandidate: {
	id:         string
	kind:       "sharpening"
	definition: string // the proposed precise definition
	// Necessary and sufficient conditions, if expressible.
	necessary_conditions:  [...string]
	sufficient_conditions: [...string]
	// How does this definition handle the divergent usages?
	divergence_diagnosis: string
	coverage: [...#UsageCoverage]
	// What this definition explicitly excludes and why.
	explicit_exclusions: [...string]
}

#SplitConceptDefinition: {
	name:               #ConceptName
	definition:         string
	boundary_criterion: string // what makes something an instance of this concept and not others
	// Necessary and sufficient conditions, if expressible.
	necessary_conditions:  [...string]
	sufficient_conditions: [...string]
	// Which usages from Phase 1 map to this concept?
	mapped_usages: [...string] // usage ids
}

#SplitCandidate: {
	id:       string
	kind:     "split"
	concepts: [...#SplitConceptDefinition]
	concepts: [_, _, ...] // at least two concepts required

	// What happens to the original term?
	original_term_disposition:
		"retired"        | // original term no longer used
		"assigned"       | // original term assigned to one of the split concepts
		"umbrella"         // original term retained as umbrella for all concepts
	if original_term_disposition == "assigned" {
		assigned_to: string // concept name it is assigned to
		assignment_rationale: string
	}
	if original_term_disposition == "umbrella" {
		umbrella_rationale: string // why the original term works as an umbrella
	}

	coverage: [...#UsageCoverage]
}

#ReplacementTerm: {
	term:       string
	definition: string
	// Which usages from Phase 1 does this replacement term cover?
	mapped_usages: [...string]
}

#RetirementCandidate: {
	id:                   string
	kind:                 "retirement"
	retirement_rationale: string // why the term cannot be sharpened or split
	replacements:         [...#ReplacementTerm]
	replacements:         [_, ...] // at least one replacement required
	coverage:             [...#UsageCoverage]
}

#ResolutionCandidate: #SharpeningCandidate | #SplitCandidate | #RetirementCandidate

#Phase2: {
	candidates: [...#ResolutionCandidate]
	candidates: [_, ...] // at least one required
}

// ─── PHASE 3: PRESSURE ───────────────────────────────────────────────────────
//
// Pressure against resolution candidates takes four forms:
//
// CoverageGap — a usage from Phase 1 that the candidate does not cover
//   and has not diagnosed. A valid rebuttal shows the usage is covered
//   or provides a diagnosis. An invalid rebuttal eliminates the candidate.
//
// DefinitionCollision — two usages that the candidate assigns to the same
//   concept but which appear to mean different things. A valid rebuttal
//   shows they are the same concept under the candidate's definition.
//   A scope-narrowing rebuttal concedes they are different and narrows
//   the concept's claimed scope.
//
// NamingPressure (split candidates only) — a challenge to a proposed name
//   on any of the four naming criteria: distinctness, non-prejudging,
//   coverage, memorability. A valid rebuttal defends the name against
//   the specific criterion challenged. Names that fail naming pressure
//   must be revised; a split candidate whose names cannot be defended
//   is not eliminated but must revise its names before Phase 4.
//
// ConnotationPressure — a demonstration that the proposed definition or
//   name imports unwanted connotations from adjacent concepts, prior usage,
//   or common understanding, such that the definition would be systematically
//   misread. This has no equivalent in CFFP or CDP. A valid rebuttal shows
//   the connotation is not actually imported, or that it is unavoidable and
//   the documentation handles it.

#DefinitionRebuttal: {
	kind:     "refutation" | "scope_narrowing"
	argument: string
	valid:    bool
	limitation_description?: string // required if scope_narrowing
}

#CoverageGapChallenge: {
	id:               string
	target_candidate: string
	usage_id:         string // the uncovered usage
	argument:         string // why this usage is not covered or diagnosed
	rebuttal?:        #DefinitionRebuttal
}

#DefinitionCollisionChallenge: {
	id:               string
	target_candidate: string
	usage_id_a:       string
	usage_id_b:       string
	argument:         string // why these usages resist assignment to the same concept
	rebuttal?:        #DefinitionRebuttal
}

#NamingCriterion: "distinctness" | "non_prejudging" | "coverage" | "memorability"

#NamingPressureChallenge: {
	id:               string
	target_candidate: string
	target_concept:   string // the concept name being challenged
	criterion:        #NamingCriterion
	argument:         string // why the name fails this criterion
	rebuttal?: {
		argument: string
		valid:    bool
		// If invalid: the candidate must revise the name.
		// Name revision does not eliminate the candidate.
		revised_name?: #ConceptName // populated if rebuttal is invalid
	}
}

#ConnotationPressureChallenge: {
	id:               string
	target_candidate: string
	// Which term or concept does this definition/name import connotations from?
	connotation_source: string
	argument:           string // how the connotation is imported and why it is harmful
	rebuttal?: {
		argument: string
		valid:    bool
	}
}

#Phase3: {
	coverage_gaps:        [...#CoverageGapChallenge]
	definition_collisions: [...#DefinitionCollisionChallenge]
	naming_pressure:      [...#NamingPressureChallenge]
	connotation_pressure: [...#ConnotationPressureChallenge]
}

// ─── SURVIVOR DERIVATION ─────────────────────────────────────────────────────
//
// A candidate is eliminated if:
//   (a) any coverage gap challenge targets it with no valid rebuttal, OR
//   (b) any definition collision targets it with no valid rebuttal, OR
//   (c) any connotation pressure challenge targets it with no valid rebuttal
//
// Naming pressure alone does not eliminate. It triggers name revision.
// A candidate with revised names re-enters survivor derivation with
// the revised names. If revised names also fail naming pressure, the
// candidate is eliminated.
//
// Scope narrowings from definition collision rebuttals are recorded
// as acknowledged limitations.

#EliminationReason:
	"coverage_gap_unrebutted"        |
	"definition_collision_unrebutted" |
	"connotation_pressure_unrebutted" |
	"naming_revision_failed"

#EliminatedCandidate: {
	candidate_id: string
	reason:       #EliminationReason
	source_id:    string
}

#SurvivorCandidate: {
	candidate_id:     string
	kind:             "sharpening" | "split" | "retirement"
	scope_narrowings: [...string]
	// Name revisions applied during pressure phase.
	name_revisions: [...{
		concept:      string
		original:     string
		revised:      string
		revision_rationale: string
	}]
}

#Derived: {
	eliminated: [...#EliminatedCandidate]
	survivors:  [...#SurvivorCandidate]
}

// ─── PHASE 3b: REVISION (conditional) ────────────────────────────────────────

#Phase3b: {
	triggered:  bool
	diagnosis:  "usages_insufficient" | "candidates_too_weak" | "term_irredeemable"
	resolution: "collect_more_usages" | "revise_candidates" | "close_as_retired"
	notes:      string
}

// ─── PHASE 4: CANDIDATE SELECTION ────────────────────────────────────────────
//
// If multiple candidates survive, select one.
// Selection criteria, applied in order:
//   1. Prefer sharpening over split over retirement (simpler resolutions preferred)
//   2. Among same-kind candidates: prefer fewest scope narrowings
//   3. Among same-kind candidates: prefer strongest coverage of core usages
//   4. Among split candidates: prefer names with fewest naming revisions
//
// This ordering may be overridden with explicit justification.

#CandidateSelection: {
	selected:        string // candidate id
	selection_basis: string // explicit reasoning against the criteria above
	alternatives_rejected: [...{
		candidate_id: string
		reason:       string
	}]
}

#Phase4: {
	multiple_survivors: bool
	if multiple_survivors {
		selection: #CandidateSelection
	}
	final_candidate: string
}

// ─── PHASE 5: RESOLUTION OBLIGATIONS ─────────────────────────────────────────
//
// Before adopting a resolution, verify:
//   - all core usages are covered or diagnosed
//   - all proposed names (in split candidates) satisfy naming criteria
//   - no unresolved connotation risks remain
//   - the resolution does not create new ambiguities worse than the original
//   - if split or retirement: the vocabulary map is complete and actionable

#ResolutionObligation: {
	property:  string
	argument:  string
	satisfied: bool
	if !satisfied {
		blocker: string
	}
}

#Phase5: {
	obligations:   [...#ResolutionObligation]
	all_satisfied: bool
}

// ─── PHASE 6: ADOPTED RESOLUTION ─────────────────────────────────────────────
//
// The adopted resolution is the output of CBP.
//
// For sharpening: a precise definition with usage coverage and
//   diagnosis of variant usages.
//
// For split: a named vocabulary map — each concept with its name,
//   definition, boundary criterion, and the usages that map to it.
//   Plus the disposition of the original term.
//   If formalization is needed, CDP or CFFP runs are authorized here.
//
// For retirement: replacement vocabulary with coverage map.
//
// The adopted resolution also carries:
//   - acknowledged limitations (from scope narrowings)
//   - open questions (usages that remain contested)
//   - authorization notes for downstream protocol runs

#SharpenedDefinition: {
	term:                  string
	definition:            string
	necessary_conditions:  [...string]
	sufficient_conditions: [...string]
	usage_coverage:        [...#UsageCoverage]
	acknowledged_limitations: [...string]
	// Usages diagnosed as errors, metaphors, or extensions.
	variant_diagnoses: [...{
		usage_id:  string
		diagnosis: "error" | "metaphor" | "domain_extension" | "out_of_scope"
		notes:     string
	}]
}

#VocabularyMap: {
	concepts: [...{
		name:               string
		definition:         string
		boundary_criterion: string
		mapped_usages:      [...string]
		acknowledged_limitations: [...string]
		// Does this concept warrant a CFFP or CDP run?
		downstream_protocol?: "cffp" | "cdp" | "none"
		downstream_notes?:    string
	}]
	original_term_disposition:
		"retired" | "assigned" | "umbrella"
	original_term_notes: string
}

#ReplacementVocabulary: {
	retired_term:  string
	retirement_rationale: string
	replacements:  [...#ReplacementTerm]
	usage_coverage: [...#UsageCoverage]
}

#AdoptedResolution: {
	kind: "sharpening" | "split" | "retirement"

	if kind == "sharpening" {
		sharpened: #SharpenedDefinition
	}
	if kind == "split" {
		vocabulary_map: #VocabularyMap
	}
	if kind == "retirement" {
		replacement_vocabulary: #ReplacementVocabulary
	}

	// Open questions: usages or distinctions that remain contested
	// even after the resolution is adopted.
	open_questions: [...string]

	// Plain-language summary for human observers.
	summary: string
}

#Phase6: {
	adopted_resolution: #AdoptedResolution
}

// ─── OUTCOME ──────────────────────────────────────────────────────────────────

#Outcome: "sharpened" | "split" | "retired" | "open"

// ─── FULL PROTOCOL INSTANCE ───────────────────────────────────────────────────

#CBPInstance: {
	protocol: #Protocol
	term:     #TermUnderInvestigation
	version:  string

	phase1: #Phase1
	phase2: #Phase2
	phase3: #Phase3

	derived: #Derived

	phase3b?: #Phase3b

	phase4?: #Phase4 // only if len(derived.survivors) > 1

	phase5: #Phase5
	phase6?: #Phase6 // only if phase5.all_satisfied == true

	outcome:       #Outcome
	outcome_notes: string
}
