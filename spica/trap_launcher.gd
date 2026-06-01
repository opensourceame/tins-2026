class_name TrapLauncher
extends Node2D

const TRAP_BUILD_TIME     = 5.0

@onready var launcher: Marker2D = $Launcher

var trap: MoonTrap
var building: bool = false

func launch(target_planet):
    if not trap:
        return

    SoundBus.play("launching")

    trap.target_planet = target_planet
    trap.launch()

    trap = null

func build():
    if building or trap:
        return

    building = true
    SoundBus.play("build-moon")

    trap = Spawner.moon_trap()
    trap.scale = Vector2.ONE * 0.1

    launcher.add_child(trap)

    var tween = create_tween()
    tween.tween_property(trap, "scale", Vector2.ONE, TRAP_BUILD_TIME)
    tween.finished.connect(_on_build_finished)

func _on_build_finished():
    SoundBus.play("moon-ready")
    building = false

func is_ready_to_launch():
    return trap

func is_ready_to_build():
    return not building and not trap
