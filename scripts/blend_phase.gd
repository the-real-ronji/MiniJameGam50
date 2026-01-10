extends Control

signal finished(success: bool, data: Dictionary)

@export var sequence: Array[String] = ["W", "D", "S", "A", "W", "D", "S", "A"]  # Default: childhood
@export var input_map: Dictionary[String, String] = {"W": "w", "A": "a", "D": "d", "S": "s"}  # Key mapping
@export var input_time_window: float = 3.0  # seconds allowed per input
@export var letterTextures: Dictionary[String, Texture] = {
	"W": preload("res://Sprites/temp sprites prototype/w.jpg"),
	"A": preload("res://Sprites/temp sprites prototype/a.jpg"),
	"S": preload("res://Sprites/temp sprites prototype/s.jpg"),
	"D": preload("res://Sprites/temp sprites prototype/d.png")
}

@onready var image: TextureRect = $image


var current_index: int = 0
var timer: float = 0.0
var success: bool = true

func start(sharedData: Dictionary = {}) -> void:
	current_index = 0
	timer = 0.0
	success = true
	set_process(true)
	set_process_unhandled_input(true)
	_update_image()
	print("Blend phase started! Sequence: ", sequence)

func _process(delta: float) -> void:
	if not success or current_index >= sequence.size():
		return
	_update_image()
	
	
	timer += delta
	if timer > input_time_window:
		_fail("Too slow!")

func _unhandled_input(event: InputEvent) -> void:
	if not success or current_index >= sequence.size():
		return
	
	var expected_key: String = input_map.get(sequence[current_index], "")
	if expected_key == "":
		push_error("No mapping for input: %s" % sequence[current_index])
		return

	if event.is_action_pressed(expected_key):
		if timer <= input_time_window:
			print("Input %s correct!" % sequence[current_index])
			current_index += 1
			timer = 0.0
			if current_index >= sequence.size():
				_success()
		else:
			_fail("Too slow!")

func _update_image() -> void:
	if current_index < sequence.size():
		var letter := sequence[current_index]
		if letterTextures.has(letter):
			image.texture = letterTextures[letter]
		else:
			image.texture = null
	else:
		image.texture = null

func _success() -> void:
	success = true
	print("Blend phase completed perfectly!")
	_end_phase(true, {"blend_success": true, "inputs_hit": current_index})

func _fail(reason: String) -> void:
	if not success:
		return
	success = false
	print("Blend phase failed: ", reason)
	_end_phase(false, {"blend_success": false, "failed_at": current_index, "reason": reason})

func _end_phase(successful: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(successful, data)
