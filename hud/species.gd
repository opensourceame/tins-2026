extends Control

func _ready():
    SignalBus.species_captured.connect(update_species)

func update_species(trap):
    get_node('Label').text += "\n" + trap.species.name()
