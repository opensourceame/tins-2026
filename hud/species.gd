extends Control

var displayed_species = {}

func _ready():
    SignalBus.species_captured.connect(update_species)

func update_species(species_or_trap):
    var species = species_or_trap.species if "species" in species_or_trap else species_or_trap
    var name = species.name()
    if displayed_species.has(name):
        return
    displayed_species[name] = true
    var label = get_node('Label')
    var line = _icon_for(species) + " " + name
    if label.text == "":
        label.text = line
    else:
        label.text += "\n" + line

func _icon_for(species):
    match species.environment:
        "water":
            return "💦"
        "sulphuric":
            return "🌕"
        _:
            return "💨"
