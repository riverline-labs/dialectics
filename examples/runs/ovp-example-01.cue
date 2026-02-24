// Example OVP run: validating an observed performance regression.
// Outcome: validated — the regression is real; ready for HEP.
//
// Scenario: a team observed that their canonicalized evaluation_order
// formalism performs 40% slower in production than in benchmarks.
// Before running HEP to explain why, OVP validates the observation.

package ovp_example

_run: {
	protocol: {
		name:        "Observation Validation Protocol"
		version:     "0.1.0"
		description: "Empirical observation validation. Gates HEP — validates phenomena are real before hypothesis elimination."
	}
	version: "1.0"

	phase1: {
		phenomenon:         "Evaluation order canonicalization runs 40% slower in production (p99=120ms) than in benchmark conditions (p99=85ms)."
		measurement_method: "Distributed tracing with 10ms granularity; p99 latency sampled over 7-day production window. Benchmark: synthetic load at equivalent QPS on identical hardware."
		context:            "Observed after deploying the evaluation_order canonical form to production on 2026-02-20. Benchmark was run the same week on identical instance types."
		reproducible:       true
		claim_source:       "SRE on-call alert, confirmed by two independent engineers reviewing traces."
		prior_validations: []
	}

	phase2: {
		evaluations: [
			{
				criterion: "measurement_validity"
				verdict:   "passes"
				argument:  "Distributed tracing instruments actual request latency end-to-end. The instrument measures what it claims: wall-clock latency of the canonicalization path."
			},
			{
				criterion: "selection_bias"
				verdict:   "passes"
				argument:  "Production sample is a 7-day window of all traffic, not a curated subset. Benchmark used the same QPS as production, same hardware class. No systematic reason the benchmark sample would under-represent slow cases."
			},
			{
				criterion: "confounding_factors"
				verdict:   "indeterminate"
				argument:  "Deployment occurred on 2026-02-20. A network topology change was also deployed on 2026-02-19. It cannot be ruled out that inter-service latency accounts for some fraction of the regression. The confound is noted but does not invalidate the latency observation itself."
			},
			{
				criterion: "sample_adequacy"
				verdict:   "passes"
				argument:  "7 days of production traffic at >10k req/min gives >100M samples. p99 is stable across sub-windows. Sample size is adequate."
			},
			{
				criterion: "reporting_accuracy"
				verdict:   "passes"
				argument:  "Traces reviewed directly by two engineers. No transcription step — raw trace data was compared to benchmark output. No analysis pipeline that could introduce error."
			},
			{
				criterion: "reproducibility"
				verdict:   "passes"
				argument:  "Regression is stable across the 7-day window and confirmed in a post-hoc benchmark replay against the production binary. It reproduces on demand."
			},
		]
		skipped_criteria: []
		summary: "Five of six criteria pass cleanly. One criterion (confounding_factors) is indeterminate due to a concurrent network topology change. The observation itself — 40% latency increase — is robustly measured, reproduced, and reported accurately. The confound is a causal concern (relevant to HEP), not a validity concern (the regression is real)."
	}

	phase3: {
		challenges: [
			{
				id:                   "VC1"
				kind:                 "confounding_factors"
				argument:             "The network topology change deployed on 2026-02-19 may account for some or all of the observed 40ms latency increase. The benchmark isolates the canonicalization binary but may not replicate the production network path."
				severity:             "significant"
				resolution_condition: "Re-run benchmark with production network path simulated, or deploy the network change rollback in production and re-measure."
			},
		]
		aggregate_assessment: "VC1 is significant but does not render the observation invalid as described. The latency increase is real and measured accurately. Whether the canonicalization formalism or the network change causes it is a causal question — which is exactly what HEP is for. OVP's job is to confirm the phenomenon occurred as described, not to explain it."
	}

	phase4: {
		verdict:   "validated"
		rationale: "The observation passes five of six validity criteria. The one indeterminate criterion (confounding_factors) surfaces a causal ambiguity that OVP explicitly hands to HEP. The 40% latency regression is real, reproducible, and accurately measured. VC1 should be carried as a HEP caveat, not treated as an OVP failure."
		validated_observation: {
			phenomenon: "Evaluation order canonicalization runs 40% slower in production (p99=120ms) than in benchmark conditions (p99=85ms), observed after 2026-02-20 deployment."
			confidence: "high"
			caveats: [
				"A concurrent network topology change (2026-02-19) may account for some fraction of the regression. HEP should treat this as a competing candidate explanation.",
			]
		}
	}

	outcome:       "validated"
	outcome_notes: "Observation validated with one caveat. The 40% latency regression is real and ready for HEP intake. HEP should include 'network topology change' as a candidate explanation alongside canonicalization-specific hypotheses."
}
