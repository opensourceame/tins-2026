class_name HUD
extends CanvasLayer

@onready var item_queue: ItemQueue = $ItemQueue
@onready var message: Control = $Message

func _ready():
    SignalBus.intelligence_detected.connect(intelligence_alert)
    SignalBus.moon_trap_returning.connect(alert_trap_returning)

func show_message(text):
    $Message/Label.text = text
    message.show()

    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 3.0
    timer.timeout.connect(hide_message)
    timer.start()

func hide_message():
    message.hide()

func alert_trap_returning(trap):
    show_message("moon trap is returning with " + trap.species.name())

func intelligence_alert(planet):
    if planet.has_moon_trap:
        return

    show_message("intelligent life detected on planet XYZ123")
