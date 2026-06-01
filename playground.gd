extends Node2D
@onready var spica: Spica = $Spica

func _ready():
    SoundBus.play("planet-detected")
    SoundBus.play("alarm-long")

    #spica.animate_damage($Spica/Marker2D.position)
