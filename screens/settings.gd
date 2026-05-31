class_name Settings
extends Control

@onready var visitor_interest_spinbox: SpinBox = %VisitorInterestSpinBox
@onready var max_energy_spinbox: SpinBox = %MaxEnergySpinBox
@onready var initial_damage_spinbox: SpinBox = %InitialDamageSpinBox
@onready var skip_tutorial_checkbox: CheckBox = %SkipTutorialCheckBox
@onready var start_button: Button = %StartButton


func _ready():
    visitor_interest_spinbox.value = SettingsManager.start_visitor_interest
    max_energy_spinbox.value = SettingsManager.max_energy
    initial_damage_spinbox.value = SettingsManager.start_damage
    skip_tutorial_checkbox.button_pressed = SettingsManager.skip_tutorial

    start_button.pressed.connect(_on_start_pressed)


func _on_start_pressed():
    SettingsManager.start_visitor_interest = visitor_interest_spinbox.value
    SettingsManager.max_energy = max_energy_spinbox.value
    SettingsManager.start_damage = initial_damage_spinbox.value
    SettingsManager.skip_tutorial = skip_tutorial_checkbox.button_pressed
    SettingsManager.save()
    get_tree().change_scene_to_file("res://main.tscn")
