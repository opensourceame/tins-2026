class_name SolarSystem
extends Node2D

signal planets_generated

const PLANET = preload("res://solar_system/planet.tscn")

var rotation_speed: int
var cooldown: Timer = null

var MIN_SIZE = 20
var MAX_SIZE = 50

var MIN_DISTANCE = 100
var MAX_DISTANCE = 500

var planets = []

func _ready():
    add_planets()
    queue_redraw()

    rotation_speed = randi_range(2, 10)

func _physics_process(delta: float) -> void:
    rotate(deg_to_rad(delta * rotation_speed))

func _draw():
    draw_sun()

func draw_sun():
    # draw the sun at the centre
    draw_circle(Vector2.ZERO, planets[0].size, Color.YELLOW)

func add_planets():
    var count = randi_range(2, 5)

    for i in range(count):
        var angle = (float(i) / count) * TAU
        angle += randf_range(-0.3, 0.3)

        var distance = randf_range(MIN_DISTANCE, MAX_DISTANCE)

        var planet: Planet = PLANET.instantiate()
        #planet.has_advanced_life = randf() < 0.3
        planet.distance_from_sun = distance
        planet.position = Vector2.RIGHT.rotated(angle) * distance
        planet.size = randi_range(MIN_SIZE, MAX_SIZE)

        add_child(planet)
        planets.append(planet)

    planets_generated.emit()

func start_detection_cooldown():
    print("SOLAR SYSTEM: detection cooldown started for ", name)

    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 10.0
    timer.one_shot = true
    timer.timeout.connect(end_detection_cooldown)
    timer.start()

    cooldown = timer

func end_detection_cooldown():
    print("SOLAR SYSTEM: detection cooldown ended for ", name)

    cooldown.queue_free()
