class_name PlaceItem
extends Control

var type
var data = {}

@onready var label: Label = $Label
@onready var energy_label: Label = $EnergyLabel

func _gui_input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var game = get_tree().current_scene
        var spica = game.spica

        var anchor
        for a in spica.anchors:
            if not a.has_component():
                anchor = a
                break

        if not anchor:
            return

        if game.energy < Game.ENERGY_REQUIRED[type]:
            game.hud.queue_message("not enough energy")
            return

        var component
        match type:
            "habitat":
                component = Spawner.habitat()
                var i = 1
                for c in spica.components:
                    if c is Habitat:
                        i += 1

                component.name = str(i)
                component.environment = data.get("environment", "air")
            "energy_collector":
                component = Spawner.energy_collector()
            "trap_launcher":
                component = Spawner.trap_launcher()
            "detector_dish":
                component = Spawner.detector_dish()

        SignalBus.energy_consumed.emit(type)

        if component:
            spica.add_component(anchor, component)
            queue_free()
