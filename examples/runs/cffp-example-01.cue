// Example CFFP run: formalizing "evaluation_order" for a hypothetical rule system.
// Outcome: canonical — single candidate survived with no pressure; adopted directly.
//
// This example demonstrates:
//   - A minimal two-invariant Phase 1
//   - A single candidate with proof sketches
//   - Empty pressure (no counterexamples challenged this candidate)
//   - A derived record with one survivor
//   - A passing obligation gate
//   - A canonical form

package cffp_example

// We reference types by their field names only — no import needed for
// a concrete example in a separate package. All fields are plain values.

_run: {
	protocol: {
		name:        "Constraint-First Formalization Protocol"
		version:     "0.2.1"
		description: "Invariant-driven semantic design. Candidates survive pressure or die."
	}
	construct: {
		name:        "evaluation_order"
		description: "The order in which expressions in a rule evaluation engine are evaluated."
		depends_on:  []
	}
	version: "1.0"

	phase1: {
		invariants: [
			{
				id:          "I1"
				description: "Evaluation always terminates for finite rule sets."
				testable:    true
				structural:  true
				class:       "termination"
			},
			{
				id:          "I2"
				description: "Identical inputs always produce identical evaluation orders."
				testable:    true
				structural:  true
				class:       "determinism"
			},
		]
	}

	phase2: {
		candidates: [
			{
				id:          "C1"
				description: "Left-to-right strict evaluation in declaration order."
				formalism: {
					structure:       "Rules are ordered by declaration index; evaluation proceeds strictly in that order."
					evaluation_rule: "eval(rules) = fold_left(rules, apply)"
					resolution_rule: "No ambiguity — declaration order is total."
				}
				claims: [
					{
						invariant_id: "I1"
						argument:     "Strict evaluation terminates if the rule set is finite and each rule terminates individually."
					},
					{
						invariant_id: "I2"
						argument:     "Declaration order is fixed; any two evaluations of the same rule set follow the same sequence."
					},
				]
				complexity: {
					time:   "O(n) in the number of rules"
					space:  "O(1) auxiliary"
					static: "O(n) to verify order properties"
				}
				failure_modes: [
					{
						description: "Does not handle dynamically added rules during evaluation."
						trigger:     "Rule set is mutated mid-evaluation."
						severity:    "fatal"
					},
				]
			},
		]
	}

	phase3: {
		counterexamples:      []
		composition_failures: []
	}

	derived: {
		eliminated: []
		survivors: [
			{
				candidate_id:     "C1"
				scope_narrowings: []
			},
		]
	}

	phase5: {
		obligations: [
			{
				property:  "Termination holds for all finite rule sets."
				argument:  "Left-to-right strict evaluation processes each rule exactly once. Finite rule set → finite steps → terminates."
				provable:  true
			},
			{
				property:  "Determinism holds for any fixed rule set."
				argument:  "Declaration order is an injective function over rule indices. Same input → same index sequence → same evaluation order."
				provable:  true
			},
		]
		all_provable: true
	}

	phase6: {
		canonical: {
			construct:        "evaluation_order"
			formal_statement: "Left-to-right strict evaluation in declaration order: eval(rules) = fold_left(rules, apply)"
			evaluation_def:   "Process rules sequentially by declaration index. Each rule is fully evaluated before the next begins."
			satisfies:        ["I1", "I2"]
			acknowledged_limitations: [
				"Does not cover rule sets mutated during evaluation. That case requires a separate formalization.",
			]
		}
	}

	outcome:       "canonical"
	outcome_notes: "Single candidate C1 survived Phase 3 without any counterexamples. Obligation gate passed. Canonical form adopted directly."
}
