// Adjudication Record Protocol (ARP)
// Version: 0.1.0
//
// ARP is a standardization wrapper. It does not adjudicate — it records.
// Every IAP run, regardless of protocol, produces an ARP record. The record
// is a uniform, queryable summary of what happened: what was disputed,
// what protocol was used, what was decided, and what was left open.
//
// ARP records are the input to RCP (Reconciliation). Without ARP, RCP has
// no canonical basis for comparing runs. With ARP, a log of decisions
// becomes analyzable: which constructs have been touched, how many times,
// with what outcomes, and with what unresolved tensions.
//
// ARP is not filled out by the agent running the underlying protocol.
// It is filled out after the run completes, as a post-run summary.
// An agent can fill it out automatically from the protocol instance output.
//
// An agent reading this file should be able to:
//   - Accept the output of any completed IAP run
//   - Extract the standardized record fields
//   - Identify what was resolved vs. what remains open
//   - Tag the record for downstream queryability
//   - Register the record in the decision log

package arp

// ─── PROTOCOL METADATA ───────────────────────────────────────────────────────

#Protocol: {
	name:        "Adjudication Record Protocol"
	version:     "0.1.0"
	description: "Standardizes the output of any IAP run into a uniform, queryable record."
}

// ─── SOURCE RUN ──────────────────────────────────────────────────────────────
//
// Identifies the IAP run this record summarizes.

#SourceProtocol:
	"AAP" | "ADP" | "CBP" | "CDP" | "CFFP" |
	"HEP" | "RCP" | "IFA" | "RPP" | "DJP" | "PSP"

#SourceRun: {
	protocol:    #SourceProtocol
	run_id:      string // unique identifier for this run instance
	run_version: string // protocol version used
	subject:     string // the construct, term, argument, or phenomenon under adjudication
	started:     string // ISO 8601
	completed:   string // ISO 8601
}

// ─── DISPUTE CHARACTERIZATION ─────────────────────────────────────────────────
//
// What was the nature of the dispute entering this run?
// This is a normalized summary — not the raw problem statement.

#DisputeKind:
	"term_ambiguity"      | // what does X mean?
	"candidate_selection" | // which formalism/explanation is correct?
	"assumption_audit"    | // what is this argument assuming?
	"design_mapping"      | // what are the possible designs?
	"construct_repair"    | // this construct is broken — how do we fix it?
	"implementation_check"| // does this implementation match the canonical form?
	"revision_proposal"   | // should this canonical form be changed?
	"deprecation_case"    | // should this canonical form be retired?
	"cross_run_conflict"  | // prior runs disagree — which is authoritative?
	"routing"               // which protocol should we run?

#DisputeCharacterization: {
	kind:        #DisputeKind
	description: string // precise description of what was in dispute
	prior_runs:  [...string] // run_ids of prior runs relevant to this dispute, if any
}

// ─── RESOLUTION SUMMARY ──────────────────────────────────────────────────────
//
// What happened? Three possible outcomes across all IAP protocols reduce to
// a common resolution shape: something was decided, something was left open,
// or the frame was rejected.

#ResolutionStatus:
	"decided"  | // a canonical outcome was reached
	"open"     | // the dispute is harder than assumed; no outcome
	"rejected"   // the frame of the dispute was wrong; needs reframing

#ResolutionSummary: {
	status: #ResolutionStatus

	// What was decided, if status is "decided"?
	// This is a plain-language summary — not the full canonical form.
	decision?: string

	// What was left unresolved, if status is "open" or "rejected"?
	open_questions?: [...string]

	// What was the elimination count? (candidates, hypotheses, assumptions ruled out)
	// Used to assess how much work the run did even if no canonical form emerged.
	eliminated_count: int | *0

	// What survived?
	survivors: [...string] // ids or names of surviving candidates/explanations/forms
}

// ─── ACKNOWLEDGED LIMITATIONS ────────────────────────────────────────────────
//
// What did this run explicitly exclude from its scope?
// These are not failures — they are recorded concessions.
// Scope narrowings from CFFP rebuttals, acknowledged gaps from HEP,
// excluded contexts from CBP — all land here.

#AcknowledgedLimitation: {
	description: string
	source:      string // which phase or mechanism produced this limitation
}

// ─── DEPENDENCIES ────────────────────────────────────────────────────────────
//
// What prior canonical forms did this run depend on?
// What new canonical forms did this run produce?
// This enables dependency graph construction across the decision log.

#Dependencies: {
	consumed: [...string] // construct names or run_ids this run treated as canonical input
	produced: [...string] // construct names or canonical forms this run produced
}

// ─── TAGS ────────────────────────────────────────────────────────────────────
//
// Free-form tags for queryability. Not constrained — the agent assigns them
// based on the domain, the subject matter, and any relevant cross-cutting concerns.

#Tags: [...string]

// ─── NEXT ACTIONS ────────────────────────────────────────────────────────────
//
// What should happen next, if anything?
// This is the agent's recommendation based on the run outcome.
// It is advisory — not a protocol trigger.

#NextAction: {
	action:    string // what to do
	protocol?: #SourceProtocol // which IAP to run, if applicable
	rationale: string
}

// ─── FULL RECORD ─────────────────────────────────────────────────────────────

#ARPRecord: {
	protocol: #Protocol
	record_id: string // unique identifier for this ARP record

	source_run:              #SourceRun
	dispute:                 #DisputeCharacterization
	resolution:              #ResolutionSummary
	acknowledged_limitations: [...#AcknowledgedLimitation]
	dependencies:            #Dependencies
	tags:                    #Tags
	next_actions:            [...#NextAction]

	// Free-form notes from the agent summarizing anything not captured above.
	notes: string | *""
}
