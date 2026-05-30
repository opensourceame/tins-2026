class_name SolarSystem
extends Node2D

signal planets_generated

const PLANET = preload("res://solar_system/planet.tscn")

var rotation_speed = 4.0

var MIN_SIZE = 20
var MAX_SIZE = 50

var MIN_DISTANCE = 100
var MAX_DISTANCE = 500

var planets = []

func _ready():
    add_planets()
    queue_redraw()

func _physics_process(delta: float) -> void:
    rotate(deg_to_rad(delta * rotation_speed))

func _draw():
    # draw the sun at the centre
    draw_circle(Vector2.ZERO, planets[0].size, Color.YELLOW)

func add_planets():
    var count = randi_range(1, 5)

    for i in range(count):
        var angle = (float(i) / count) * TAU
        angle += randf_range(-0.3, 0.3)

        var distance = randf_range(MIN_DISTANCE, MAX_DISTANCE)

        var planet: Planet = PLANET.instantiate()
        planet.has_advanced_life = randf() < 0.1
        planet.distance_from_sun = distance
        planet.position = Vector2.RIGHT.rotated(angle) * distance
        planet.size = randi_range(MIN_SIZE, MAX_SIZE)

        add_child(planet)
        planets.append(planet)

    planets_generated.emit()
