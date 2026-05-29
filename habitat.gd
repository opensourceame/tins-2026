class_name Habitat
extends Node2D

@onready var label: Label = $Label

var capacity = 5

func _ready():
    label.text = name

func capture(species, amount):
    capacity -= amount

func has_space():
    capacity > 0
