class_name Spica
extends StaticBody2D

@onready var game = get_tree().current_scene
@onready var return_area: Area2D = $ReturnArea
@onready var crash_area: Area2D = $CrashArea

var rotation_speed = 15.0
var intelligent_planets = []
var anchors = []
var components = []
var captured_species = []
var capacity_oxygen    = 0
var capacity_water     = 0
var capacity_sulphuric = 0
var capacity_plasma    = 0
var damage = 0

func _ready():
    for a in $Anchors.get_children():
        anchors.append(a)

    SignalBus.intelligence_detected.connect(_on_intelligence_detected)
    SignalBus.habitat_capacity_changed.connect(_on_habitat_capacity_changed)

    crash_area.body_entered.connect(_on_body_entered)
    return_area.body_entered.connect(_on_return_area_entered)

    SignalBus.spica_damage.emit(0)

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

func trap_launcher():
    for c in components:
        if c is TrapLauncher:
            return c

func _on_intelligence_detected(planet):
    pass

func _on_return_area_entered(trap):
    if not trap is MoonTrap:
        return

    if not trap.is_returning():
        return

    if can_accomodate(trap):
        capture_species(trap)
    else:
        crash_moon_trap(trap)

    SignalBus.moon_trap_returned.emit(trap)

func crash_moon_trap(trap):
    trap.crash_into_spica()
    game.hud.queue_message("no space for these victims")

    damage += randi_range(3, 5)

    SignalBus.spica_damage.emit()

func can_accomodate(trap):
    return get_capacity_for(trap.species.environment) > 0

func get_capacity_for(env: String) -> int:
    match env:
        "water":
            return capacity_water
        "sulphuric":
            return capacity_sulphuric
        "plasma":
            return capacity_plasma
        "oxygen":
            return capacity_oxygen
        _:
            return 0

func refresh_capacities():
    capacity_oxygen = 0
    capacity_water = 0
    capacity_sulphuric = 0
    capacity_plasma = 0
    for c in components:
        if c is Habitat:
            var available = c.capacity - c.captured
            match c.environment:
                "water":
                    capacity_water += available
                "sulphuric":
                    capacity_sulphuric += available
                "plasma":
                    capacity_plasma += available
                "oxygen":
                    capacity_oxygen += available

func get_habitat_for(environment: String) -> Habitat:
    for c in components:
        if c is Habitat and c.environment == environment:
            return c
    return null

func _on_habitat_capacity_changed(_habitat):
    refresh_capacities()

func capture_species(trap):
    print("SPICA: trapped ", trap.species)
    captured_species.append(trap.species)
    for c in components:
        if c is Habitat and c.environment == trap.species.environment and c.has_space():
            c.capture(trap.species, randi_range(7, 10))
            break
    trap.returned()

    SignalBus.species_captured.emit(trap)
    SignalBus.habitat_capacity_changed.emit(null)

func _on_body_entered(body):
    if body is MoonTrap and body.is_crashing():
        body.queue_free()

    animate_damage(body.global_position - global_position)

    game.hud.queue_message("trap crashed")

func animate_damage(pos: Vector2):
    var damage = load("res://damage.tscn").instantiate()
    add_child(damage)
    damage.position = pos
