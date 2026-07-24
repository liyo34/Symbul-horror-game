extends Node2D

#======================================================================
# HOW TO SET UP THE SCENE (Game.tscn)
#----------------------------------------------------------------------
# Build this node tree. Nodes marked (ADD LATER) are optional — the
# game will still run if they are missing, so you can drop them in
# whenever you want. Names must match EXACTLY.
#
# Game (Node2D)                        <- this script is attached here
# ├── CanvasLayer
# │   ├── BedroomView      (TextureRect)   full screen bedroom image
# │   ├── CameraView       (Control)       the tablet, hidden by default
# │   │   ├── CameraImage  (TextureRect)   the current camera picture
# │   │   ├── CamLabel     (Label)   (ADD LATER) shows "Cam 1/2/3"
# │   │   ├── Cam1Button   (Button)  -> connect "pressed" to _on_cam_1_button_pressed
# │   │   ├── Cam2Button   (Button)  -> connect "pressed" to _on_cam_2_button_pressed
# │   │   ├── Cam3Button   (Button)  -> connect "pressed" to _on_cam_3_button_pressed
# │   ├── ViewCameraButton (Button)  bottom button -> _on_view_camera_button_pressed
# │   ├── CloseEyesButton  (Button)  hold to close eyes -> button_down/button_up
# │   ├── StaticOverlay    (ColorRect) TV static shown in the bedroom while the entity is there
# │   ├── TimeLabel        (Label)   (ADD LATER) the clock
# │   ├── CloseEyesImage   (TextureRect) (ADD LATER) "close your eyes" picture
# │   └── EyesClosedOverlay(ColorRect)    black screen, color = black
# │   └── Jumpscare       (TextureRect)   drawn on top of everything
# │   ├── DemoOverlay      (ColorRect)    black screen for demo end card
# │   └── DemoLabel        (Label)        "Demo" text on the end card
# ├── EnemyTimer          (Timer)  -> connect "timeout" to _on_enemy_timer_timeout
# ├── NightTimer          (Timer)  -> connect "timeout" to _on_night_timer_timeout
# ├── BedroomTimer        (Timer)  one shot -> _on_bedroom_timer_timeout
# ├── AmbientTimer        (Timer)  one shot -> _on_ambient_timer_timeout
# ├── BedroomBreathing    (AudioStreamPlayer) bedroom breathing, bedroom view only
# ├── AmbientSound        (AudioStreamPlayer) random door knock / footsteps
# ├── LaughSound          (AudioStreamPlayer) plays while the player sees the entity
# ├── JumpscareSound      (AudioStreamPlayer) jumpscare sting
# ├── BellSound           (AudioStreamPlayer) morning bell at 7 AM
# └── AlarmSound          (AudioStreamPlayer) demo end alarm
#
# CONTROLS: hold SPACE (or hold the Close Eyes button) to close your eyes.
#           press Q to close the camera view.
#======================================================================


#=========================
# Nodes  (safe if missing)
#=========================

@onready var bedroom_view: TextureRect   = get_node_or_null("CanvasLayer/BedroomView")
@onready var generator_view: TextureRect  = get_node_or_null("CanvasLayer/GeneratorView")
@onready var camera_view: Control        = get_node_or_null("CanvasLayer/CameraView")
@onready var camera_image: TextureRect   = get_node_or_null("CanvasLayer/CameraView/CameraImage")
@onready var eyes_overlay: ColorRect     = get_node_or_null("CanvasLayer/EyesClosedOverlay")

# You can add these later; the game ignores them until they exist.
@onready var cam_label: Label            = get_node_or_null("CanvasLayer/CameraView/CamLabel")
@onready var time_label: Label           = get_node_or_null("CanvasLayer/TimeLabel")
@onready var battery_label: Label       = get_node_or_null("CanvasLayer/BatteryLabel")
@onready var battery_meter: ProgressBar = get_node_or_null("CanvasLayer/BatteryMeter")
@onready var electric_label: Label      = get_node_or_null("CanvasLayer/ElectricLabel")
@onready var electric_meter: ProgressBar = get_node_or_null("CanvasLayer/ElectricMeter")
@onready var power_warning: Label       = get_node_or_null("CanvasLayer/PowerWarning")
@onready var no_power_message: Label    = get_node_or_null("CanvasLayer/NoPowerMessage")
@onready var close_eyes_image: TextureRect = get_node_or_null("CanvasLayer/CloseEyesImage")
@onready var static_overlay: ColorRect   = get_node_or_null("CanvasLayer/StaticOverlay")
@onready var view_camera_button: Button  = get_node_or_null("CanvasLayer/ViewCameraButton")

