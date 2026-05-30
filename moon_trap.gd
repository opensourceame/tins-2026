class_name MoonTrap
extends CharacterBody2D

enum State { IDLE, LAUNCHED, ORBITING, RETURNING, RETURNED, CRASHING }

@onready var moon: Node2D = $Moon

var target
var current_direction: Vector2
var current_state = State.IDLE
var orbit_timer: Timer
var species

func _physics_process(delta: float) -> void:
    if not target:
        return

    if is_moving():
        current_direction = (target.global_position - global_position).normalized()
        velocity = current_direction * speed()
        move_and_slide()

    moon.scale *= scale_change()

func is_moving():
    return current_state == State.LAUNCHED or current_state == State.RETURNING

func scale_change():
    match current_state:
        State.LAUNCHED:
            return 0.999
        State.RETURNING:
            return 1.011
        _:
            return 1.0

func speed():
    match current_state:
        State.IDLE:
            return 0
        State.LAUNCHED:
            return 400
        State.RETURNING:
            return 200

func launch():
    current_state = State.LAUNCHED

func orbit(planet):
    if current_state == State.ORBITING:
        return

    current_state = State.ORBITING
    species = planet.species

    call_deferred("reparent", planet)

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

    var tween = create_tween()
    tween.tween_property(moon, "scale", Vector2(0.5, 0.5), 2.0)

func crash_into_spica():
    current_state = State.CRASHING


func is_returning():
    return current_state == State.RETURNING

func returned():
    current_state = State.RETURNED

    queue_free()
