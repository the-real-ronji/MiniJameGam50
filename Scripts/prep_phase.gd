extends Control

signal finished(success: bool, data: Dictionary)

@onready var ice_bar: TextureProgressBar = $IceBar

var pressed := false
var elapsed := 0.0

@export var min_time := 0.5
@export var max_time := 1.0

func _ready() -> void:
	ice_bar.min_value = 0.0
	ice_bar.max_value = 1.0
	ice_bar.value = 0.0
	
	set_process(false)
	set_process_unhandled_input(false)

func start(sharedData := {}) -> void:
	pressed = false
	elapsed = 0.0
	ice_bar.value = 0.0
	
	set_process(true)
	set_process_unhandled_input(true)
	print("Prep phase started! Press SPACE between %.1f and %.1f seconds." % [min_time, max_time])

func _process(delta: float) -> void:
	if pressed:
		return
	
	elapsed += delta
	ice_bar.value = clamp(elapsed / 1.0, 0.0, 1.0)
	
	if elapsed > max_time:
		_fail("Too late!")

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

func _success() -> void:
	print("\n✅ Perfect ice prep! Timing was ", elapsed, " seconds.")
	_end_phase(true, {
		"prep_quality": remap(elapsed, min_time, max_time, 1.0, 0.7),
		"timing": elapsed
	})

func _fail(reason: String) -> void:
	print("\n❌ Prep failed: ", reason, " (pressed at ", elapsed, " seconds)")
	_end_phase(false, {
		"reason": reason,
		"timing": elapsed
	})

func _end_phase(success: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(success, data)
