class_name GameOver
extends Control

@onready var try_again_button: Button = %TryAgainButton


func _ready():
    try_again_button.pressed.connect(_on_try_again_pressed)


func _on_try_again_pressed():
    get_tree().change_scene_to_file("res://main.tscn")
