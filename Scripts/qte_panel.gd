extends Control
class_name QTEPanel

signal finished(success: bool, data: Dictionary)

@onready var phaseContainer: Control = $Phases

var phases: Array[PackedScene] = []
var phaseIndex := 0
var currentPhase: Control = null
var lifeStage
var accData : Dictionary = {}

func start_qte(phaseList : Array[PackedScene], stage : Main.Stage, initialData := {} ) -> void:
	show()
	lifeStage = stage
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
		var startData = accData.duplicate()
		startData["lifeStage"] = lifeStage
		currentPhase.start(startData)
	
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
