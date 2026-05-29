class_name Planet
extends Node2D

@onready var detect_area: Area2D = $DetectArea

var size: int = 20
var color: Color = Color.RED
var distance_from_sun: int
var has_advanced_life: bool = false

const COLOR_RANGES = {
    30: Color.AQUAMARINE,
    40: Color.CORAL,
    50: Color.BLUE_VIOLET,
    60: Color.ORANGE
}

func _ready():
    calculate_color()
    queue_redraw()

    if has_advanced_life:
        detect_area.monitorable = true

func _draw():
    draw_circle(Vector2.ZERO, size, color)

func calculate_color():
    for threshold in COLOR_RANGES:
        if size < threshold:
            color = COLOR_RANGES[threshold]
            break
