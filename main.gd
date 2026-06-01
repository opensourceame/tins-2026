class_name Game
extends Node2D

enum SaveStrategy { JSON, SIMPLE }

@export var save_strategy: SaveStrategy = SaveStrategy.SIMPLE

@onready var world: CanvasLayer = $World
@onready var hud: CanvasLayer = $HUD
@onready var spica: Spica = $World/Spica
@onready var visitor_interest_timer: Timer = $VisitorInterestTimer
@onready var overlays: CanvasLayer = $Overlays
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

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
var intelligent_planets_count = 3

var spawn: Node

const SPAWNER_SCRIPT = preload("res://common/spawner.gd")
const ENERGY_REQUIRED = {
    "energy_collector": 100,
    "habitat":          300,
    "trap_launcher":    500,
    "detector_dish":    250,
    "moon_trap":        200,
    "repair_module":    300,
}

func _ready():
    Config.reset()
    print("GAME: starting")

    visitor_interest = SettingsManager.start_visitor_interest
    MAX_ENERGY = SettingsManager.max_energy
    energy = MAX_ENERGY
    spica.damage = SettingsManager.start_damage
    SignalBus.spica_damage.emit()
    skip_tutorial = SettingsManager.skip_tutorial
    intelligent_planets_count = SettingsManager.intelligent_planets_count

    center = get_viewport().get_visible_rect().size * 0.5

    SignalBus.intelligence_detected.connect(on_intelligence_detected)
    SignalBus.energy_collected.connect(on_energy_collected)
    SignalBus.energy_consumed.connect(on_energy_consumed)
    SignalBus.moon_trap_returned.connect(on_moon_trap_returned)
    SignalBus.spica_damage.connect(on_spica_damage)
    SignalBus.species_captured.connect(on_species_captured)
    SignalBus.habitat_overcrowded.connect(on_habitat_overcrowded)

    SignalBus.habitat_overcrowded.connect(func(_h): SoundBus.play("alarm-long"))

    spawn = SPAWNER_SCRIPT.new()

    hud.permanent_items.add_item("habitat", { "environment": "oxygen" })
    hud.permanent_items.add_item("habitat", { "environment": "water" })
    hud.permanent_items.add_item("habitat", { "environment": "methane" })
    hud.permanent_items.add_item("habitat", { "environment": "plasma" })
    hud.permanent_items.add_item("trap_launcher")
    hud.permanent_items.add_item("detector_dish")
    hud.permanent_items.add_item("energy_collector")
    hud.permanent_items.add_item("repair_module")

    if not skip_tutorial:
        hud.queue_message("Welcome to the Spica Zoo")
        hud.queue_message("Keep your visitors happy and the zoo open")

    run_pre_start_checks()

    visitor_interest_timer.timeout.connect(lose_interest)
    visitor_interest_timer.start()

    if SettingsManager.music_enabled:
        audio_player.play()

func _physics_process(delta: float) -> void:
    years_elapsed += 0.01
    hud.get_node("%Years/Label").text = str(round(years_elapsed)) + " years"

    visitors += visitor_interest / 100.0
    energy   -= spica.damage * delta / 2

    check_game_over()

func _input(event: InputEvent):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_R:
            get_tree().reload_current_scene()
        if event.keycode == KEY_G:
            game_over("user")
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
                var fish = Fishoids.new()
                habitat.capture(fish, 11)
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
        if event.keycode == KEY_S:
            if _save_game():
                hud.queue_message("Game saved")
        if event.keycode == KEY_L and not get_node_or_null("QuickLoad"):
            var quick_load = preload("res://screens/quick_load.tscn").instantiate()
            quick_load.save_manager = _save_manager()
            overlays.add_child(quick_load)
        if event.keycode == KEY_P and not get_node_or_null("PauseOverlay"):
            var pause = preload("res://screens/pause.tscn").instantiate()
            add_child(pause)

func run_pre_start_checks():
    var eligible = []
    var count = 0
    for planet in get_planets():
        if planet.has_advanced_life:
            count += 1
        else:
            eligible.append(planet)

    while count < intelligent_planets_count and eligible.size() > 0:
        var planet = eligible.pick_random()
        eligible.erase(planet)
        planet.has_advanced_life = true
        planet.add_intelligent_species()
        count += 1

func get_planets():
    var planets = []
    for child in world.get_children():
        if child is SolarSystem:
            planets.append_array(child.planets)
    return planets

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
        game_over("energy")

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
    pass

func on_species_captured(species):
    if visitor_interest > 9:
        return

    var count = 0
    for s in spica.captured_species:
        if s == species.name():
            count += 1

    if count == 1:
        visitor_interest += 2
    else:
        visitor_interest += 1

func on_habitat_overcrowded(habitat):
    hud.queue_message("the " + habitat.environment + " habitat is overcrowded!")
    SoundBus.play("habitat-overcrowded")

func lose_interest():
    visitor_interest -= 1

    if visitor_interest < 3:
        hud.queue_message("Customers are losing interest in your zoo!")

func check_game_over():
    if visitor_interest < 0:
        game_over("interest")
    if energy < 0:
        game_over("energy")

func game_over(reason):
    GameOver.reason = reason
    get_tree().change_scene_to_file("res://screens/game_over.tscn")



func _save_game() -> bool:
    match save_strategy:
        SaveStrategy.JSON:
            return SaveManager.quick_save()
        SaveStrategy.SIMPLE:
            return SimpleSaveManager.quick_save()
    return false


func _save_manager():
    match save_strategy:
        SaveStrategy.JSON:
            return SaveManager
        SaveStrategy.SIMPLE:
            return SimpleSaveManager
    return SaveManager
