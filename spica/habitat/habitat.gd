class_name Habitat
extends Node2D

const VERTEBRA = preload("res://spica/habitat/vertebra.tscn")

@onready var label: Label = $Label
@onready var spine: Node2D = $Spine
@onready var grow_timer: Timer = $GrowTimer

var capacity = 0

func _ready():
    label.text = name

    grow_timer.timeout.connect(increment_capacity)
    grow_timer.start()

func capture(species, amount):
    capacity -= amount

func has_space():
    capacity > 0

func increment_capacity():
    if capacity > 9:
        return

    SignalBus.habitat_capacity_changed.emit(self)

    var v = VERTEBRA.instantiate()
    spine.add_child(v)
    v.position.y = capacity * -96

    capacity += 1