@onready var jumpscare                   = get_node_or_null("CanvasLayer/Jumpscare")
@onready var jumpscare_red_spike: ColorRect = get_node_or_null("CanvasLayer/JumpscareRedSpike")
@onready var demo_overlay: ColorRect     = get_node_or_null("CanvasLayer/DemoOverlay")
@onready var demo_label: Label           = get_node_or_null("CanvasLayer/DemoLabel")
@onready var demo_exit_button: Button    = get_node_or_null("CanvasLayer/DemoExitButton")
@onready var start_fade: ColorRect       = get_node_or_null("CanvasLayer/StartFadeOverlay")
@onready var controls_overlay: ColorRect = get_node_or_null("CanvasLayer/ControlsOverlay")
@onready var controls_label: Label       = get_node_or_null("CanvasLayer/ControlsLabel")
@onready var win_screen: TextureRect     = get_node_or_null("CanvasLayer/WinScreen")
@onready var play_again_button: Button   = get_node_or_null("CanvasLayer/PlayAgainButton")
@onready var exit_button: Button         = get_node_or_null("CanvasLayer/ExitButton")

@onready var enemy_timer: Timer          = get_node_or_null("EnemyTimer")
@onready var night_timer: Timer          = get_node_or_null("NightTimer")
@onready var bedroom_timer: Timer        = get_node_or_null("BedroomTimer")
@onready var ambient_timer: Timer        = get_node_or_null("AmbientTimer")
@onready var bedroom_breathing: AudioStreamPlayer = get_node_or_null("BedroomBreathing")
@onready var ambient_sound: AudioStreamPlayer = get_node_or_null("AmbientSound")
@onready var laugh_sound: AudioStreamPlayer = get_node_or_null("LaughSound")
@onready var jumpscare_sound: AudioStreamPlayer = get_node_or_null("JumpscareSound")
@onready var bell_sound: AudioStreamPlayer = get_node_or_null("BellSound")
@onready var alarm_sound: AudioStreamPlayer = get_node_or_null("AlarmSound")
@onready var generator_sound: AudioStreamPlayer = get_node_or_null("GeneratorSound")
@onready var charge_sound: AudioStreamPlayer = get_node_or_null("ChargeSound")
@onready var generator_button: Button = get_node_or_null("CanvasLayer/GeneratorButton")
@onready var generator_label: Label = get_node_or_null("CanvasLayer/GeneratorLabel")
@onready var generator_power_label: Label = get_node_or_null("CanvasLayer/GeneratorPowerLabel")
@onready var generator_hold_label: Label = get_node_or_null("CanvasLayer/GeneratorHoldLabel")
@onready var generator_back_button: Button = get_node_or_null("CanvasLayer/GeneratorBackButton")

#=========================
# Images
#=========================

const STORAGE_EMPTY  = preload("res://assets/cameras/storagewithout_entity.png")
const STORAGE_ENTITY = preload("res://assets/cameras/storagewith_entity.png")

const HALLWAY_EMPTY  = preload("res://assets/cameras/hallwaywithout_entity.png")
const HALLWAY_ENTITY = preload("res://assets/cameras/hallwaywith_entity.png")

const BASEMENT_EMPTY  = preload("res://assets/cameras/basementwithout_entity.png")
const BASEMENT_ENTITY = preload("res://assets/cameras/basementwith_entity.png")

const BED_EMPTY  = preload("res://assets/cameras/bedwithout_entity.png")
const BED_ENTITY = preload("res://assets/cameras/bedwith_entity.png")

const JUMPSCARE = preload("res://assets/jumpscare/Jumpscare.png")
const SLOW_BREATHING = preload("res://assets/sounds/slowbreathing.mp3")
const FAST_BREATHING = preload("res://assets/sounds/fastbreathing.mp3")
const DOOR_KNOCK = preload("res://assets/sounds/doorknock.mp3")
const FOOTSTEP_1 = preload("res://assets/sounds/footstep1.mp3")
const FOOTSTEP_2 = preload("res://assets/sounds/footstep2.mp3")
const LAUGH = preload("res://assets/sounds/laugh.mp3")
const JUMPSCARE_SOUND = preload("res://assets/sounds/jumpscare.mp3")
const BELL = preload("res://assets/sounds/bell.mp3")
const ALARM = preload("res://assets/sounds/alarmeffect.mp3")
const GENERATOR_SOUND = preload("res://assets/sounds/generator.mp3")
const CHARGE_SOUND = preload("res://assets/sounds/charge.mp3")
const GAME_OVER_SCENE = "res://scenes/GameOver.tscn"
const MENU_SCENE = "res://scenes/Menu.tscn"

