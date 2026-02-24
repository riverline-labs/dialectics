// Example CGP run: adjudicating a revision to the evaluation_order canonical form.
// Outcome: admissible_revision — revision preserves all invariants; non-breaking.
//
// Scenario: someone proposes changing evaluation_order from strict left-to-right
// to priority-based ordering. The revision claims non-breaking.

package cgp_example

_run: {
	protocol: {
		name:        "Canonical Governance Protocol"
		version:     "0.1.0"
		description: "Adjudicates fitness-for-purpose of canonical forms. Handles revision through deprecation."
	}
	version: "1.0"

	phase1: {
		canonical: {
			construct:                "evaluation_order"
			source_run_id:            "cffp-example-01"
			formal_statement:         "Left-to-right strict evaluation in declaration order: eval(rules) = fold_left(rules, apply)"
			evaluation_def:           "Process rules sequentially by declaration index."
			satisfies:                ["I1", "I2"]
			acknowledged_limitations: ["Does not cover rule sets mutated during evaluation."]
			canonicalized_at:         "2026-02-01T00:00:00Z"
		}
		case: {
			kind: "revision"
			revision: {
				id:          "R1"
				proposed_by: "engine-team"
				description: "Add an optional priority field to each rule; when present, higher-priority rules evaluate first."
				changes: {
					formal_statement: "Priority-then-declaration-order evaluation: eval(rules) = fold_left(sort_by_priority(rules), apply)"
					add_invariants:   ["I3: Priority values are total-ordered; ties are broken by declaration order."]
				}
				motivation:          "High-priority override rules need to fire before lower-priority rules regardless of declaration position."
				claims_non_breaking: true
			}
		}
	}

	phase2: {
		preservation_checks: [
			{
				invariant_id: "I1"
				verdict:      "preserved"
				rationale:    "Sorting by priority is O(n log n) on finite sets; still terminates. Strict evaluation of each rule is unchanged."
			},
			{
				invariant_id: "I2"
				verdict:      "preserved"
				rationale:    "For a fixed rule set with fixed priority values, sort_by_priority is deterministic. Same inputs → same sorted order → same evaluation sequence."
			},
		]
		invariant_health:          "sound"
		invariant_health_argument: "Both existing invariants are preserved. The new invariant I3 is a strengthening, not a contradiction."
	}

	phase3: {
		successor_proposed: false
		alternative_exists: false
		assessment_notes:   "Revision adds a new invariant I3 with no successor proposed. No alternative assessment required."
	}

	phase4: {
		known_dependents: [
			{
				id:          "rule-engine-impl-v2"
				kind:        "implementation"
				description: "Existing rule engine implementation that assumes declaration-order evaluation."
			},
		]
		impact_assessments: [
			{
				dependent_id: "rule-engine-impl-v2"
				breaking:     false
				burden:       "moderate"
				rationale:    "The implementation must be updated to support the priority field, but existing rules without a priority field continue to evaluate in declaration order — backwards compatible."
			},
		]
		total_burden:         "moderate"
		blocked_dependents:   []
		incomplete_landscape: false
	}

	phase5: {
		verdict:   "admissible_revision"
		rationale: "Both existing invariants are preserved. The new invariant I3 is well-formed. The single known dependent is not broken — existing rules without priority are unaffected. Revision is admissible."
		revised_canonical: {
			formal_statement:         "Priority-then-declaration-order evaluation: eval(rules) = fold_left(sort_by_priority(rules), apply)"
			evaluation_def:           "Sort rules by priority (descending), breaking ties by declaration index. Evaluate in that order."
			satisfies:                ["I1", "I2", "I3"]
			acknowledged_limitations: ["Does not cover rule sets mutated during evaluation.", "Priority field is optional; absent priority is treated as lowest."]
		}
	}

	outcome:       "admissible_revision"
	outcome_notes: "Revision R1 preserves all existing invariants and adds I3. Non-breaking. Admissible."
}
