extends Node2D
@onready var spica: Spica = $Spica

func _ready():
    SoundBus.play("no-oxygen-capacity")
    #SoundBus.play("planet-detected", 1.0, 1.0, false)
    #SoundBus.play("alarm-long")
    #SoundBus.play("overcrowded")
    #SoundBus.play("xxx", 1.0, 1.0, true)
    #SoundBus.play("xxx", 1.0, 1.0, false)

    spica.animate_damage($Spica/Marker2D.position)