const AMBIENT_SOUNDS = [DOOR_KNOCK, FOOTSTEP_1, FOOTSTEP_2]
const AMBIENT_INTERVAL = 10.0

var laugh_stream: AudioStream

#=========================
# Camera mapping
#=========================
# Cam 1 = storage, Cam 2 = hallway, Cam 3 = basement

const CAM_ROOMS = {
	"cam1": "storage",
	"cam2": "hallway",
	"cam3": "basement",
}

const CAM_NAMES = {
	"cam1": "Cam 1",
	"cam2": "Cam 2",
	"cam3": "Cam 3",
}

var current_camera = "cam1"

#=========================
# View: "bedroom", "camera", or "generator"
#=========================

var current_view = "bedroom"

#=========================
# Time
#=========================

var hour = 12
var minute = 0

#=========================
# Enemy
#=========================

var enemy_path = [
	"storage",
	"hallway",
	"basement",
	"bedroom",
]

var enemy_index = 0
var enemy_room = "storage"

# Eyes mechanic
var eyes_closed = false
var in_bedroom_danger = false
# fast breathing stays on while eyes are closed so the player can't tell if the entity left
var uncertain_breathing = false
var game_ended = false

# Power system
var battery_level = 100.0
var electric_level = 100.0
var power_warning_shown = false
var generator_held = false

#=========================
# Ready
#=========================

func _ready():

	if jumpscare:
		jumpscare.visible = false
	if eyes_overlay:
		eyes_overlay.visible = false
	if close_eyes_image:
		close_eyes_image.visible = false
	if demo_overlay:
		demo_overlay.visible = false
	if demo_label:
		demo_label.visible = false
	if start_fade:
		start_fade.color = Color(0, 0, 0, 1)

	if battery_meter:
		battery_meter.value = battery_level
	if electric_meter:
		electric_meter.value = electric_level
	if power_warning:
		power_warning.visible = false

	laugh_stream = LAUGH.duplicate()
	if laugh_stream is AudioStreamMP3:
		laugh_stream.loop = true

	if enemy_timer:
		enemy_timer.wait_time = 8.0

	if night_timer:
		night_timer.wait_time = 1.0

	if bedroom_timer:
		# time the player has to react once the entity reaches the bedroom
		bedroom_timer.wait_time = 6.0
		bedroom_timer.one_shot = true

	# stop Space/Enter from activating buttons when used to close eyes
	if view_camera_button:
		view_camera_button.focus_mode = Control.FOCUS_NONE

	update_view()
	update_camera_image()
	update_bedroom()
	update_time()
	update_power_meters()

	await _fade_in_game()

	# Show controls for 2 seconds, then fade out over 2 seconds
	if controls_overlay and controls_label:
		controls_overlay.visible = true
		controls_label.visible = true
		await get_tree().create_timer(2.0).timeout
		var fade_tween := create_tween()
		fade_tween.tween_property(controls_overlay, "color:a", 0.0, 2.0)
		fade_tween.tween_property(controls_label, "modulate:a", 0.0, 2.0)
		fade_tween.tween_callback(func():
			if controls_overlay:
				controls_overlay.visible = false
			if controls_label:
				controls_label.visible = false
		)

	if enemy_timer:
		enemy_timer.start()
	if night_timer:
		night_timer.start()

	schedule_ambient_sound()


func _fade_in_game() -> void:
	if start_fade == null:
		return

	var tween := create_tween()
	tween.tween_property(start_fade, "color:a", 0.0, 2.0)
	await tween.finished
	if not is_inside_tree():
		return

#=========================
# Eyes (hold SPACE)
#=========================

