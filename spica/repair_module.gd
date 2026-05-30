class_name RepairModule
extends StaticBody2D

@onready var game = get_tree().current_scene
@onready var repair_timer: Timer = $RepairTimer

const REPAIR_SPEED = 1
const ENERGY_DRAIN = 2

var spica: Spica

func _ready():
    spica = game.spica

    repair_timer.timeout.connect(repair)
    repair_timer.start()

func repair():
    if spica.damage < 1:
        return

    spica.damage -= 1
    SignalBus.spica_damage.emit()
