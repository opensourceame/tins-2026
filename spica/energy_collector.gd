class_name EnergyCollector
extends StaticBody2D

@onready var collect_area: Area2D = $CollectArea
@onready var top: Polygon2D = $Top

var collecting: bool = false

func _ready():
    collect_area.area_entered.connect(_on_collect_area_entered)
    collect_area.area_exited.connect(_on_collect_area_exited)

    top.modulate = Color.DARK_MAGENTA

func _on_collect_area_entered(area: Area2D) -> void:
    collecting = true
    top.modulate = Color.WHITE

func _on_collect_area_exited(area: Area2D) -> void:
    collecting = false
    top.modulate = Color.DARK_MAGENTA

func _physics_process(_delta: float) -> void:
    if collecting:
        if randf() < 0.15:
            SignalBus.energy_collected.emit()
