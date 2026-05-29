class_name MoonTrap
extends CharacterBody2D

enum State { IDLE, LAUNCHED, ORBITING }

@onready var moon: Node2D = $Moon

var target
var current_direction: Vector2
var current_state = State.IDLE

func _physics_process(delta: float) -> void:
    if target and current_state == State.LAUNCHED:
        current_direction = (target.global_position - global_position).normalized()

        velocity = current_direction * 400

        moon.scale *= 0.999

        move_and_slide()

func launch():
    current_state = State.LAUNCHED

func orbit(planet):
    current_state = State.ORBITING

    reparent(planet)

    var tween = create_tween()
    tween.tween_property(moon, "scale", Vector2(0.1, 0.1), 2.0)
