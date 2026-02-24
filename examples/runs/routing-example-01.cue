// Example routing result: a team presents a problem with co-occurring features.
// Outcome: routed — OVP first, then HEP sequenced after.
//
// Scenario: a team has observed unexpected behavior in production and wants
// to understand why. They have both an empirical claim ("this is happening")
// and a causal question ("why is it happening"). Routing determines the
// correct protocol sequence.

package routing_example

_result: {
	input: {
		problem_statement:   "We're seeing evaluation_order canonicalization run 40% slower in production than in benchmarks. We have traces and want to understand why."
		structural_features: ["observation_validity", "causal_ambiguity"]
		context:             "The regression appeared after the 2026-02-20 deployment. A concurrent network change also deployed on 2026-02-19. The team wants to know: is the regression real, and if so, what causes it?"
	}

	primary:   "OVP"
	secondary: ["HEP"]
	sequenced: true
	sequence: [
		{
			order:    1
			protocol: "OVP"
			purpose:  "Validate that the 40% latency regression is a real phenomenon and not a measurement artifact, before committing resources to causal explanation."
			feeds:    "OVP's #ValidatedObservation becomes HEP's phenomenon input. OVP caveats (e.g., confounding factors) become HEP candidate seeds."
		},
		{
			order:    2
			protocol: "HEP"
			purpose:  "Explain the validated regression. Generate and eliminate hypotheses (canonicalization regression, network change, load shape shift, instrumentation overhead). Adopt a surviving explanation."
			feeds:    "HEP output feeds into CGP if a formalism revision is required, or into IFA if the implementation diverges from the canonical form."
		},
	]
	rationale:     "Two structural features co-occur: observation_validity and causal_ambiguity. The disambiguation rule applies: when both are present, run OVP first to gate HEP. Running HEP on an unvalidated observation wastes hypothesis-generation effort and risks explaining an artifact. OVP costs one short protocol run; HEP costs a full adversarial cycle. Sequence is correct."
	warnings: [
		"If OVP returns 'artifact', do not proceed to HEP. The phenomenon as described did not occur. Re-examine measurement methodology.",
		"If OVP returns 'contested', evaluate whether to proceed to HEP with caveats or to resolve the validation gaps first.",
	]
	outcome:       "routed"
	outcome_notes: "OVP → HEP sequence determined. OVP gates HEP. If further causal investigation leads to a formalism change, route to CGP after HEP completes."
}
