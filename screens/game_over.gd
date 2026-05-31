class_name GameOver
extends Control

static var reason: String = ""

@onready var reason_label: Label = %ReasonLabel
@onready var try_again_button: Button = %TryAgainButton
@onready var settings_button: Button = %SettingsButton

const REASONS = {
    "energy":   "The Spica ran out of energy",
    "interest": "Visitors lost interest",
    "user":     "Stopped by user"
}
func _ready():
    reason_label.text = REASONS[reason]

    try_again_button.pressed.connect(_on_try_again_pressed)
    settings_button.pressed.connect(_on_settings_pressed)


func _on_try_again_pressed():
    get_tree().change_scene_to_file("res://main.tscn")


func _on_settings_pressed():
    get_tree().change_scene_to_file("res://screens/settings.tscn")
