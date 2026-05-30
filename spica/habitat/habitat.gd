class_name Habitat
extends Node2D

const VERTEBRA = preload("res://spica/habitat/vertebra.tscn")

@onready var label: Label = $Label
@onready var spine: Node2D = $Spine
@onready var color_rect: ColorRect = $ColorRect

var capacity = 0
var captured = 0

var environment: String = "air":
    set(value):
        environment = value
        update_environment()

func _ready():
    label.text = name
    update_environment()

func update_environment():
    match environment:
        "water":
            modulate = Color(0.4, 0.6, 1.0)
        "sulphuric":
            modulate = Color(0.5, 1.0, 0.4)
        _:
            modulate = Color.WHITE

func capture(species, amount):
    capacity -= amount

func has_space():
    return capacity > 0

func grow() -> bool:
    if capacity > 9:
        return false

    var v = VERTEBRA.instantiate()
    spine.add_child(v)
    v.scale.y = 0.1
    v.position.y = capacity * -96

    var tween = create_tween()
    tween.tween_property(v, "scale.y", 1.0, 2.0)

    capacity += 1
    SignalBus.habitat_capacity_changed.emit(self)
    return true
