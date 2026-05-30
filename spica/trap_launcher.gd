class_name TrapLauncher
extends Node2D

const TRAP_BUILD_TIME     = 5.0
const TRAP_BUILD_COOLDOWN = 10.0

@onready var build_marker: Marker2D = $BuildMarker

var trap: MoonTrap
var building: bool = false
var build_cooldown = 0.0

func _physics_process(delta: float) -> void:
    if build_cooldown > 0:
        build_cooldown -= delta

func build(target_planet):
    if building or build_cooldown > 0:
        return

    building = true
    trap = Spawner.moon_trap()
    trap.target = target_planet
    build_marker.add_child(trap)
    trap.scale = Vector2.ONE * 0.1
    var tween = create_tween()
    tween.tween_property(trap, "scale", Vector2.ONE, TRAP_BUILD_TIME)
    tween.finished.connect(_on_build_finished)

func _on_build_finished():
    building = false

    trap.reparent(get_tree().current_scene.world)

    var spica = find_parent("Spica") as Spica
    var spica_pos = spica.global_position if spica else trap.global_position
    var direction = (trap.global_position - spica_pos).normalized()
    var distance = randf_range(200, 400)
    var hold_position = spica_pos + direction * distance
    var tween = create_tween()
    tween.tween_property(trap, "global_position", hold_position, 2.0)
    tween.tween_callback(trap.launch)

    build_cooldown = TRAP_BUILD_COOLDOWN
