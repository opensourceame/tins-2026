class_name DetectorDish
extends Node2D

signal intelligence_detected

const DETECTOR_DISH = preload("res://spica/detector_dish.tscn")

const MAX_DISTANCE = 3500

@onready var detect_ray: RayCast2D = $DetectRay
@onready var detect_distance_timer: Timer = $DetectDistanceTimer

var intelligent_planets = []
var spica: Spica
var detect_distance: int = 500
var colliding: bool = false

func _ready():
    detect_ray.enabled = true
    spica = find_parent("Spica")

    queue_redraw()

    #detect_distance_timer.start()
    #detect_distance_timer.timeout.connect(update_detect_distance)

func _draw():
    if colliding:
        draw_line(Vector2.ZERO, Vector2(0, -detect_distance), Color(0.812, 0.702, 0.129, 0.694) , 30, true)
    else:
        draw_line(Vector2.ZERO, Vector2(0, -detect_distance), Color(0.812, 0.702, 0.129, 0.396) , 4, true)

func _physics_process(_delta):
    if not detect_ray.enabled:
        return
    if detect_ray.is_colliding():
        var area = detect_ray.get_collider()
        if area.get_parent().has_advanced_life:
            intelligence_detected.emit(area.get_parent())
            SignalBus.intelligence_detected.emit(area.get_parent())
            SoundBus.play("planet-detected")
            colliding = true
    else:
        colliding = false

    queue_redraw()

func update_detect_distance():
    if detect_distance >= MAX_DISTANCE:
        return

    detect_distance += 500
    detect_ray.target_position.y = -detect_distance

    queue_redraw()

func add_detector_dish(anchor):
    var detector_dish = DETECTOR_DISH.instantiate()
    anchor.add_child(detector_dish)
    detector_dish.intelligence_detected.connect(detected_intelligence)

func detected_intelligence(planet):
    if planet.has_moon_trap:
        return

    print("SPICA: detected new intelligent planet ", planet)
    intelligent_planets.append(planet)
    if spica:
        spica.register_intelligent_planet(planet)
