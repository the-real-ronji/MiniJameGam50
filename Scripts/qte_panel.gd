extends Control
class_name QTEPanel

signal finished(success: bool, data: Dictionary)

enum Stage {Childhood, Adolescence, YoungAdult, MiddleAge, Senior}
@export var lifeStage : Stage = Stage.Childhood

@onready var phaseContainer: Control = $Phases

var phases: Array[PackedScene] = []
var phaseIndex := 0
var currentPhase: Control = null

var accData : Dictionary = {}

func start_qte(phaseList : Array[PackedScene], initialData := {}) -> void:
	show()
	
	phases = phaseList
	phaseIndex = 0
	accData = initialData.duplicate()
	_start_next_phase()

func _start_next_phase() -> void:
	if currentPhase:
		currentPhase.queue_free()
		currentPhase = null
	
	if phaseIndex >= phases.size():
		_finish_qte(true)
		return
	
	currentPhase = phases[phaseIndex].instantiate()
	phaseContainer.add_child(currentPhase)
	
	currentPhase.finished.connect(_on_phase_finished)
	
	if currentPhase.has_method("start"):
		currentPhase.start(accData)
	
	phaseIndex+=1

func _on_phase_finished(success: bool, data : Dictionary) -> void:
	if not success:
		_finish_qte(false, data)
		return
	
	accData.merge(data, true)
	_start_next_phase()

func _finish_qte(success: bool, finalData := {}) -> void:
	hide()
	
	if currentPhase:
		currentPhase.queue_free()
		currentPhase = null
	
	accData.merge(finalData)
	finished.emit(success, accData)
