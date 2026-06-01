class_name Start
extends Control

@onready var easy_button:   Button = %EasyButton
@onready var medium_button: Button = %MediumButton
@onready var hard_button:   Button = %HardButton
@onready var custom_button: Button = %CustomButton

const PRESETS = {
    "easy": {
        "start_visitor_interest": 10,
        "max_energy": 3000,
        "start_damage": 0,
        "intelligent_planets_count": 10,
        "energy_collection_rate": 0.25,
        "skip_tutorial": false,
    },
    "medium": {
        "start_visitor_interest": 7,
        "max_energy": 2000,
        "start_damage": 0,
        "intelligent_planets_count": 8,
        "energy_collection_rate": 0.2,
        "skip_tutorial": false,
    },
    "hard": {
        "start_visitor_interest": 5,
        "max_energy": 1000,
        "start_damage": 0,
        "intelligent_planets_count": 5,
        "energy_collection_rate": 0.15,
        "skip_tutorial": false,
    },
}

func _ready():
    easy_button.pressed.connect(_on_easy_pressed)
    medium_button.pressed.connect(_on_medium_pressed)
    hard_button.pressed.connect(_on_hard_pressed)
    custom_button.pressed.connect(_on_custom_pressed)

func _on_easy_pressed():
    _apply_preset("easy")

func _on_medium_pressed():
    _apply_preset("medium")

func _on_hard_pressed():
    _apply_preset("hard")

func _apply_preset(name: String):
    var p = PRESETS[name]
    SettingsManager.start_visitor_interest = p.start_visitor_interest
    SettingsManager.max_energy = p.max_energy
    SettingsManager.start_damage = p.start_damage
    SettingsManager.intelligent_planets_count = p.intelligent_planets_count
    SettingsManager.energy_collection_rate = p.energy_collection_rate
    SettingsManager.skip_tutorial = p.skip_tutorial
    SettingsManager.save()
    get_tree().change_scene_to_file("res://main.tscn")

func _on_custom_pressed():
    get_tree().change_scene_to_file("res://screens/settings.tscn")
