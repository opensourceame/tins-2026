class_name PlaceItem
extends Control

var type

@onready var label: Label = $Label

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

        var component
        match type:
            "habitat":
                component = Spawner.habitat()
                var i = 1
                for c in spica.components:
                    if c is Habitat:
                        i += 1

                component.name = str(i)

            "trap_launcher":
                component = Spawner.trap_launcher()
            "detector_dish":
                component = Spawner.detector_dish()

        if component:
            spica.add_component(anchor, component)
            queue_free()
