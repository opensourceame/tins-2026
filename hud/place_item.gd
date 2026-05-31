class_name PlaceItem
extends Control

enum State { ENABLED, DISABLED }
var type
var data = {}
var current_state = State.ENABLED

@onready var game: = get_tree().current_scene
@onready var spica = game.spica
@onready var label: Label = $Label
@onready var energy_label: Label = $EnergyLabel

func _gui_input(event):
    if current_state == State.DISABLED:
        return

    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
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
                    if habitat.capacity > 99:
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

                SignalBus.energy_consumed.emit(type)

                disable_me()

                var timer = Timer.new()
                timer.wait_time = 10.0
                timer.timeout.connect(enable_me)
                add_child(timer)
                timer.start()
                return

            "energy_collector":
                return add_or_upgrade_energy_collector()

            "trap_launcher":
                for a in spica.anchors:
                    if not a.has_component():
                        anchor = a
                        break
                if not anchor:
                    return
                component = Spawner.trap_launcher()
            "detector_dish":
                return add_or_upgrade_detector_dish()
            "repair_module":
                return add_or_upgrade_repair_module()
            "moon_trap":
                if not game.spica.trap_launcher():
                    game.hud.queue_message("you need a trap launcher")
                    return
                var launcher = game.spica.trap_launcher()
                if not launcher.is_ready():
                    return

                launcher.build(data.get("target"))

                SignalBus.energy_consumed.emit("moon_trap")

        if component:
            spica.add_component(anchor, component)

        queue_free()

func disable_me():
    modulate = Color.BLACK
    current_state = State.DISABLED

func enable_me():
    modulate = Color.WHITE
    current_state = State.ENABLED

func find_free_anchor():
    for a in spica.anchors:
        if not a.has_component():
              return a

func add_or_upgrade_detector_dish():
    if not spica.detector_dish:
        var a = find_free_anchor()
        if not a:
            return no_space()

        return spica.add_component(a, Spawner.detector_dish())
    else:
        spica.detector_dish.update_detect_distance()

    SignalBus.energy_consumed.emit("detector_dish")

    if not spica.detector_dish.can_upgrade():
        queue_free()

func add_or_upgrade_energy_collector():
    if not spica.energy_collector:
        var a = find_free_anchor()
        if not a:
            return no_space()

        spica.add_component(a, Spawner.energy_collector())
    else:
        if not spica.energy_collector.upgrade():
            return

    SignalBus.energy_consumed.emit("energy_collector")

    if not spica.energy_collector.can_upgrade():
        queue_free()

func add_or_upgrade_repair_module():
    if not spica.repair_module:
        var a = find_free_anchor()
        if not a:
            return no_space()

        spica.add_component(a, Spawner.repair_module())
    else:
        if not spica.repair_module.upgrade():
            return

    SignalBus.energy_consumed.emit("repair_module")

    if not spica.repair_module.can_upgrade():
        queue_free()

func no_space():
    game.hud.queue_message("Spica has no free slots")
