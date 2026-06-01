class_name Spica
extends StaticBody2D

@onready var game = get_tree().current_scene
@onready var return_area: Area2D = $ReturnArea
@onready var crash_area: Area2D = $CrashArea

var rotation_speed = 10.0
var intelligent_planets = []
var anchors = []
var components = []
var captured_species = []
var capacity_oxygen    = 0
var capacity_water     = 0
var capacity_sulphuric = 0
var capacity_plasma    = 0
var damage = 0
var detector_dish: DetectorDish
var energy_collector: EnergyCollector
var repair_module: RepairModule
var trap_launcher: TrapLauncher

func _ready():
    for a in $Anchors.get_children():
        anchors.append(a)

    SignalBus.intelligence_detected.connect(_on_intelligence_detected)
    SignalBus.habitat_capacity_changed.connect(_on_habitat_capacity_changed)
    SignalBus.repair_module_dismantle.connect(_on_repair_module_dismantle)

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

    if component is EnergyCollector:
        energy_collector = component

    if component is DetectorDish:
        detector_dish = component

    if component is RepairModule:
        repair_module = component

    if component is TrapLauncher:
        trap_launcher = component

#func trap_launcher():
    #return trap_launcher

func _on_intelligence_detected(planet):
    pass

func _on_return_area_entered(trap):
    if not trap is MoonTrap:
        return

    if not trap.is_returning():
        return

    if can_accomodate(trap.species):
        capture_species(trap.species)
        trap.returned()
    else:
        crash_moon_trap(trap)

    SignalBus.moon_trap_returned.emit(trap)

func crash_moon_trap(trap):
    trap.crash_into_spica()
    SoundBus.play("no-" + trap.target_planet.environment + "-capacity")
    game.hud.queue_message("no space for these victims")

    damage += randi_range(3, 5)

    SignalBus.spica_damage.emit()

func can_accomodate(species):
    return get_capacity_for(species.environment) > 0

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
        if c and c is Habitat:
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
        if c and c is Habitat and c.environment == environment:
            return c
    return null

func _on_habitat_capacity_changed(_habitat):
    refresh_capacities()

func capture_species(species):
    var name = species.name()
    if name not in captured_species:
        captured_species.append(species.name())

    print("SPICA: trapped ", species)
    print(captured_species)

    var habitat = get_habitat_for(species.environment)
    habitat.capture(species, randi_range(7, 10))

    SignalBus.species_captured.emit(species)
    SignalBus.habitat_capacity_changed.emit(null)

func _on_body_entered(body):
    if not body is MoonTrap:
        return
    if not body.is_crashing():
        return

    body.queue_free()

    animate_damage(body.global_position - global_position)

    game.hud.queue_message("trap crashed")

func animate_damage(pos: Vector2):
    var damage = load("res://damage.tscn").instantiate()
    add_child(damage)
    damage.position = pos

func _on_repair_module_dismantle():
    repair_module = null
