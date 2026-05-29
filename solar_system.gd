class_name SolarSystem
extends Node2D

signal planets_generated

var rotation_speed = 4.0

var MIN_SIZE = 20
var MAX_SIZE = 50

var MIN_DISTANCE = 100
var MAX_DISTANCE = 500

var planets = []

func _ready():
    add_sun()
    add_planets()
    planets_generated.emit()
    queue_redraw()

func _physics_process(delta: float) -> void:
    rotate(deg_to_rad(delta * rotation_speed))

func _draw():
    for planet in planets:
        draw_circle(planet.pos, planet.size, planet.color)

func add_sun():
    planets.append({
        "pos": Vector2.ZERO,
        "size": randi_range(40, 70),
        "color": Color.YELLOW,
    })

func add_planets():
    var count = randi_range(1, 5)

    for i in range(count):
        var angle = (float(i) / count) * TAU
        angle += randf_range(-0.3, 0.3)

        var distance = randf_range(MIN_DISTANCE, MAX_DISTANCE)


        planets.append({
            "pos": Vector2.RIGHT.rotated(angle) * distance,
            "size": randi_range(MIN_SIZE, MAX_SIZE),
            "color": Color.RED,
        })
