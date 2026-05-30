extends Node2D

const STARS = 200

func _ready():
    queue_redraw()

func _draw():
    for i in range(STARS):
        var pos = Vector2(randi_range(-1000, 3000), randi_range(-500, 2000))
        var radius = randi_range(1, 4)

        draw_circle(pos, radius, Color.WHITE)
