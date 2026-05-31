class_name EnergyCollector
extends StaticBody2D

const MAX_EFFICIENCY = 7

@onready var collect_area: Area2D = $CollectArea
@onready var top: Polygon2D = $Top

var collecting: bool = false
var efficiency: int = 0

@export var energy_collection_rate = 0.25

func _ready():
    energy_collection_rate = SettingsManager.energy_collection_rate
    collect_area.area_entered.connect(_on_collect_area_entered)
    collect_area.area_exited.connect(_on_collect_area_exited)

    top.modulate = Color.DARK_MAGENTA

    upgrade()

func _on_collect_area_entered(area: Area2D) -> void:
    collecting = true
    top.modulate = Color.WHITE

func _on_collect_area_exited(area: Area2D) -> void:
    collecting = false
    top.modulate = Color.DARK_MAGENTA

func _physics_process(_delta: float) -> void:
    if collecting:
        if randf() < efficiency / 7.03  * energy_collection_rate * Engine.time_scale:
            SignalBus.energy_collected.emit()

func can_upgrade():
    return efficiency < MAX_EFFICIENCY

func upgrade():
    if efficiency >= MAX_EFFICIENCY:
        return

    var nodes = $Grid.get_children()

    var i = 0
    for node in nodes:
        if i > efficiency:
            node.color = Color.BROWN
        else:
            node.color = Color.WHITE
        i += 1

    efficiency += 1

    return true
