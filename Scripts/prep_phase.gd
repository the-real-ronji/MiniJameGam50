extends Control

signal finished(success: bool, data: Dictionary)

@onready var ice_bar: TextureProgressBar = $IceBar
@onready var green: ColorRect = $Green
@onready var white: ColorRect = $White

# --- State variables ---
var pressed: bool = false
var elapsed: float = 0.0
var can_fill: bool = false

# --- Configurable values ---
@export var fill_duration: float = 3.0   # how long the bar takes to fill completely
@export var min_fraction: float = 0.5    # earliest valid press (fraction of fill_duration)
@export var max_fraction: float = 1.0    # latest valid press (fraction of fill_duration)

func _ready() -> void:
	$"prepphase tutorial".show()
	ice_bar.min_value = 0.0
	ice_bar.max_value = 1.0
	ice_bar.value = 0.0
	
	_update_green_zone()
	
	set_process(false)
	set_process_unhandled_input(false)


func start(_sharedData := {}) -> void:
	pressed = false
	elapsed = 0.0
	ice_bar.value = 0.0
	can_fill = false
	
	_update_green_zone()
	
	set_process(true)
	set_process_unhandled_input(true)
	print("Prep phase started! Press SPACE between %.1f and %.1f seconds." % [
		fill_duration * min_fraction,
		fill_duration * max_fraction
	])


func _process(delta: float) -> void:
	if pressed or not can_fill:
		return
	
	elapsed += delta
	ice_bar.value = clamp(elapsed / fill_duration, 0.0, 1.0)
	
	if elapsed > fill_duration * max_fraction:
		_fail("Too late!")
		return
	
	ice_bar.value = elapsed / fill_duration


func _unhandled_input(event: InputEvent) -> void:
	if pressed or not can_fill:
		return
	
	if event.is_action_pressed("space"):
		pressed = true
		
		if elapsed >= fill_duration * min_fraction and elapsed <= fill_duration * max_fraction:
			_success()
		elif elapsed < fill_duration * min_fraction:
			_fail("Too early!")
		else:
			_fail("Too late!")


func _update_green_zone() -> void:
	if not white:
		return
	
	var bar_width := white.size.x  # 400px
	
	var start_ratio := min_fraction / fill_duration
	var size_ratio := (max_fraction - min_fraction) / fill_duration
	
	green.position.x = white.position.x + start_ratio * bar_width
	green.size.x = size_ratio * bar_width
	green.size.y = white.size.y


func _success() -> void:
	print("\nPerfect ice prep! Timing:", elapsed)
	_end_phase(true, {
		"prep_quality": remap(elapsed, fill_duration * min_fraction, fill_duration * max_fraction, 1.0, 0.7),
		"timing": elapsed
	})


func _fail(reason: String) -> void:
	print("\nPrep failed:", reason, "(stopped at ", elapsed, ")")
	_end_phase(false, {
		"reason": reason,
		"timing": elapsed
	})


func _end_phase(success: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(success, data)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			can_fill = true
			$"prepphase tutorial".hide()
