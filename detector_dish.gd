class_name DetectorDish
extends Node2D

signal intelligence_detected

const DETECTOR_DISH = preload("res://detector_dish.tscn")

@onready var detect_ray: RayCast2D = $DetectRay

var intelligent_planets = []

func _ready():
    detect_ray.body_entered(_on_body_entered)

func _on_body_entered(body):
    if body is Planet:
        intelligence_detected.emit(body)

func add_detector_dish(anchor):
    var detector_dish = DETECTOR_DISH.instantiate()
    anchor.add_child(detector_dish)

    detector_dish.intelligence_detected.connect(detected_intelligence)

func detected_intelligence(planet):
    intelligent_planets.append(planet)
