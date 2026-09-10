class_name BotTooltip
extends RefCounted

static func make(text: String) -> Control:
	if text.strip_edges().is_empty(): return null
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("14242c")
	style.border_color = Color("78cbb6")
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI", "Arial"])
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("eceddf"))
	label.custom_minimum_size.x = 290
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = text
	panel.add_child(label)
	return panel
