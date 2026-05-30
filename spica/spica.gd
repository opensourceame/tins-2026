class_name Spica
extends StaticBody2D

@onready var game = get_tree().current_scene
@onready var return_area: Area2D = $ReturnArea
@onready var crash_area: Area2D = $CrashArea

var rotation_speed = 30.0
var intelligent_planets = []
var anchors = []
var components = []
var captured_species = []
var capacity = 0

func _ready():
    for a in $Anchors.get_children():
        anchors.append(a)

    SignalBus.intelligence_detected.connect(_on_intelligence_detected)

    crash_area.body_entered.connect(_on_body_entered)
    return_area.body_entered.connect(_on_return_area_entered)

func _physics_process(delta: float) -> void:
    rotate(deg_to_rad(delta * rotation_speed))

func register_intelligent_planet(planet):
    if not planet in intelligent_planets:
        intelligent_planets.append(planet)
        print("Spica: registered intelligent planet ", planet)

func add_component(anchor, component):
    anchor.attach_component(component)
    components.append(component)
    component.rotation = anchor.position.angle() + deg_to_rad(90)

func get_components():
    var c = []
    for a in anchors:
        if a.component:
            c.append(a.component)

    return c

func _on_intelligence_detected(planet):
    if planet.has_moon_trap:
        return

    for c in components:
        if c is TrapLauncher:
            c.build(planet)
            return

func _on_return_area_entered(trap):
    if not trap is MoonTrap:
        return

    if not trap.is_returning():
        return

    if can_accomodate(trap):
        capture_species(trap)
    else:
        crash_moon_trap(trap)

func crash_moon_trap(trap):
    trap.crash_into_spica()
    game.hud.queue_message("no space for these victims")

func can_accomodate(trap):
    return get_capacity() > 0

func get_capacity():
    var total = 0
    for c in components:
        if c is Habitat:
            total += c.capacity

    return total



func capture_species(trap):
    print("SPICA: trapped ", trap.species)
    captured_species.append(trap.species)
    trap.returned()

    SignalBus.species_captured.emit(trap)

func _on_body_entered(body):
    if body is MoonTrap and body.is_crashing():
        body.queue_free()

    animate_damage(body.global_position - global_position)

    game.hud.queue_message("trap crashed")

func animate_damage(pos: Vector2):
    var damage = load("res://damage.tscn").instantiate()
    add_child(damage)
    damage.position = pos
