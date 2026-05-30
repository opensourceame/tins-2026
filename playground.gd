extends Node2D
@onready var spica: Spica = $Spica

func _ready():
    spica.animate_damage($Spica/Marker2D.position)
