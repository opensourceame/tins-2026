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
    "sulphuric": [preload("res://species/bzzaps.gd")],
    "plasma":    [preload("res://species/plasmoids.gd"), preload("res://species/embers.gd")],
}

func _ready():
    calculate_color()
    queue_redraw()

    if has_advanced_life:
        add_intelligent_species()

func add_intelligent_species():
    detect_area.monitorable = true
    orbit_area.body_entered.connect(_on_orbit_entered)
    if game.planet_names.size() > 0:
        planet_name = game.planet_names.pop_back()

    set_random_environment()
    add_label()

    add_child(BROADCASTING_COMPONENT.instantiate())

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
            color = COLOR_RANGES[threshold]
            break

func _on_orbit_entered(body):
    if not body is MoonTrap:
        return

    if body.is_returning():
        return

    if body.is_orbiting():
        return

    has_moon_trap = true

    body.orbit(self)
