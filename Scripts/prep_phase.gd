extends Control

signal finished(success: bool, data: Dictionary)

@onready var ice_bar: TextureProgressBar = $IceBar
@onready var green: ColorRect = $Green
@onready var white: ColorRect = $White
@onready var tutorial := $"prepphase tutorial"
#@onready var anim := $AnimatedSprite2D

# --- State ---
var pressed: bool = false
var elapsed: float = 0.0
var can_fill: bool = false
var timing_started := false

# --- Timing config ---
@export var total_time: float = 3.0      # full bar duration (seconds)

# --- Difficulty tuning ----
@export var window_min_size := 0.15
@export var window_max_size := 0.30
@export var window_min_start := 0.0

# success window as FRACTIONS of total_time (0–1)
@export_range(0.0, 1.0) var min_fraction := 0.4
@export_range(0.0, 1.0) var max_fraction := 0.65


func _ready() -> void:
	ice_bar.min_value = 0.0
	ice_bar.max_value = 1.0
	ice_bar.value = 0.0

	if tutorial:
		tutorial.show()
	
	timing_started = false
	_update_green_zone()

	set_process(false)
	set_process_unhandled_input(false)


func start(data := {}) -> void:
	pressed = false
	elapsed = 0.0
	can_fill = false
	ice_bar.value = 0.0

	# --- RANDOMIZE WINDOW EACH START ---
	var window_size := randf_range(0.15, 0.30)   # 15%–30% bar size
	min_fraction = randf_range(0.0, 1.0 - window_size)
	max_fraction = min_fraction + window_size
	
	var stage = data.get("lifeStage", null)
	if stage != null:
		_adjust_difficulty(stage)

	_update_green_zone()
	
	set_process(true)
	set_process_unhandled_input(true)

	print(
		"Prep phase started! Press SPACE between %.2f and %.2f seconds."
		% [
			total_time * min_fraction,
			total_time * max_fraction
		]
	)

func _adjust_difficulty(stage: Main.Stage) -> void:
	match stage:
		Main.Stage.Childhood:
			total_time = 1.6
			window_min_size = 0.25
			window_max_size = 0.50
			window_min_start = 0.40

		Main.Stage.Adolescence:
			total_time = 1.3
			window_min_size = 0.20
			window_max_size = 0.35
			window_min_start = 0.35

		Main.Stage.YoungAdult:
			total_time = 1.1
			window_min_size = 0.18
			window_max_size = 0.30
			window_min_start = 0.40

		Main.Stage.MiddleAge:
			total_time = 0.9
			window_min_size = 0.15
			window_max_size = 0.25
			window_min_start = 0.45

		Main.Stage.Senior:
			total_time = 0.75
			window_min_size = 0.10
			window_max_size = 0.18
			window_min_start = 0.50


func _process(delta: float) -> void:
	if not can_fill:
		return

	if not timing_started:
		timing_started = true
		elapsed = 0.0
		return

	elapsed += delta

	if pressed:
		return

	if elapsed >= total_time:
		elapsed = total_time
		ice_bar.value = 1.0
		_fail("Too late!")
		return

	ice_bar.value = elapsed / total_time


func _unhandled_input(event: InputEvent) -> void:
	if pressed or not can_fill or not timing_started:
		return

	if event.is_action_pressed("ui_accept"):
		pressed = true

		var min_time := total_time * min_fraction
		var max_time := total_time * max_fraction

		if elapsed >= min_time and elapsed <= max_time:
			_success()
		elif elapsed < min_time:
			_fail("Too early!")
		else:
			_fail("Too late!")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		can_fill = true
		if tutorial:
			tutorial.hide()


func _update_green_zone() -> void:
	if not white:
		return

	var bar_width := white.size.x

	var start_ratio := min_fraction
	var size_ratio := max_fraction - min_fraction

	green.position.x = white.position.x + start_ratio * bar_width
	green.size.x = size_ratio * bar_width
	green.size.y = white.size.y


func _success() -> void:
	print("Perfect ice prep! Timing:", elapsed)

	_end_phase(true, {
		"prep_quality": remap(
			elapsed,
			total_time * min_fraction,
			total_time * max_fraction,
			1.0,
			0.7
		),
		"timing": elapsed
	})


func _fail(reason: String) -> void:
	print("Prep failed:", reason, "(stopped at", elapsed, ")")

	_end_phase(false, {
		"reason": reason,
		"timing": elapsed
	})


func _end_phase(success: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(success, data)
