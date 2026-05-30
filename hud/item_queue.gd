class_name ItemQueue
extends Control

const PLACE_ITEM = preload("res://hud/place_item.tscn")

var items = []

func _ready():
    pass

func add_item(type):
    print("ITEM QUEUE: adding ", type)
    var item = PLACE_ITEM.instantiate()
    $VBoxContainer.add_child(item)
    items.append(item)
    item.label.text = type.replace("_", "\n")
    item.type = type
