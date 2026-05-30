class_name HUD
extends CanvasLayer

@onready var game = get_tree().current_scene
@onready var item_queue: ItemQueue = $ItemQueue
@onready var message: Control = $Message
@onready var capacity_label: Label = %CapacityLabel

var message_queue = []
var message_being_displayed = false

func _ready():
    SignalBus.intelligence_detected.connect(intelligence_alert)
    SignalBus.moon_trap_returning.connect(alert_trap_returning)
    SignalBus.habitat_capacity_changed.connect(capacity_changed)

func _physics_process(delta: float) -> void:
    if message_queue.size() > 0 and not message_being_displayed:
        show_next_message()

    $Control/VBoxContainer/Visitors/Label.text = str(game.visitors) + ' visitors'
    %EnergyLabel.text = "energy: " + str(game.energy)

func queue_message(text):
    message_queue.append(text)

func show_next_message():
    message_being_displayed = true
    var text = message_queue.pop_front()
    $Message/Label.text = text
    message.show()

    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 3.0
    timer.timeout.connect(hide_message)
    timer.start()

func hide_message():
    message.hide()

    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 1.0
    timer.timeout.connect(message_display_ready)
    timer.start()

func message_display_ready():
    message_being_displayed = false

func alert_trap_returning(trap):
    queue_message("moon trap is returning with " + trap.species.name())

func intelligence_alert(planet):
    if planet.has_moon_trap:
        return

    queue_message("intelligent life detected on planet XYZ123")

func capacity_changed(habitat):
    %CapacityLabel.text = "capacity: " + str(game.spica.get_capacity())
