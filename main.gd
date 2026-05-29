class_name Game
extends Node2D

@onready var world: CanvasLayer = $World

const ZOOM_OUT: float = 0.1

var zoomed_out: bool = false
var center: Vector2
var tween: Tween

func _ready():
    print("GAME: starting")

    center = get_viewport().get_visible_rect().size * 0.5

func _input(event: InputEvent):
    if event is InputEventKey and event.keycode == KEY_Z and event.pressed != zoomed_out:
        zoomed_out = event.pressed
        if tween and tween.is_valid():
            tween.kill()
        tween = create_tween()
        tween.set_parallel(true)
        var s = ZOOM_OUT if zoomed_out else 1.0
        tween.tween_property(world, "scale", Vector2(s, s), 0.5)
        tween.tween_property(world, "offset", center * (1.0 - s), 0.5)
