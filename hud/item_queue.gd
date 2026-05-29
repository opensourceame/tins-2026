class_name ItemQueue
extends Control

var items = []

func _ready():
    pass

func add_item(type):
    var item = Spawner.call(type)
    $VBoxContainer.add_child(item)
    items.append(item)
