class_name MoonTrap
extends CharacterBody2D

enum State { IDLE, LAUNCHED, ORBITING, RETURNING, RETURNED, CRASHING }

const MIN_MOON_SCALE = 0.1

#@onready var game: Game = get_tree().current_scene
@onready var moon: Node2D = $Moon
@onready var particle_trail: GPUParticles2D = $ParticleTrail
@onready var launcher: Marker2D = $Launcher

var target_planet
var target:
    set(value):
        target = value
        if target and is_inside_tree():
            target_distance = global_position.distance_to(target.global_position)
var target_distance: float
var current_direction: Vector2
var distance_to_target: float
var current_state = State.IDLE
var orbit_timer: Timer
var species

func _physics_process(delta: float) -> void:
    particle_trail.emitting = current_state in [State.LAUNCHED, State.RETURNING, State.CRASHING]

    if not target:
        return

    if is_moving():
        current_direction = (target.global_position - global_position).normalized()
        velocity = current_direction * speed()
        move_and_slide()

    moon.scale *= scale_change()

func is_moving():
    match current_state:
        State.IDLE, State.ORBITING, State.RETURNED:
            return false
        _:
            return true

func scale_change():
    match current_state:
        State.LAUNCHED:
            return 1.0
        State.RETURNING:
            return 1.0
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
        State.CRASHING:
            return 50

func launch():
    distance_to_target = global_position.distance_to(target.global_position)

    detach_from_spica()

func travel_to_target():
    current_state = State.LAUNCHED

    var travel_time = distance_to_target / speed()
    var tween = create_tween()
    tween.tween_property(moon, "scale", Vector2(0.1, 0.1), travel_time)

func detach_from_spica():
    var game = get_tree().current_scene
    reparent(game.world)

    var spica         = game.spica
    var spica_pos     = spica.global_position if spica else global_position
    var direction     = (global_position - spica_pos).normalized()
    var distance      = randf_range(200, 400)
    var hold_position = spica_pos + direction * distance

    var tween = create_tween()
    tween.tween_property(self, "global_position", hold_position, 2.0)
    tween.tween_callback(travel_to_target)

func orbit(planet):
    if current_state == State.ORBITING:
        return

    current_state = State.ORBITING
    species = planet.species

    call_deferred("reparent", planet)

    target_planet = planet
    orbit_timer = Timer.new()
    add_child(orbit_timer)
    orbit_timer.wait_time = randi_range(6, 9)
    orbit_timer.timeout.connect(return_home)
    orbit_timer.start()

func return_home():
    SignalBus.moon_trap_returning.emit(self)

    target = get_tree().current_scene.spica

    reparent(get_tree().current_scene.world)

    current_state = State.RETURNING

    var travel_time = distance_to_target / speed()
    var tween = create_tween()
    tween.tween_property(moon, "scale", Vector2(0.5, 0.5), travel_time)

func crash_into_spica():
    current_state = State.CRASHING
    modulate = Color.RED

func is_returning():
    return current_state == State.RETURNING

func is_crashing():
    return current_state == State.CRASHING

func is_orbiting():
    return current_state == State.ORBITING

func returned():
    current_state = State.RETURNED

    queue_free()
