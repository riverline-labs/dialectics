// Governance: Protocol Run Recording
// Version: 0.1.0
//
// Recording standardizes the output of any protocol run into a uniform,
// queryable record. This was previously ARP (Adjudication Record Protocol).
// Promoted to governance because recording is type projection, not adjudication.
//
// A #Record can be produced from any completed protocol run.
// Records are the input to RCP (Reconciliation Protocol).
// They form the decision log of the dialectic system.
//
// An agent reading this file should be able to:
//   - Accept the output of any completed protocol run
//   - Project it into a #Record with all required fields
//   - Identify what was resolved vs. what remains open
//   - Tag the record for downstream queryability

package recording

// ─── SOURCE PROTOCOL ────────────────────────────────────────────────────────

#SourceProtocol:
	"AAP" | "ADP" | "ATP" | "CBP" | "CDP" | "CFFP" | "CGP" |
	"EMP" | "HEP" | "IFA" | "OVP" | "PTP" | "RCP"

#SourceRun: {
	protocol:    #SourceProtocol
	run_id:      string
	run_version: string
	subject:     string
	started:     string // ISO 8601
	completed:   string // ISO 8601
}

// ─── DISPUTE CHARACTERIZATION ────────────────────────────────────────────────

#DisputeKind:
	"term_ambiguity"        |
	"candidate_selection"   |
	"assumption_audit"      |
	"design_mapping"        |
	"construct_repair"      |
	"implementation_check"  |
	"governance_case"       | // was revision_proposal + deprecation_case; now CGP
	"cross_run_conflict"    |
	"analogy_transfer"      | // ATP
	"composition_emergence" | // EMP
	"observation_validity"  | // OVP
	"prioritization"          // PTP

#DisputeCharacterization: {
	kind:        #DisputeKind
	description: string
	prior_runs:  [...string] // run_ids of prior relevant runs
}

// ─── RESOLUTION SUMMARY ──────────────────────────────────────────────────────

#ResolutionStatus: "decided" | "open" | "rejected"

#ResolutionSummary: {
	status:           #ResolutionStatus
	decision?:        string
	open_questions?:  [...string]
	eliminated_count: int | *0
	survivors:        [...string]
}

// ─── ACKNOWLEDGED LIMITATIONS ────────────────────────────────────────────────

#AcknowledgedLimitation: {
	description: string
	source:      string // which phase or challenge produced this limitation
}

// ─── DEPENDENCIES ────────────────────────────────────────────────────────────

#Dependencies: {
	consumed: [...string] // run_ids this run depended on
	produced: [...string] // artifacts this run produced
}

// ─── NEXT ACTIONS ────────────────────────────────────────────────────────────

#NextAction: {
	action:    string
	protocol?: #SourceProtocol
	rationale: string
}

// ─── RECORD ──────────────────────────────────────────────────────────────────
//
// The canonical projection of any completed protocol run.
// All fields are required. Absent fields indicate an incomplete projection.

#Record: {
	record_id: string

	source_run:               #SourceRun
	dispute:                  #DisputeCharacterization
	resolution:               #ResolutionSummary
	acknowledged_limitations: [...#AcknowledgedLimitation]
	dependencies:             #Dependencies
	tags:                     [...string]
	next_actions:             [...#NextAction]
	notes:                    string | *""
}
