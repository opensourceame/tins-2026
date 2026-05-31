class_name Game
extends Node2D

@onready var world: CanvasLayer = $World
@onready var hud: CanvasLayer = $HUD
@onready var spica: Spica = $World/Spica
@onready var visitor_interest_timer: Timer = $VisitorInterestTimer

const ZOOM_OUT_SCALE: float = 0.4
const ZOOM_TIME: float = 0.3
static var MAX_ENERGY: int = 3000

var skip_tutorial: bool = false
var zoomed_out: bool = false
var center: Vector2
var tween: Tween
var intelligent_planets = []
var years_elapsed: float = 0.0
var visitors: float = 0.0

@export var visitor_interest: int = 3
@export var energy: float = MAX_ENERGY

var spawn: Node

const SPAWNER_SCRIPT = preload("res://common/spawner.gd")
const ENERGY_REQUIRED = {
    "energy_collector": 100,
    "habitat": 500,
    "trap_launcher": 500,
    "detector_dish": 250,
    "moon_trap": 200,
    "repair_module": 300,
}

var planet_names = [
    "Zephyra", "Arkanis", "Thalassa", "Vortigern", "Calypsos",
    "Draconis", "Eryndor", "Fenris", "Gorath", "Heliopolis",
    "Iridia", "Jotunheim", "Krynn", "Lyra", "Myrkr",
    "Nyx", "Oblivion", "Pandora", "Quor", "Ryloth"
]

func _ready():
    print("GAME: starting")

    visitor_interest = SettingsManager.start_visitor_interest
    MAX_ENERGY = SettingsManager.max_energy
    energy = MAX_ENERGY
    spica.damage = SettingsManager.start_damage
    SignalBus.spica_damage.emit()

    center = get_viewport().get_visible_rect().size * 0.5

    SignalBus.intelligence_detected.connect(on_intelligence_detected)
    SignalBus.energy_collected.connect(on_energy_collected)
    SignalBus.energy_consumed.connect(on_energy_consumed)
    SignalBus.moon_trap_returned.connect(on_moon_trap_returned)
    SignalBus.spica_damage.connect(on_spica_damage)
    SignalBus.species_captured.connect(on_species_captured)

    spawn = SPAWNER_SCRIPT.new()

    hud.permanent_items.add_item("habitat", { "environment": "oxygen" })
    hud.permanent_items.add_item("habitat", { "environment": "water" })
    hud.permanent_items.add_item("habitat", { "environment": "sulphuric" })
    hud.permanent_items.add_item("habitat", { "environment": "plasma" })
    hud.permanent_items.add_item("trap_launcher")
    hud.permanent_items.add_item("detector_dish")
    hud.permanent_items.add_item("energy_collector")

    if not skip_tutorial:
        hud.queue_message("Welcome to the Spica Zoo")
        hud.queue_message("Keep your visitors happy and the zoo open")


    visitor_interest_timer.timeout.connect(lose_interest)
    visitor_interest_timer.start()

    #game_over()

func _physics_process(delta: float) -> void:
    years_elapsed += 0.01
    hud.get_node("%Years/Label").text = str(round(years_elapsed)) + " years"

    visitors += visitor_interest / 100.0
    energy   -= spica.damage * delta

    check_game_over()

func _input(event: InputEvent):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_R:
            get_tree().reload_current_scene()
        if event.keycode == KEY_G:
            game_over()
        if event.keycode == KEY_1:
            Engine.time_scale = 1.0
        if event.keycode == KEY_2:
            Engine.time_scale = 2.0
        if event.keycode == KEY_3:
            Engine.time_scale = 5.0
        if event.keycode == KEY_W:
            var habitat = spica.get_habitat_for("water")
            if habitat:
                habitat.grow()
                var count = habitat.capacity + 1
                for i in count:
                    var fish = Fishoids.new()
                    spica.captured_species.append(fish)
                    habitat.capture(fish, 11)
                    SignalBus.species_captured.emit(fish)
                spica.refresh_capacities()
                SignalBus.habitat_capacity_changed.emit(null)
            else:
                hud.queue_message("no water habitat")
        if event.keycode == KEY_Z:
            zoomed_out = not zoomed_out
            if tween and tween.is_valid():
                tween.kill()
            tween = create_tween()
            tween.set_parallel(true)
            var s = ZOOM_OUT_SCALE if zoomed_out else 1.0
            tween.tween_property(world, "scale", Vector2(s, s), ZOOM_TIME)
            tween.tween_property(world, "offset", center * (1.0 - s), ZOOM_TIME)
            tween.tween_callback(toggle_hud)


func toggle_hud():
    if zoomed_out:
        hud.hide()
    else:
        hud.show()


func on_intelligence_detected(planet):
    if not planet in intelligent_planets:
        print("GAME: intelligent planet detected - ", planet.planet_name)
        intelligent_planets.append(planet)
        queue_trap_item(planet)
        hud.queue_message("intelligent life detected on " + planet.planet_name)

func on_energy_collected():
    if energy < MAX_ENERGY:
        energy += 1

func on_energy_consumed(consumer):
    energy -= ENERGY_REQUIRED[consumer]

    if energy < 1:
        game_over()

func on_moon_trap_returned(trap):
    var timer = Timer.new()
    add_child(timer)
    timer.one_shot = true
    timer.wait_time = 5.0
    timer.timeout.connect(queue_trap_item.bind(trap.target_planet))
    timer.start()

func queue_trap_item(planet):
    hud.item_queue.add_item("moon_trap", { "target": planet })

func on_spica_damage():
    for c in spica.components:
        if c is RepairModule:
            return
    hud.item_queue.add_item("repair_module")

func on_species_captured(trap):
    if visitor_interest > 9:
        return

    visitor_interest += 1

func lose_interest():
    visitor_interest -= 1

    if visitor_interest < 3:
        hud.queue_message("Customers are losing interest in your zoo!")

func check_game_over():
    if visitor_interest < 0:
        game_over()
    if energy < 0:
        game_over()

func game_over():
    get_tree().change_scene_to_file("res://screens/game_over.tscn")
