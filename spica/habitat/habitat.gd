class_name Habitat
extends Node2D

enum State { AVAILABLE, OVERCROWDED }
const VERTEBRA = preload("res://spica/habitat/vertebra.tscn")

@onready var game: Game = get_tree().current_scene
@onready var label: Label = $Label
@onready var spine: Node2D = $Spine
@onready var color_rect: ColorRect = $ColorRect

var capacity = 0
var captured = 0
var vertebrae = 0

var environment: String = "oxygen":
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
        "plasma":
            modulate = Color(1.0, 0.3, 0.6)
        _:
            modulate = Color.WHITE

func capture(species, amount):
    capacity -= amount

    check_overcrowding()

func has_space():
    return capacity > 0

func grow() -> bool:
    if capacity > 99:
        return false


    var v = VERTEBRA.instantiate()
    spine.add_child(v)
    v.scale.y = 0.1
    v.position.y = vertebrae * -96

    vertebrae += 1

    var tween = create_tween()
    tween.tween_property(v, "scale.y", 1.0, 2.0)

    capacity += 10
    SignalBus.habitat_capacity_changed.emit(self)

    check_overcrowding()

    return true

func check_overcrowding():
    if not is_over_capacity():
        return

    spine.modulate = Color.RED

    game.hud.queue_message("Overcrowding in " + environment + " habitat")

    for v in spine.get_children():
        v.rotate(deg_to_rad(randi_range(5, -5)))

    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 4.0
    timer.one_shot = true
    timer.timeout.connect(check_habitat_collapse)
    timer.start()



func is_over_capacity():
    return capacity < 0

func check_habitat_collapse():
    if not is_over_capacity():
        return

    var rigid_body = RigidBody2D.new()
    game.world.add_child(rigid_body)
    rigid_body.global_position = global_position
    rigid_body.gravity_scale = 0

    var away = (global_position - game.spica.global_position).normalized()
    rigid_body.linear_velocity = away * 200
    rigid_body.angular_velocity = randf_range(-3.0, 3.0)

    var anchor = get_parent().get_parent()
    if anchor is SpicaAnchor:
        anchor.component = null

    game.spica.components.erase(self)
    game.spica.refresh_capacities()
    SignalBus.habitat_capacity_changed.emit(self)

    reparent(rigid_body)
