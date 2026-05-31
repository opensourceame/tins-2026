class_name Settings
extends Control

@onready var visitor_interest_spinbox: SpinBox = %VisitorInterestSpinBox
@onready var max_energy_spinbox: SpinBox = %MaxEnergySpinBox
@onready var start_button: Button = %StartButton


func _ready():
    visitor_interest_spinbox.value = SettingsManager.start_visitor_interest
    max_energy_spinbox.value = SettingsManager.max_energy

    start_button.pressed.connect(_on_start_pressed)


func _on_start_pressed():
    SettingsManager.start_visitor_interest = visitor_interest_spinbox.value
    SettingsManager.max_energy = max_energy_spinbox.value
    get_tree().change_scene_to_file("res://main.tscn")
