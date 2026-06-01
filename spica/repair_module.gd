class_name RepairModule
extends StaticBody2D

const MAX_LEVEL = 2

@onready var game = get_tree().current_scene
@onready var repair_timer: Timer = $RepairTimer

var spica: Spica
var level: int = 0
var _repair_interval: float = 5.0

func _ready():
    spica = game.spica

    repair_timer.timeout.connect(repair)
    repair_timer.start()

    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 30.0
    timer.timeout.connect(remove_module)
    timer.start()

func repair():
    if spica.damage < 1:
        return

    spica.damage -= level + 1
    SignalBus.spica_damage.emit()

    if spica.damage == 0:
        SoundBus.play("spica-repaired")

func can_upgrade() -> bool:
    return level < MAX_LEVEL

func upgrade() -> bool:
    if not can_upgrade():
        return false

    level += 1
    _repair_interval = lerpf(5.0, 1.0, float(level) / MAX_LEVEL)
    repair_timer.wait_time = _repair_interval
    repair_timer.start()
    return true

func remove_module():
    SignalBus.repair_module_dismantle.emit()
    queue_free()
