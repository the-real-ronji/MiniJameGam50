extends Control

signal finished(success: bool, data: Dictionary)

@onready var ice_bar: TextureProgressBar = $IceBar
@onready var green: ColorRect = $Green
@onready var white: ColorRect = $White

var pressed := false
var elapsed := 0.0

@export var min_time := 0.5
@export var max_time := 0.8
@export var total_time := 1.0


func _ready() -> void:
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
	
	_update_green_zone()
	
	set_process(true)
	set_process_unhandled_input(true)
	print("Prep phase started! Press SPACE between %.1f and %.1f seconds." % [min_time, max_time])


func _process(delta: float) -> void:
	if pressed:
		return
	
	elapsed += delta
	
	if elapsed >= total_time:
		elapsed = total_time
		ice_bar.value = 1.0
		_fail("Too late!")
		return
	
	ice_bar.value = elapsed / total_time


func _unhandled_input(event: InputEvent) -> void:
	if pressed:
		return
	
	if event.is_action_pressed("ui_accept"):
		pressed = true
		
		if elapsed >= min_time and elapsed <= max_time:
			_success()
		elif elapsed < min_time:
			_fail("Too early!")
		else:
			_fail("Too late!")


func _update_green_zone() -> void:
	if not white:
		return
	
	var bar_width := white.size.x  # 400px
	
	var start_ratio := min_time / total_time
	var size_ratio := (max_time - min_time) / total_time
	
	green.position.x = white.position.x + start_ratio * bar_width
	green.size.x = size_ratio * bar_width
	green.size.y = white.size.y


func _success() -> void:
	print("✅ Perfect ice prep! Timing:", elapsed)
	_end_phase(true, {
		"prep_quality": remap(elapsed, min_time, max_time, 1.0, 0.7),
		"timing": elapsed
	})


func _fail(reason: String) -> void:
	print("❌ Prep failed:", reason, "(stopped at ", elapsed, ")")
	_end_phase(false, {
		"reason": reason,
		"timing": elapsed
	})


func _end_phase(success: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(success, data)
