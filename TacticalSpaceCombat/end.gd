extends CenterContainer

const MAIN_SCENE: String = "res://TacticalSpaceCombat/tactical_space_combat.tscn"

@onready var message_label: Label = %MessageLabel
@onready var button_retry: Button = %ButtonRetry
@onready var button_quit: Button = %ButtonQuit


func _ready() -> void:
	button_retry.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_SCENE))
	button_quit.pressed.connect(func(): get_tree().quit())
	message_label.text = "You %s!" % ("Won" if Globals.winner_is_player else "Lost")
