class_name PlanetLabel
extends Node2D

const OFFSET = Vector2(0, -100)

var target: Planet

@onready var label: Label = $Control/Label
@onready var control: Control = $Control

func _ready():
    var prefix = target.env_icon(target.environment)
    $Control/Label.text = prefix + " " + target.planet_name

func _physics_process(delta: float) -> void:
    global_position = target.global_position + OFFSET

    if get_parent().scale.x < 1.0:
        control.scale = Vector2.ONE * (1 / get_parent().scale.x)
