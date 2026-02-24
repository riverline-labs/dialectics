// Example ATP run: transferring "monotone queue" formalization from algorithms
// to stream processing systems.
// Outcome: validated — correspondence survived with one acknowledged divergence.
//
// Scenario: a team wants to apply the monotone queue data structure's
// formal properties to a sliding-window stream processor.

package atp_example

_run: {
	protocol: {
		name:        "Analogy Transfer Protocol"
		version:     "0.1.0"
		description: "Cross-domain structural transfer validation. Survivors carry acknowledged divergences."
	}
	version: "1.0"

	phase1: {
		source_construct: {
			name:             "monotone_queue"
			domain:           "algorithm design"
			formal_statement: "A deque maintaining monotone order: elements are added to back, stale front elements removed, min/max retrievable in O(1)."
			invariants: [
				"MQ-I1: The deque is always monotonically ordered (non-decreasing or non-increasing).",
				"MQ-I2: The front element is always the current window minimum (or maximum).",
				"MQ-I3: Each element is added and removed at most once — amortized O(1) per operation.",
			]
		}
		target_domain: {
			name:                "stream processing"
			description:        "A domain where data arrives in time-ordered events; windows are defined by time ranges."
			canonical_constructs: ["stream_event", "time_window"]
		}
		claimed_correspondence: "The monotone queue's deque maps to the stream buffer; window elements map to stream events in a time range; the min/max property maps to a running aggregate over the window."
		motivation:             "We want O(1) window aggregate maintenance for stream events without re-scanning the full window on each tick."
	}

	phase2: {
		candidates: [
			{
				id:          "C1"
				description: "Direct structural mapping: deque → ring buffer, element → stream event, add/remove → event arrival/expiry."
				mappings: [
					{
						source_element:     "deque element"
						target_element:     "stream event"
						alignment_argument: "Both are ordered units of data that enter from one end and expire from the other."
						mapping_kind:       "direct"
					},
					{
						source_element:     "window boundary (index-based)"
						target_element:     "time window (timestamp-based)"
						alignment_argument: "Both define which elements are 'current'. The index slides; the timestamp advances."
						mapping_kind:       "adjusted"
						adjustment_description: "Source uses integer indices; target uses timestamps. The ordering property is preserved; the comparison operator differs."
					},
					{
						source_element:     "min/max retrieval in O(1)"
						target_element:     "running aggregate over active window"
						alignment_argument: "Both retrieve a summary statistic of the current active set in O(1) without re-scanning."
						mapping_kind:       "direct"
					},
				]
				invariants_transfer: true
				domain_specific_gains: [
					"Extends to non-count aggregates (sum, min, max) over time windows.",
					"Handles out-of-order event arrival with bounded correction.",
				]
			},
		]
	}

	phase3: {
		disanalogy_counterexamples: [
			{
				id:               "CE1"
				target_candidate: "C1"
				target_mapping:   "window boundary mapping"
				witness:          "An event arrives 500ms late but is still within the declared window. Index-based deques have no equivalent — an element at index k is either in the window or it is not."
				minimal:          true
				rebuttal: {
					kind:                    "scope_narrowing"
					argument:                "Out-of-order arrival is a stream-specific concern. The core monotone queue transfer holds for in-order event streams."
					valid:                   true
					limitation_description:  "This transfer applies to in-order event streams only. Out-of-order arrival requires a separate formalization."
				}
			},
		]
		domain_mismatches:  []
		scope_challenges:   []
	}

	derived: {
		eliminated: []
		survivors: [
			{
				candidate_id:     "C1"
				scope_narrowings: ["Applies to in-order event streams only. Out-of-order arrival is excluded from this transfer."]
			},
		]
	}

	phase5: {
		obligations: [
			{
				property:  "MQ-I1 (monotone order) is preserved in the stream buffer."
				argument:  "In-order event streams arrive with non-decreasing timestamps. The ring buffer maintains events in arrival order, which is timestamp order. Monotonicity is structurally guaranteed for in-order streams."
				satisfied: true
			},
			{
				property:  "MQ-I2 (front = window min/max) holds over time-window-bounded events."
				argument:  "Expired events (timestamp < window_start) are removed from the front. The front event is the oldest active event, and by the monotone invariant, it is the current minimum. This holds for the declared window semantics."
				satisfied: true
			},
			{
				property:  "MQ-I3 (amortized O(1)) is preserved."
				argument:  "Each event is enqueued once on arrival and dequeued once on expiry. The amortized analysis is identical to the algorithm domain."
				satisfied: true
			},
		]
		all_satisfied: true
	}

	phase6: {
		validated_transfer: {
			source_construct:          "monotone_queue"
			target_domain:             "stream processing"
			adopted_correspondence:    "Monotone ring buffer for in-order time-windowed stream aggregation."
			transferred_formalization: "Maintain a ring buffer of active events sorted by timestamp. On event arrival: remove back entries that violate monotone order, then enqueue. On window tick: dequeue expired front entries. The front entry is the current window aggregate in O(1)."
			acknowledged_divergences:  ["Applies to in-order event streams only. Out-of-order arrival is excluded from this transfer."]
			preserved_invariants:      ["MQ-I1", "MQ-I2", "MQ-I3"]
			non_transferred_invariants: []
		}
	}

	outcome:       "validated"
	outcome_notes: "C1 survived all pressure. One scope narrowing (in-order streams only) acknowledged. Transfer validated."
}
