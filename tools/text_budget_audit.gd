extends SceneTree
## A3 text-budget audit (GAMEPLAY_IMPROVEMENT_PLAN.md).
##
## Read-only over the default release content: lists every event body over
## BODY_THRESHOLD words and every outcome text over OUTCOME_THRESHOLD words,
## longest first with event ids, and writes docs/baselines/text_budget.md.
## The thresholds are report filters, not validation bands; the enforced
## contract stays the per-scene-role band in ContentRepository.

const ContentRepositoryScript = preload("res://scripts/domain/content_repository.gd")

const BODY_THRESHOLD := 70
const OUTCOME_THRESHOLD := 40
const REPORT_PATH := "res://docs/baselines/text_budget.md"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var repository: ContentRepository = ContentRepositoryScript.new()
	if not repository.load_errors.is_empty():
		push_error("Content errors: %s" % "; ".join(repository.load_errors))
		quit(2)
		return
	var passages := collect_passages(repository.events)
	var rows := over_budget(passages)
	var report := format_report(repository.events.size(), passages.size(), rows)
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not write %s" % REPORT_PATH)
		quit(2)
		return
	file.store_string(report)
	file.close()
	var bodies := 0
	var outcomes := 0
	for row: Dictionary in rows:
		if str(row["kind"]) == "body":
			bodies += 1
		else:
			outcomes += 1
	print("Text budget: %d events, %d bodies over %d words, %d outcomes over %d words -> %s" % [repository.events.size(), bodies, BODY_THRESHOLD, outcomes, OUTCOME_THRESHOLD, REPORT_PATH])
	quit()


## Every readable passage of every event: the introduction, its conditional
## variants, and each outcome text with the variants that stand in for it.
static func collect_passages(events: Dictionary) -> Array:
	var passages: Array = []
	for event_id: String in events:
		var event: Dictionary = events[event_id]
		passages.append({
			"event_id": event_id,
			"kind": "body",
			"ref": "body",
			"words": ContentRepositoryScript.word_count(str(event.get("body", ""))),
		})
		var body_variant_index := 0
		for variant: Variant in event.get("body_variants", []):
			if typeof(variant) == TYPE_DICTIONARY:
				passages.append({
					"event_id": event_id,
					"kind": "body",
					"ref": "body variant %d" % body_variant_index,
					"words": ContentRepositoryScript.word_count(str(variant.get("text", ""))),
				})
			body_variant_index += 1
		var choice_index := 0
		for choice: Variant in event.get("choices", []):
			if typeof(choice) != TYPE_DICTIONARY:
				choice_index += 1
				continue
			for outcome_key: String in ContentRepositoryScript.OUTCOME_KEYS:
				if typeof(choice.get(outcome_key, null)) != TYPE_DICTIONARY:
					continue
				passages.append({
					"event_id": event_id,
					"kind": "outcome",
					"ref": "choice %d %s" % [choice_index, outcome_key],
					"words": ContentRepositoryScript.word_count(str(choice[outcome_key].get("text", ""))),
				})
				var outcome_variant_index := 0
				for outcome_variant: Variant in choice[outcome_key].get("variants", []):
					if typeof(outcome_variant) == TYPE_DICTIONARY:
						passages.append({
							"event_id": event_id,
							"kind": "outcome",
							"ref": "choice %d %s variant %d" % [choice_index, outcome_key, outcome_variant_index],
							"words": ContentRepositoryScript.word_count(str(outcome_variant.get("text", ""))),
						})
					outcome_variant_index += 1
			choice_index += 1
	return passages


## The report filter: bodies strictly over the body threshold, outcomes
## strictly over the outcome threshold, longest first for the trim queue.
static func over_budget(passages: Array) -> Array:
	var rows: Array = []
	for passage: Dictionary in passages:
		var limit := BODY_THRESHOLD if str(passage.get("kind", "")) == "body" else OUTCOME_THRESHOLD
		if int(passage.get("words", 0)) > limit:
			rows.append(passage)
	rows.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		if int(left.get("words", 0)) != int(right.get("words", 0)):
			return int(left.get("words", 0)) > int(right.get("words", 0))
		if str(left.get("event_id", "")) != str(right.get("event_id", "")):
			return str(left.get("event_id", "")) < str(right.get("event_id", ""))
		return str(left.get("ref", "")) < str(right.get("ref", ""))
	)
	return rows


static func format_report(event_count: int, passage_count: int, rows: Array) -> String:
	var bodies: Array = []
	var outcomes: Array = []
	for row: Dictionary in rows:
		if str(row.get("kind", "")) == "body":
			bodies.append(row)
		else:
			outcomes.append(row)
	var lines: Array[String] = []
	lines.append("# Text budget")
	lines.append("")
	lines.append("Source: `tools/text_budget_audit.gd` over the default release content (%d events, %d passages). Thresholds: body over %d words, outcome text over %d words. These are report filters for the trim queue; the enforced contract is the per-scene-role band in `ContentRepository.SCENE_ROLE_BANDS`." % [event_count, passage_count, BODY_THRESHOLD, OUTCOME_THRESHOLD])
	lines.append("")
	lines.append("## Bodies over %d words (%d)" % [BODY_THRESHOLD, bodies.size()])
	lines.append("")
	lines.append("| event | ref | words |")
	lines.append("|---|---|---|")
	for row: Dictionary in bodies:
		lines.append("| %s | %s | %d |" % [str(row.get("event_id", "")), str(row.get("ref", "")), int(row.get("words", 0))])
	lines.append("")
	lines.append("## Outcome texts over %d words (%d)" % [OUTCOME_THRESHOLD, outcomes.size()])
	lines.append("")
	lines.append("| event | ref | words |")
	lines.append("|---|---|---|")
	for row: Dictionary in outcomes:
		lines.append("| %s | %s | %d |" % [str(row.get("event_id", "")), str(row.get("ref", "")), int(row.get("words", 0))])
	lines.append("")
	return "\n".join(lines)
