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
var energy: int = 0

var spawn: Node

const SPAWNER_SCRIPT = preload("res://common/spawner.gd")

func _ready():
    print("GAME: starting")

    center = get_viewport().get_visible_rect().size * 0.5

    SignalBus.intelligence_detected.connect(on_intelligence_detected)
    SignalBus.energy_collected.connect(on_energy_collected)

    spawn = SPAWNER_SCRIPT.new()

    hud.item_queue.add_item("habitat")
    hud.item_queue.add_item("trap_launcher")
    hud.item_queue.add_item("detector_dish")
    hud.item_queue.add_item("habitat")
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
        print("GAME: intelligent planet detected - ", planet)
        intelligent_planets.append(planet)

func on_energy_collected():
    energy += 1
