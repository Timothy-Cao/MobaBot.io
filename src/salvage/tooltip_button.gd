extends Button

func _make_custom_tooltip(for_text: String) -> Object:
	if for_text.strip_edges().is_empty(): return null
	return BotTooltip.make(for_text)
