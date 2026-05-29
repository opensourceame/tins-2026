class_name MoonTrap
extends CharacterBody2D

enum State { IDLE, LAUNCHED }

var target
var current_direction: Vector2

func _physics_process(delta: float) -> void:
    if target:
        current_direction = (target.global_position - global_position).normalize()
        velocity = current_direction * 100

func launch(toward_target):
    target = toward_target
