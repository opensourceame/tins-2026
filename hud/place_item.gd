class_name PlaceItem
extends Control

enum State { READY, BUSY, DISABLED }
var type
var data = {}
var current_state = State.READY

@onready var game: = get_tree().current_scene
@onready var spica = game.spica
@onready var label: Label = $Label
@onready var energy_label: Label = $EnergyLabel

func _gui_input(event):
    if not current_state == State.READY:
        return

    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if game.energy < Game.ENERGY_REQUIRED[type]:
            game.hud.queue_message("not enough energy")
            return

        var component
        var anchor

        match type:
            "habitat":
                var environment = data.get("environment", "oxygen")

                return create_or_grow_habitat(environment)

            "energy_collector":
                return add_or_upgrade_energy_collector()

            "trap_launcher":
                return add_trap_launcher()
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

func find_free_anchor():
    for a in spica.anchors:
        if not a.has_component():
              return a


func create_or_grow_habitat(environment):
    var habitat: Habitat

    for c in spica.components:
        if c and c is Habitat and c.environment == environment:
            habitat = c
            break

    trigger_progress_bar(10, func():
        if habitat:
            if habitat.capacity > 99:
                game.hud.queue_message("habitat full")
                return
            habitat.grow()
        else:

            var a = find_free_anchor()
            if not a:
                return no_space()

            var new_habitat = Spawner.habitat()
            #var i = 1
            #for c in spica.components:
                #if c is Habitat:
                    #i += 1
            #new_habitat.name = str(i)
            new_habitat.name = environment[0]
            new_habitat.environment = environment
            spica.add_component(a, new_habitat)
            new_habitat.grow()
            habitat = new_habitat

        var item_type = type
        var item_data = data

        SignalBus.energy_consumed.emit(type)
    )

func add_or_upgrade_detector_dish():
    if not spica.detector_dish:
        SignalBus.energy_consumed.emit("detector_dish")

        trigger_progress_bar(5.0, func():
            spica.add_component(find_free_anchor(), Spawner.detector_dish())
            if not spica.detector_dish.can_upgrade():
                queue_free()
        )
        return

    trigger_progress_bar(5.0, func():
        spica.detector_dish.update_detect_distance()
        if not spica.detector_dish.can_upgrade():
            queue_free()
    )

    SignalBus.energy_consumed.emit("detector_dish")


func add_trap_launcher():
    if not spica.trap_launcher:
        SignalBus.energy_consumed.emit("trap_launcher")

        trigger_progress_bar(5.0, func():
            spica.add_component(find_free_anchor(), Spawner.trap_launcher())
            queue_free()
        )
        return


func add_or_upgrade_energy_collector():
    if not spica.energy_collector:

        #if not a:
            #return no_space()

        trigger_progress_bar(5.0, func():
            var a = find_free_anchor()
            spica.add_component(a, Spawner.energy_collector())
        )
    else:
        if not spica.energy_collector.can_upgrade():
            return

        trigger_progress_bar(3.0, func():
            spica.energy_collector.upgrade()
            if not spica.energy_collector.can_upgrade():
                queue_free()
        )

    SignalBus.energy_consumed.emit("energy_collector")


func add_or_upgrade_repair_module():
    if not spica.repair_module:
        trigger_progress_bar(3.0, func():
            spica.add_component(find_free_anchor(), Spawner.repair_module())
        )
    else:
        if not spica.repair_module.can_upgrade():
            return

        trigger_progress_bar(3.0, func():
            spica.repair_module.upgrade()
            if not spica.repair_module.can_upgrade():
                queue_free()
            )

    SignalBus.energy_consumed.emit("repair_module")


func no_space():
    game.hud.queue_message("Spica has no free slots")

func trigger_progress_bar(seconds: float, callback: Callable = Callable()):
    current_state = State.BUSY

    var tween = create_tween()
    tween.tween_property(%ProgressBar, "size", Vector2(200, 10), seconds)
    tween.tween_callback(func():
        %ProgressBar.size.x = 0
        current_state = State.READY
        if callback.is_valid():
            callback.call()
    )
