class_name DetectorDish
extends Node2D

signal intelligence_detected

const DETECTOR_DISH = preload("res://detector_dish.tscn")

@onready var detect_ray: RayCast2D = $DetectRay

var intelligent_planets = []
var spica: Spica

func _ready():
    detect_ray.enabled = true
    spica = find_parent("Spica")

func _physics_process(_delta):
    if not detect_ray.enabled:
        return
    if detect_ray.is_colliding():
        var area = detect_ray.get_collider()
        if area.get_parent().has_advanced_life:
            intelligence_detected.emit(area.get_parent())
            SignalBus.intelligence_detected.emit(area.get_parent())

func add_detector_dish(anchor):
    var detector_dish = DETECTOR_DISH.instantiate()
    anchor.add_child(detector_dish)
    detector_dish.intelligence_detected.connect(detected_intelligence)

func detected_intelligence(planet):
    print("SPICA: detected intelligent planet ", planet)
    intelligent_planets.append(planet)
    if spica:
        spica.register_intelligent_planet(planet)
