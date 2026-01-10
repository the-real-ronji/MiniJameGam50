extends Control

signal finished(success: bool, data: Dictionary)

@export var hold_key: String = "ui_accept"   # Key to hold
@export var fill_speed: float = 0.2          # Fill per second (0-1 scale)
@export var pourWindow: float = 0.2
@export var lowerBound: float = 0.5
@export var upperBound: float = 0.9

@onready var fill_bar: TextureProgressBar = $FillBar
@onready var label: Label = $Label

var holding := false
var fill_amount := 0.0
var success := true
var min_fill: float = 0.7
var max_fill: float = 0.8

func start(data: Dictionary = {}) -> void:
	holding = false
	fill_amount = 0.0
	success = true
	fill_bar.value = 0.0
	
	# Extract life stage
	var stage = data.get("lifeStage", null)
	if stage != null:
		_adjust_difficulty(stage)
	
	# Pick a random range (10% wide, min >= 0.5)
	var min_percent = randf_range(0.5, 0.9)   # 50% to 90%
	min_fill = min_percent
	max_fill = min_fill + pourWindow                 # Always 10% window
	if max_fill > 1.0:
		max_fill = 1.0
	
	set_process(true)
	set_process_unhandled_input(true)
	print("Pour phase started! Hold '%s' and release between %.0f%% and %.0f%%." 
		% [hold_key, min_fill*100, max_fill*100])
	$range.text = "%.0f%% - %.0f%%" % [min_fill * 100, max_fill * 100]

func _process(delta: float) -> void:
	if holding:
		fill_amount += fill_speed * delta
		fill_amount = clamp(fill_amount, 0.0, 1.0)
		fill_bar.value = fill_amount * 100
	
	# Optional: Fail if overfill
	if fill_amount > 1.0:
		_fail("Overfilled!")
	
	label.text = "%.1f%%" % (fill_amount*100.0)     

func _unhandled_input(event: InputEvent) -> void:
	if not success:
		return
	
	if event.is_action_pressed(hold_key):
		holding = true
	
	if event.is_action_released(hold_key) and holding:
		holding = false
		if fill_amount >= min_fill and fill_amount <= max_fill:
			_success()
		else:
			_fail("Incorrect fill level! Filled %.0f%%" % (fill_amount*100))

func _adjust_difficulty(stage : QTEPanel.Stage) -> void:
	match stage:
		QTEPanel.Stage.Childhood:
			pass
		QTEPanel.Stage.Adolescence:
			pass
		QTEPanel.Stage.YoungAdult:
			pass
		QTEPanel.Stage.MiddleAge:
			pass
		QTEPanel.Stage.Senior:
			pass

func _success() -> void:
	success = true
	print("\nPour phase success! Filled %.0f%%" % (fill_amount*100))
	_end_phase(true, {"pour_success": true, "fill": fill_amount})

func _fail(reason: String) -> void:
	if not success:
		return
	success = false
	print("\nPour phase failed: ", reason)
	_end_phase(false, {"pour_success": false, "fill": fill_amount, "reason": reason})

func _end_phase(successful: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(successful, data)
