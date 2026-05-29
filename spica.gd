class_name Spica
extends Node2D

var rotation_speed = 10.0 # degrees per second

func _ready():
    pass

func _physics_process(delta: float) -> void:
    rotate(deg_to_rad(delta * rotation_speed))
