extends Control

signal finished(success: bool, data: Dictionary)

@onready var ice_bar: TextureProgressBar = $IceBar
@onready var green: ColorRect = $Green
@onready var white: ColorRect = $White
@onready var tutorial := $"prepphase tutorial"

# --- QTE state ---
var pressed: bool = false
var elapsed: float = 0.0
var can_fill: bool = false
var timing_started := false

# --- Timing / difficulty ---
@export var total_time: float = 1.0

# These are used internally for randomization within stage
var greenZoneStart: float = 0.4
var greenZoneEnd: float = 0.9
var greenZoneLowerBound: float = 0.15
var greenZoneUpperBound: float = 0.3

# Final fractions used for the bar
var min_fraction: float = 0.5
var max_fraction: float = 0.8

# --- Start QTE ---
func start(data := {}) -> void:
	pressed = false
	elapsed = 0.0
	timing_started = false
	can_fill = false
	ice_bar.value = 0.0

	if tutorial:
		tutorial.show()

	# Extract life stage
	var stage = data.get("lifeStage", null)
	if stage != null:
		_adjust_difficulty(stage)
	
	# Randomize green zone within stage-defined bounds
	var window_size := randf_range(greenZoneLowerBound, greenZoneUpperBound)
	min_fraction = randf_range(greenZoneStart, greenZoneEnd - window_size)
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

# --- Adjust difficulty and green zone bounds by stage ---
func _adjust_difficulty(stage: Main.Stage) -> void:
	match stage:
		Main.Stage.Childhood:
			total_time = 1.5
			greenZoneStart = 0.4
			greenZoneEnd = 0.9
			greenZoneLowerBound = 0.3
			greenZoneUpperBound = 0.5
		Main.Stage.Adolescence:
			total_time = 1.2
			greenZoneStart = 0.45
			greenZoneEnd = 0.85
			greenZoneLowerBound = 0.25
			greenZoneUpperBound = 0.45
		Main.Stage.YoungAdult:
			total_time = 1.0
			greenZoneStart = 0.5
			greenZoneEnd = 0.85
			greenZoneLowerBound = 0.2
			greenZoneUpperBound = 0.4
		Main.Stage.MiddleAge:
			total_time = 0.8
			greenZoneStart = 0.55
			greenZoneEnd = 0.85
			greenZoneLowerBound = 0.15
			greenZoneUpperBound = 0.35
		Main.Stage.Senior:
			total_time = 0.7
			greenZoneStart = 0.6
			greenZoneEnd = 0.85
			greenZoneLowerBound = 0.1
			greenZoneUpperBound = 0.25

# --- Process / timing ---
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

# --- Input ---
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

# --- Green zone display ---
func _update_green_zone() -> void:
	if not white:
		return
	var bar_width := white.size.x
	var start_ratio := min_fraction
	var size_ratio := max_fraction - min_fraction

	green.position.x = white.position.x + start_ratio * bar_width
	green.size.x = size_ratio * bar_width
	green.size.y = white.size.y

# --- Success / fail ---
func _success() -> void:
	print("Perfect ice prep! Timing: ", elapsed)
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
	print("Prep failed: ", reason, "(stopped at ", elapsed, ")")
	_end_phase(false, {
		"reason": reason,
		"timing": elapsed
	})

func _end_phase(success: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(success, data)