func _process(delta):

	# eyes can only be closed in the bedroom view (not while watching cameras)
	var want_closed = is_eyes_closed()

	if want_closed != eyes_closed:
		eyes_closed = want_closed

		if eyes_overlay:
			eyes_overlay.visible = eyes_closed

		# hide the "close your eyes" prompt while the eyes are actually closed
		if close_eyes_image:
			close_eyes_image.visible = in_bedroom_danger and not eyes_closed

		# only switch to slow breathing once the player opens their eyes and sees the room is clear
		if not eyes_closed and enemy_room != "bedroom":
			uncertain_breathing = false

		update_bedroom_breathing()
		update_view()

	update_laugh()

	# can't open cameras while eyes are closed
	if view_camera_button:
		view_camera_button.disabled = eyes_closed

	# battery depletion when using tablet (per second, faster than electric)
	if current_view == "camera" and not game_ended:
		battery_level -= 3.0 * delta
		if battery_level < 0:
			battery_level = 0
		update_power_meters()

	# tablet charging from generator when not using tablet
	if current_view == "bedroom" and electric_level > 0 and battery_level < 100 and not game_ended:
		battery_level += 5.0 * delta
		if battery_level > 100:
			battery_level = 100
		update_power_meters()
		# hide no power message if power is restored
		if electric_level > 0 and no_power_message:
			no_power_message.visible = false

	# generator charging electric meter (only in generator view)
	if generator_held and electric_level < 100 and not game_ended:
		electric_level += 3.0 * delta
		if electric_level > 100:
			electric_level = 100
		update_power_meters()
		# hide warning if power is restored
		if electric_level > 20 and power_warning_shown:
			power_warning_shown = false
			if power_warning:
				power_warning.visible = false
		# hide no power message if power is restored
		if electric_level > 0 and no_power_message:
			no_power_message.visible = false

# Press Q to close the camera view
func _input(event):
	if event is InputEventKey and not event.echo:
		if event.keycode == KEY_Q and event.pressed:
			if current_view == "camera":
				close_camera_view()
			elif current_view == "generator":
				_on_generator_back_pressed()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE and current_view == "bedroom":
			get_viewport().set_input_as_handled()
		elif (event.keycode == KEY_W or event.keycode == KEY_E) and current_view == "generator":
			if event.pressed:
				generator_held = true
				_start_charging()
			else:
				generator_held = false
				_stop_charging()
			get_viewport().set_input_as_handled()


func _start_charging() -> void:
	if generator_sound:
		generator_sound.stream = GENERATOR_SOUND
		generator_sound.play()
	if charge_sound:
		charge_sound.stream = CHARGE_SOUND
		charge_sound.play()

func _stop_charging() -> void:
	if generator_sound and generator_sound.playing:
		generator_sound.stop()
	if charge_sound and charge_sound.playing:
		charge_sound.stop()

func is_eyes_closed() -> bool:
	if game_ended:
		return false
	return current_view == "bedroom" and Input.is_key_pressed(KEY_SPACE)

func player_sees_bedroom_entity() -> bool:
	return (
		not game_ended
		and current_view == "bedroom"
		and not is_eyes_closed()
		and enemy_room == "bedroom"
	)

#=========================
# View switching
#=========================

func update_view():

	if bedroom_view:
		bedroom_view.visible = current_view == "bedroom"

	if generator_view:
		generator_view.visible = current_view == "generator"

	if camera_view:
		camera_view.visible = current_view == "camera"

	# only show "View Camera" in the bedroom — prevents double-clicks while on cameras
	if view_camera_button:
		view_camera_button.visible = current_view == "bedroom"

	# generator button only shows in bedroom and when eyes are open
	if generator_button:
		generator_button.visible = current_view == "bedroom" and not eyes_closed
	if generator_label:
		generator_label.visible = current_view == "bedroom" and not eyes_closed

	# generator view elements
	if generator_power_label:
		generator_power_label.visible = current_view == "generator"
	if generator_hold_label:
		generator_hold_label.visible = current_view == "generator"
	if generator_back_button:
		generator_back_button.visible = current_view == "generator"

	update_static()
	update_bedroom_breathing()
	update_laugh()
	schedule_ambient_sound()

# Bottom "View Camera" button — opens the tablet (bedroom only)
func _on_view_camera_button_pressed():
	if current_view != "bedroom":
		return

	if battery_level <= 0:
		return

	current_view = "camera"
	update_view()
	update_camera_image()
	play_random_ambient()

# Generator button — switches to generator view
func _on_generator_button_pressed():
	if current_view != "bedroom":
		return

	current_view = "generator"
	update_view()

# Generator back button — returns to bedroom
func _on_generator_back_pressed():
	if current_view != "generator":
		return

	current_view = "bedroom"
	update_view()

# Generator charge hold in generator view
func _on_generator_charge_down():
	if current_view == "generator":
		generator_held = true
		_start_charging()

func _on_generator_charge_up():
	generator_held = false
	_stop_charging()

