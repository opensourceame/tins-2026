class_name MoonTrap
extends CharacterBody2D

enum State { IDLE, LAUNCHED, ORBITING, RETURNING, RETURNED }

@onready var moon: Node2D = $Moon

var target
var current_direction: Vector2
var current_state = State.IDLE
var orbit_timer: Timer
var species

func _physics_process(delta: float) -> void:
    if not target:
        return

    if current_state == State.LAUNCHED:
        current_direction = (target.global_position - global_position).normalized()

        velocity = current_direction * 400

        moon.scale *= 0.999

        move_and_slide()

    if current_state == State.RETURNING:
        current_direction = (target.global_position - global_position).normalized()

        velocity = current_direction * 200

        moon.scale *= 1.001

        move_and_slide()


func launch():
    current_state = State.LAUNCHED

func orbit(planet):
    if current_state == State.ORBITING:
        return

    current_state = State.ORBITING
    species = planet.species

    reparent(planet)

    var tween = create_tween()
    tween.tween_property(moon, "scale", Vector2(0.1, 0.1), 2.0)

    orbit_timer = Timer.new()
    add_child(orbit_timer)
    orbit_timer.wait_time = randi_range(3, 5)
    orbit_timer.timeout.connect(return_home)
    orbit_timer.start()

func return_home():
    SignalBus.moon_trap_returning.emit(self)

    target = get_tree().current_scene.spica

    reparent(get_tree().current_scene.world)

    current_state = State.RETURNING

func is_returning():
    return current_state == State.RETURNING

func returned():
    current_state = State.RETURNED

    queue_free()
