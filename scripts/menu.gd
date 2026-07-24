extends Control

const BELL = preload("res://assets/sounds/bell.mp3")
const THEME = preload("res://assets/sounds/theme.mp3")
const GAME_SCENE = "res://scenes/Game.tscn"
const TRANSITION_WAIT = 5.0
const BELL_FADE_DURATION = 3.0
const THEME_FADE_DURATION = 1.0

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var credits_panel: PanelContainer = $CreditsPanel
@onready var full_version_panel: PanelContainer = $FullVersionPanel
@onready var play_button: Button = $LeftPanel/LeftVBox/ContentColumn/PlayButton
@onready var credits_button: Button = $LeftPanel/LeftVBox/ContentColumn/CreditsButton
@onready var bell_sound: AudioStreamPlayer = $BellSound
@onready var theme_sound: AudioStreamPlayer = $ThemeSound
@onready var logo: TextureRect = $LeftPanel/LeftVBox/ContentColumn/LogoWrap/Logo
@onready var logo_glow: TextureRect = $LeftPanel/LeftVBox/ContentColumn/LogoWrap/LogoGlow
@onready var demo_label: Label = $LeftPanel/LeftVBox/ContentColumn/DemoLabel


func _ready() -> void:
	fade_overlay.color = Color(0, 0, 0, 0)
	credits_panel.visible = false
	full_version_panel.visible = false
	_start_horror_effects()
	_play_menu_music()


func _start_horror_effects() -> void:
	var logo_pulse := create_tween().set_loops()
	logo_pulse.tween_property(logo, "modulate", Color(1.05, 0.92, 0.92, 1), 2.4)
	logo_pulse.tween_property(logo, "modulate", Color(1, 1, 1, 1), 2.4)

	var glow_pulse := create_tween().set_loops()
	glow_pulse.tween_property(logo_glow, "modulate:a", 0.22, 1.8)
	glow_pulse.tween_property(logo_glow, "modulate:a", 0.42, 1.8)

	_flicker_demo_label()


func _flicker_demo_label() -> void:
	await get_tree().create_timer(randf_range(3.0, 7.0)).timeout
	if not is_inside_tree():
		return

	demo_label.modulate.a = randf_range(0.45, 0.85)
	await get_tree().create_timer(randf_range(0.04, 0.12)).timeout
	if not is_inside_tree():
		return

	demo_label.modulate.a = 1.0
	_flicker_demo_label()


func _play_menu_music() -> void:
	bell_sound.volume_db = 0.0
	bell_sound.stream = BELL
	bell_sound.play()

	var bell_length := BELL.get_length()
	if bell_length <= 0.0:
		bell_length = 7.0

	var wait_before_fade := minf(TRANSITION_WAIT, maxf(0.0, bell_length - BELL_FADE_DURATION))
	await get_tree().create_timer(wait_before_fade).timeout
	if not is_inside_tree():
		return

	_start_theme()

	var fade_tween := create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(bell_sound, "volume_db", -80.0, BELL_FADE_DURATION)
	fade_tween.tween_property(theme_sound, "volume_db", 0.0, THEME_FADE_DURATION)
	await fade_tween.finished
	if not is_inside_tree():
		return

	bell_sound.stop()
	bell_sound.volume_db = 0.0


func _start_theme() -> void:
	if theme_sound.playing:
		return

	var theme_stream := THEME.duplicate()
	if theme_stream is AudioStreamMP3:
		theme_stream.loop = true

	theme_sound.volume_db = -80.0
	theme_sound.stream = theme_stream
	theme_sound.play()


func _on_play_pressed() -> void:
	_set_buttons_disabled(true)

	if bell_sound.playing:
		var bell_fade := create_tween()
		bell_fade.tween_property(bell_sound, "volume_db", -80.0, 4.0)

	if theme_sound.playing:
		var theme_fade := create_tween()
		theme_fade.tween_property(theme_sound, "volume_db", -80.0, 4.0)

	var fade_tween := create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 4.0)
	await fade_tween.finished
	if not is_inside_tree():
		return

	get_tree().change_scene_to_file(GAME_SCENE)


func _on_credits_pressed() -> void:
	credits_panel.visible = not credits_panel.visible


func _on_credits_close_pressed() -> void:
	credits_panel.visible = false


func _on_full_version_pressed() -> void:
	full_version_panel.visible = not full_version_panel.visible


func _on_full_version_close_pressed() -> void:
	full_version_panel.visible = false


func _set_buttons_disabled(disabled: bool) -> void:
	play_button.disabled = disabled
	credits_button.disabled = disabled