# Close the tablet and return to the bedroom
func close_camera_view():
	if current_view != "camera":
		return

	current_view = "bedroom"
	update_view()

#=========================
# Camera display
#=========================

func update_camera_image():

	if camera_image == null:
		return

	var room = CAM_ROOMS[current_camera]
	var has_entity = enemy_room == room

	match room:
		"storage":
			camera_image.texture = STORAGE_ENTITY if has_entity else STORAGE_EMPTY
		"hallway":
			camera_image.texture = HALLWAY_ENTITY if has_entity else HALLWAY_EMPTY
		"basement":
			camera_image.texture = BASEMENT_ENTITY if has_entity else BASEMENT_EMPTY

	if cam_label:
		cam_label.text = CAM_NAMES[current_camera]

	update_static()

#=========================
# Bedroom display
#=========================

func update_bedroom():

	if bedroom_view == null:
		return

	bedroom_view.texture = BED_ENTITY if enemy_room == "bedroom" else BED_EMPTY
	update_bedroom_breathing()
	update_laugh()

#=========================
# Camera buttons
#=========================

func _on_cam_1_button_pressed():
	current_camera = "cam1"
	update_camera_image()

func _on_cam_2_button_pressed():
	current_camera = "cam2"
	update_camera_image()

func _on_cam_3_button_pressed():
	current_camera = "cam3"
	update_camera_image()

#=========================
# Enemy AI
#=========================

func _on_enemy_timer_timeout():

	# Already in the bedroom and waiting for the eyes reaction? do nothing here,
	# BedroomTimer decides whether the player survives.
	if enemy_room == "bedroom":
		return

	var left_room = enemy_room

	enemy_index += 1
	enemy_room = enemy_path[enemy_index]

	print("Enemy moved to ", enemy_room)

	if enemy_room == "bedroom":
		start_bedroom_danger()

	update_camera_image()
	update_bedroom()

	# quick one-time static burst on the camera the entity just left
	if current_view == "camera" and CAM_ROOMS.get(current_camera) == left_room:
		play_camera_static()

#=========================
# Bedroom danger (close your eyes)
#=========================

func start_bedroom_danger():

	in_bedroom_danger = true
	uncertain_breathing = true

	# show the "close your eyes" prompt (only if eyes are currently open)
	if close_eyes_image:
		close_eyes_image.visible = not eyes_closed

	if bedroom_timer:
		bedroom_timer.start()

	update_bedroom_breathing()
	update_laugh()

func _on_bedroom_timer_timeout():

	if eyes_closed:
		# survived: the entity leaves and starts over from storage
		in_bedroom_danger = false

		if close_eyes_image:
			close_eyes_image.visible = false

		enemy_index = 0
		enemy_room = "storage"

		update_camera_image()
		update_bedroom()
	else:
		attack_player()

#=========================
# Analog static
#=========================
# Bedroom: static stays on the whole time the entity is in the bedroom.
# Cameras: no static while the entity is there; a quick one-time burst plays
# on the camera the moment the entity leaves that room.

func update_static():

	if static_overlay == null:
		return

	static_overlay.visible = current_view == "bedroom" and enemy_room == "bedroom"

func update_bedroom_breathing():

	if bedroom_breathing == null:
		return

	if current_view != "bedroom" and current_view != "generator":
		if bedroom_breathing.playing:
			bedroom_breathing.stop()
		return

	# fast while the entity is here, or while eyes stay closed after danger (player can't tell if it left)
	var use_fast = enemy_room == "bedroom" or uncertain_breathing
	var target_stream = FAST_BREATHING if use_fast else SLOW_BREATHING

	if bedroom_breathing.stream != target_stream:
		bedroom_breathing.stream = target_stream
		bedroom_breathing.play()
	elif not bedroom_breathing.playing:
		bedroom_breathing.play()

func update_laugh():

	if laugh_sound == null:
		return

	if player_sees_bedroom_entity():
		if laugh_sound.stream != laugh_stream:
			laugh_sound.stream = laugh_stream
		if not laugh_sound.playing:
			laugh_sound.play()
	elif laugh_sound.playing:
		laugh_sound.stop()

func schedule_ambient_sound():

	if ambient_timer == null or game_ended:
		return

	if current_view != "bedroom" and current_view != "camera" and current_view != "generator":
		return

	ambient_timer.wait_time = AMBIENT_INTERVAL
	ambient_timer.start()

