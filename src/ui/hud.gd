class_name GameHud
extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var lives_label: Label = %LivesLabel
@onready var time_label: Label = %TimeLabel
@onready var message_panel: PanelContainer = %MessagePanel
@onready var message_label: Label = %MessageLabel
@onready var detail_label: Label = %DetailLabel


func set_stats(score: int, target: int, lives: int, seconds_left: int) -> void:
	score_label.text = "STARS  %d / %d" % [score, target]
	lives_label.text = "SHIELDS  %d" % lives
	time_label.text = "TIME  %02d" % seconds_left


func show_running() -> void:
	message_panel.visible = false


func show_result(title: String, detail: String) -> void:
	message_label.text = title
	detail_label.text = detail
	message_panel.visible = true
