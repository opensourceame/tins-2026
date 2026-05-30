class_name ItemQueue
extends Control

const PLACE_ITEM = preload("res://hud/place_item.tscn")

var items = []

func _ready():
    pass

func add_item(type, data = {}):
    print("ITEM QUEUE: adding ", type, " data: ", data)
    var item = PLACE_ITEM.instantiate()
    $VBoxContainer.add_child(item)
    items.append(item)
    var env = data.get("environment")
    item.type = type
    item.data = data
    item.label.text = type.replace("_", "\n") + ("\n" + env if env else "")

    if Game.ENERGY_REQUIRED[type]:
        item.energy_label.text = "⚡️ " + str(Game.ENERGY_REQUIRED[type])

    #$VBoxContainer.add_child(HSeparator.new())
    item.add_child(HSeparator.new())
