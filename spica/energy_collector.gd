class_name EnergyCollector
extends StaticBody2D

@onready var collect_area: Area2D = $CollectArea

var collecting: bool = false

func _ready():
    collect_area.area_entered.connect(_on_collect_area_entered)
    collect_area.area_exited.connect(_on_collect_area_exited)

func _on_collect_area_entered(area: Area2D) -> void:
    collecting = true

func _on_collect_area_exited(area: Area2D) -> void:
    collecting = false

func _physics_process(_delta: float) -> void:
    if collecting:
        if randf() < 0.1:
            SignalBus.energy_collected.emit()
