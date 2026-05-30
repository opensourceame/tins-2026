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

        if game.energy < Game.ENERGY_REQUIRED[type]:
            game.hud.queue_message("not enough energy")
            return

        var component
        var anchor

        match type:
            "habitat":
                var target_env = data.get("environment", "oxygen")
                var habitat: Habitat

                for c in spica.components:
                    if c is Habitat and c.environment == target_env:
                        habitat = c
                        break

                if habitat:
                    if habitat.capacity > 9:
                        game.hud.queue_message("habitat full")
                        return
                    habitat.grow()
                else:
                    for a in spica.anchors:
                        if not a.has_component():
                            anchor = a
                            break

                    if not anchor:
                        game.hud.queue_message("no space for habitat")
                        return

                    var new_habitat = Spawner.habitat()
                    var i = 1
                    for c in spica.components:
                        if c is Habitat:
                            i += 1
                    new_habitat.name = str(i)
                    new_habitat.environment = target_env
                    spica.add_component(anchor, new_habitat)
                    new_habitat.grow()
                    habitat = new_habitat

                var item_type = type
                var item_data = data
                var timer = Timer.new()
                game.add_child(timer)
                timer.one_shot = true
                timer.wait_time = 10.0
                timer.timeout.connect(func():
                    if habitat.capacity < 10:
                        game.hud.item_queue.add_item(item_type, item_data)
                )
                timer.start()
            "energy_collector":
                for a in spica.anchors:
                    if not a.has_component():
                        anchor = a
                        break
                if not anchor:
                    return
                component = Spawner.energy_collector()
            "trap_launcher":
                for a in spica.anchors:
                    if not a.has_component():
                        anchor = a
                        break
                if not anchor:
                    return
                component = Spawner.trap_launcher()
            "detector_dish":
                for a in spica.anchors:
                    if not a.has_component():
                        anchor = a
                        break
                if not anchor:
                    return
                component = Spawner.detector_dish()
            "repair_module":
                for a in spica.anchors:
                    if not a.has_component():
                        anchor = a
                        break
                if not anchor:
                    return
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
