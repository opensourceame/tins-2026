extends Node

const SETTINGS_PATH := "user://settings.cfg"

var start_visitor_interest: int = 3
var max_energy: int = 3000
var start_damage: int = 0
var intelligent_planets_count: int = 3
var energy_collection_rate: float = 0.15
var skip_tutorial: bool = false
var music_enabled: bool = true


func _ready():
    load_settings()


func save():
    var config = ConfigFile.new()

    config.set_value("gameplay", "start_visitor_interest", start_visitor_interest)
    config.set_value("gameplay", "max_energy", max_energy)
    config.set_value("gameplay", "start_damage", start_damage)
    config.set_value("gameplay", "intelligent_planets_count", intelligent_planets_count)
    config.set_value("gameplay", "energy_collection_rate", energy_collection_rate)
    config.set_value("gameplay", "skip_tutorial", skip_tutorial)
    config.set_value("audio", "music_enabled", music_enabled)

    config.save(SETTINGS_PATH)


func load_settings():
    var config = ConfigFile.new()
    if config.load(SETTINGS_PATH) != OK:
        return

    start_visitor_interest = config.get_value("gameplay", "start_visitor_interest", start_visitor_interest)
    max_energy = config.get_value("gameplay", "max_energy", max_energy)
    start_damage = config.get_value("gameplay", "start_damage", start_damage)
    intelligent_planets_count = config.get_value("gameplay", "intelligent_planets_count", intelligent_planets_count)
    energy_collection_rate = config.get_value("gameplay", "energy_collection_rate", energy_collection_rate)
    skip_tutorial = config.get_value("gameplay", "skip_tutorial", skip_tutorial)
    music_enabled = config.get_value("audio", "music_enabled", music_enabled)
