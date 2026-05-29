class_name Spica
extends Node2D

var rotation_speed = 30.0
var intelligent_planets = []
var anchors = []

func _ready():
    for a in $Anchors.get_children():
        anchors.append(a)

    SignalBus.intelligence_detected.connect(_on_intelligence_detected)

func _physics_process(delta: float) -> void:
    rotate(deg_to_rad(delta * rotation_speed))

func register_intelligent_planet(planet):
    if not planet in intelligent_planets:
        intelligent_planets.append(planet)
        print("Spica: registered intelligent planet ", planet)

func add_component(anchor, component):
    anchor.add_child(component)
    component.rotation = anchor.position.angle() + deg_to_rad(90)

func components():
    var c = []
    for a in anchors:
        if a.get_children()[0]:
            c.append(a)

    return c

func _on_intelligence_detected(planet):
    for a in anchors:
        for child in a.get_children():
            if child is TrapLauncher:
                child.build(planet)
                return
