class_name Game
extends Node2D

@onready var world: CanvasLayer = $World
@onready var hud: CanvasLayer = $HUD
@onready var spica: Spica = $World/Spica

const ZOOM_OUT_SCALE: float = 0.4
const ZOOM_TIME: float = 0.3

var zoomed_out: bool = false
var center: Vector2
var tween: Tween
var intelligent_planets = []
var years_elapsed: float = 0.0
var visitors: int = 0
var energy: int = 1000

var spawn: Node

const SPAWNER_SCRIPT = preload("res://common/spawner.gd")
const ENERGY_REQUIRED = {
    "energy_collector": 100,
    "habitat": 500,
    "trap_launcher": 500,
    "detector_dish": 250,
    "moon_trap": 200,
}

var planet_names = [
    "Zephyra", "Arkanis", "Thalassa", "Vortigern", "Calypsos",
    "Draconis", "Eryndor", "Fenris", "Gorath", "Heliopolis",
    "Iridia", "Jotunheim", "Krynn", "Lyra", "Myrkr",
    "Nyx", "Oblivion", "Pandora", "Quor", "Ryloth"
]

func _ready():
    print("GAME: starting")

    center = get_viewport().get_visible_rect().size * 0.5

    SignalBus.intelligence_detected.connect(on_intelligence_detected)
    SignalBus.energy_collected.connect(on_energy_collected)
    SignalBus.energy_consumed.connect(on_energy_consumed)

    spawn = SPAWNER_SCRIPT.new()

    hud.item_queue.add_item("habitat", { "environment": "air" })
    hud.item_queue.add_item("habitat", { "environment": "water" })
    hud.item_queue.add_item("habitat", { "environment": "sulphuric" })
    hud.item_queue.add_item("trap_launcher")
    hud.item_queue.add_item("detector_dish")
    hud.item_queue.add_item("energy_collector")

    hud.queue_message("welcome")



func _physics_process(delta: float) -> void:
    years_elapsed += 0.01
    hud.get_node("%Years/Label").text = str(round(years_elapsed)) + " years"

    visitors += 1

func _input(event: InputEvent):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_R:
            get_tree().reload_current_scene()
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
        hud.item_queue.add_item("moon_trap", { "target": planet })
        hud.queue_message("intelligent life detected on " + planet.planet_name)

func on_energy_collected():
    if energy < 1000:
        energy += 1

func on_energy_consumed(consumer):
    energy -= ENERGY_REQUIRED[consumer]
