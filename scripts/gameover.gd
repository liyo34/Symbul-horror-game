extends Control

const ALARM = preload("res://assets/sounds/alarmeffect.mp3")
const GAME_SCENE = "res://scenes/Game.tscn"
const MENU_SCENE = "res://scenes/Menu.tscn"

@onready var alarm_sound: AudioStreamPlayer = $AlarmSound


func _ready() -> void:
	alarm_sound.stream = ALARM
	alarm_sound.play()


func _on_try_again_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
