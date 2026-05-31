class_name Planet
extends Node2D

@onready var game: = get_tree().current_scene
@onready var detect_area: Area2D = $PlanetDetectArea
@onready var orbit_area: Area2D = $OrbitArea

var size: int = 20
var color: Color = Color.RED
var distance_from_sun: int
var has_advanced_life: bool = false
var has_moon_trap: bool = false
var rotation_speed = 60
var planet_name: String
var environment: String = "oxygen"
var species: Species
var is_detected: bool = false

const COLOR_RANGES = {
    30: Color.AQUAMARINE,
    40: Color.CORAL,
    50: Color.BLUE_VIOLET,
    60: Color.ORANGE
}

const BROADCASTING_COMPONENT = preload("res://solar_system/broadcasting_component.tscn")
const PLANET_LABEL = preload("res://solar_system/planet_label.tscn")

const SPECIES_BY_ENV = {
    "oxygen":    [preload("res://species/humans.gd"),    preload("res://species/wibbles.gd")],
    "water":     [preload("res://species/fishoids.gd"),  preload("res://species/guppiez.gd")],
    "sulphuric": [preload("res://species/hegrons.gd"),   preload("res://species/sherzat.gd")],
    "plasma":    [preload("res://species/plasmoids.gd"), preload("res://species/embers.gd")],
}

func _ready():
    calculate_color()
    queue_redraw()

    if has_advanced_life:
        add_intelligent_species()

func detect():
    if is_detected:
        return

    is_detected = true
    add_label()
    add_child(BROADCASTING_COMPONENT.instantiate())

func add_intelligent_species():
    detect_area.monitorable = true
    orbit_area.input_event.connect(_on_detect_area_input)
    orbit_area.body_entered.connect(_on_orbit_entered)
    if game.planet_names.size() > 0:
        planet_name = game.planet_names.pop_back()

    set_random_environment()

func _physics_process(delta: float) -> void:
    rotate(deg_to_rad(delta * rotation_speed))

func _draw():
    draw_circle(Vector2.ZERO, size, color)

func add_label():
    var label = PLANET_LABEL.instantiate()
    label.target = self
    game.get_node("World").call_deferred("add_child", label)

func set_random_environment():
    var environments = ["oxygen", "water", "sulphuric", "plasma"]
    environment = environments.pick_random()
    species = SPECIES_BY_ENV[environment].pick_random().new()

func calculate_color():
    for threshold in COLOR_RANGES:
        if size < threshold:
            color = COLOR_RANGES[threshold] - (Color.WHITE * randf_range(0.0, 0.4))
            break

func _on_detect_area_input(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    if not is_detected:
        return
    if not event is InputEventMouseButton:
        return
    if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
        return

    var launcher = game.spica.trap_launcher

    if not launcher:
        game.hud.queue_message("you need a trap launcher")
        return

    if not launcher.is_ready():
        game.hud.queue_message("trap launcher is busy")
        return

    launcher.build(self)

func _on_orbit_entered(body):
    if not body is MoonTrap:
        return

    if body.is_returning():
        return

    if body.is_orbiting():
        return

    has_moon_trap = true

    body.orbit(self)

func env_icon(env):
    match env:
        "water":
            return "💦"
        "oxygen":
            return "💨"
        "sulphuric":
            return "🌕"
        "plasma":
            return "🌀"
        _:
            return ""
