class_name PlaceItem
extends Control

var type
var data = {}

@onready var game: = get_tree().current_scene
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
            "repair_module":
                component = Spawner.repair_module()
            "moon_trap":
                if not game.spica.trap_launcher():
                    game.hud.queue_message("you need a trap launcher")
                    return
                var launcher = game.spica.trap_launcher()
                if not launcher.is_ready():
                    return

                launcher.build(data.get("target"))

        if component:
            spica.add_component(anchor, component)

        queue_free()
        SignalBus.energy_consumed.emit(type)
