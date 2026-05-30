class_name EnergyCollector
extends StaticBody2D

@onready var collect_area: Area2D = $CollectArea

func _physics_process(_delta: float) -> void:
    for area in collect_area.get_overlapping_areas():
        if area.name == &"EnergyCollectArea":
            SignalBus.energy_collected.emit()
            return