func _on_ambient_timer_timeout():

	if game_ended:
		return

	if current_view == "bedroom" or current_view == "camera" or current_view == "generator":
		play_random_ambient()

	schedule_ambient_sound()


func play_random_ambient() -> void:

	if ambient_sound == null or ambient_sound.playing:
		return

	ambient_sound.stream = AMBIENT_SOUNDS.pick_random()
	ambient_sound.play()

func stop_game_audio():

	if bedroom_breathing and bedroom_breathing.playing:
		bedroom_breathing.stop()
	if ambient_sound and ambient_sound.playing:
		ambient_sound.stop()
	if laugh_sound and laugh_sound.playing:
		laugh_sound.stop()
	if ambient_timer:
		ambient_timer.stop()

# A quick one-time static burst on the camera when the entity leaves a room
func play_camera_static(duration := 0.4):

	if static_overlay == null:
		return

	static_overlay.visible = true
	await get_tree().create_timer(duration).timeout
	if not is_inside_tree():
		return
	update_static()

#=========================
# Night clock
#=========================

func _on_night_timer_timeout():

	minute += 1

	if minute >= 60:
		minute = 0
		hour += 1
		if hour >= 24:
			hour = 0
		increase_difficulty()

	if hour == 19:
		win_game()
		return

	update_time()

	# electric depletion only when using camera
	if not game_ended and current_view == "camera":
		electric_level -= 2.0
		if electric_level < 0:
			electric_level = 0
		update_power_meters()

		# check for power warning
		if electric_level <= 20 and not power_warning_shown:
			power_warning_shown = true
			if power_warning:
				power_warning.visible = true

		# jumpscare if electric is empty
		if electric_level <= 0:
			attack_player()

func update_time():

	if time_label == null:
		return

	var minute_string = str(minute).pad_zeros(2)
	time_label.text = str(hour) + ":" + minute_string + " AM"

func update_power_meters() -> void:
	if battery_meter:
		battery_meter.value = battery_level
	if electric_meter:
		electric_meter.value = electric_level

#=========================
# Difficulty
#=========================

func increase_difficulty():

	if enemy_timer == null:
		return

	match hour:
		1: enemy_timer.wait_time = 7.0
		2: enemy_timer.wait_time = 6.5
		3: enemy_timer.wait_time = 6.0
		4: enemy_timer.wait_time = 5.5
		5: enemy_timer.wait_time = 5.0
		6: enemy_timer.wait_time = 4.0

#=========================
# Lose
#=========================

func attack_player():

	game_ended = true

	if enemy_timer:
		enemy_timer.stop()
	if night_timer:
		night_timer.stop()
	stop_game_audio()

	if jumpscare:
		jumpscare.texture = JUMPSCARE
		jumpscare.visible = true

	if jumpscare_red_spike:
		jumpscare_red_spike.visible = true

	if jumpscare_sound:
		jumpscare_sound.stream = JUMPSCARE_SOUND
		jumpscare_sound.play()

	_start_jumpscare_effects()

	await get_tree().create_timer(3.0).timeout
	if not is_inside_tree():
		return

	get_tree().change_scene_to_file(GAME_OVER_SCENE)

func _start_jumpscare_effects() -> void:
	if jumpscare_red_spike:
		var spike_tween := create_tween().set_loops()
		spike_tween.tween_property(jumpscare_red_spike, "color:a", 0.6, 0.05)
		spike_tween.tween_property(jumpscare_red_spike, "color:a", 0.0, 0.05)
		spike_tween.tween_property(jumpscare_red_spike, "color:a", 0.8, 0.03)
		spike_tween.tween_property(jumpscare_red_spike, "color:a", 0.0, 0.08)

	if jumpscare:
		var shake_tween := create_tween().set_loops()
		shake_tween.tween_property(jumpscare, "position:x", 10.0, 0.02)
		shake_tween.tween_property(jumpscare, "position:x", -10.0, 0.02)
		shake_tween.tween_property(jumpscare, "position:y", 5.0, 0.02)
		shake_tween.tween_property(jumpscare, "position:y", -5.0, 0.02)

#=========================
# Win
#=========================

func win_game():

	game_ended = true

	if enemy_timer:
		enemy_timer.stop()
	if night_timer:
		night_timer.stop()
	stop_game_audio()

	if alarm_sound:
		alarm_sound.stream = ALARM
		alarm_sound.play()

	if win_screen:
		win_screen.visible = true
	if play_again_button:
		play_again_button.visible = true
	if exit_button:
		exit_button.visible = true


func _on_demo_exit_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
