class_name HUD
extends CanvasLayer

@onready var game = get_tree().current_scene
@onready var item_queue: ItemQueue = %ItemQueue
@onready var permanent_items: ItemQueue = %PermanentItems
@onready var message: Control = $Message
@onready var capacity_label: Label = %CapacityLabel
@onready var damage_label: Label = %DamageLabel

var message_queue = []
var message_being_displayed = false

func _ready():
    SignalBus.moon_trap_returning.connect(alert_trap_returning)
    SignalBus.habitat_capacity_changed.connect(capacity_changed)
    SignalBus.spica_damage.connect(spica_damage)
    SignalBus.species_captured.connect(update_species_captured)

    update_species_captured()

func _physics_process(delta: float) -> void:
    if message_queue.size() > 0 and not message_being_displayed:
        show_next_message()

    $RightBar/VBoxContainer/Visitors/Label.text = str(int(game.visitors)) + ' visitors'
    %EnergyLabel.text = "⚡️ " + str(int(game.energy))

    update_visitor_interest()


func queue_message(text):
    message_queue.append(text)

func show_next_message():
    message_being_displayed = true
    var text = message_queue.pop_front()
    $Message/Label.text = text
    message.show()

    var timer = Timer.new()
    add_child(timer)
    timer.one_shot  = true
    timer.wait_time = 4.0
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

func capacity_changed(_habitat):
    var s = game.spica
    %CapacityLabel.text = "Capacities: 💨" + str(s.capacity_oxygen) + "  💦: " + str(s.capacity_water) + "  🌕: " + str(s.capacity_sulphuric) + "  🌀: " + str(s.capacity_plasma)

func spica_damage():
    %DamageLabel.text = "⚠️ " + str(game.spica.damage)

func update_species_captured(species = null):
    if not game.spica:
        return

    for node in %SpeciesVBoxContainer.get_children():
        if node.name in game.spica.captured_species:
            node.modulate = Color.GREEN
        else:
            node.modulate = Color(0.313, 0.313, 0.313, 1.0)

func update_visitor_interest():
    var i = 0
    for node in %InterestProgressBar.get_children():
        if game.visitor_interest > i:
            node.modulate = Color.GREEN
        else:
            node.modulate = Color(0.037, 0.204, 0.038, 1.0)
        i += 1
