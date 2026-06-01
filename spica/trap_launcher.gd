class_name TrapLauncher
extends Node2D

const TRAP_BUILD_TIME     = 5.0
const TRAP_BUILD_COOLDOWN = 1.0

@onready var launcher: Marker2D = $Launcher

var trap: MoonTrap
var building: bool = false
var build_cooldown = 0.0

func _physics_process(delta: float) -> void:
    if build_cooldown > 0:
        build_cooldown -= delta

func launch(target_planet):
    trap.target = target_planet
    trap.launch()

    trap = null

func build():
    if building or build_cooldown > 0:
        return

    building = true
    SoundBus.play("build-moon")
    trap = Spawner.moon_trap()

    launcher.add_child(trap)

    trap.scale = Vector2.ONE * 0.1
    var tween = create_tween()
    tween.tween_property(trap, "scale", Vector2.ONE, TRAP_BUILD_TIME)
    tween.finished.connect(_on_build_finished)

func _on_build_finished():
    SoundBus.play("moon-ready")
    building = false


func is_ready():
    return building == false
