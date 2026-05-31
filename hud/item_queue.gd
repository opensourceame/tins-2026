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
    item.label.text = type.replace("_", "\n")

    if item.find_parent("PermanentItems"):
        item.get_node("ColorRect").color = Color(0.299, 0.044, 0.044, 1.0)

    if env:
        item.label.text += " " + env_icon(env)

    if type == "moon_trap":
        var t = data.get("target")
        item.label.text = "🌖 " +t.planet_name + " " + env_icon(t.environment)

    if Game.ENERGY_REQUIRED[type]:
        item.energy_label.text = "⚡️ " + str(Game.ENERGY_REQUIRED[type])

    #$VBoxContainer.add_child(HSeparator.new())
    item.add_child(HSeparator.new())

func env_icon(env):
    match env:
        "water":
            return "💦"
        "oxygen":
            return "💨"
        "sulphuric":
            return "🌕"
        "plasma":
            return "🌀"
        _:
            return ""
