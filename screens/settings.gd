class_name Settings
extends Control

@onready var visitor_interest_spinbox: SpinBox = %VisitorInterestSpinBox
@onready var max_energy_spinbox: SpinBox = %MaxEnergySpinBox
@onready var initial_damage_spinbox: SpinBox = %InitialDamageSpinBox
@onready var intelligent_planets_spinbox: SpinBox = %IntelligentPlanetsSpinBox
@onready var energy_collection_rate_slider: HSlider = %EnergyCollectionRateSlider
@onready var skip_tutorial_checkbox: CheckBox = %SkipTutorialCheckBox
@onready var start_button: Button = %StartButton


func _ready():
    visitor_interest_spinbox.value = SettingsManager.start_visitor_interest
    max_energy_spinbox.value = SettingsManager.max_energy
    initial_damage_spinbox.value = SettingsManager.start_damage
    intelligent_planets_spinbox.value = SettingsManager.intelligent_planets_count
    energy_collection_rate_slider.value = SettingsManager.energy_collection_rate
    skip_tutorial_checkbox.button_pressed = SettingsManager.skip_tutorial

    start_button.pressed.connect(_on_start_pressed)


func _on_start_pressed():
    SettingsManager.start_visitor_interest = visitor_interest_spinbox.value
    SettingsManager.max_energy = max_energy_spinbox.value
    SettingsManager.start_damage = initial_damage_spinbox.value
    SettingsManager.intelligent_planets_count = intelligent_planets_spinbox.value
    SettingsManager.energy_collection_rate = energy_collection_rate_slider.value
    SettingsManager.skip_tutorial = skip_tutorial_checkbox.button_pressed
    SettingsManager.save()
    get_tree().change_scene_to_file("res://main.tscn")
