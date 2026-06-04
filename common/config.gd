extends Node

var planet_names = []


func _ready():
    load_planet_names()


func load_planet_names():
    var file = FileAccess.open("res://config/planets.txt", FileAccess.READ)
    if not file:
        push_error("Could not open config/planets.txt")
        return
    while not file.eof_reached():
        var line = file.get_line().strip_edges()
        if not line.is_empty():
            planet_names.append(line)
    if planet_names.is_empty():
        push_error("config/planets.txt is empty")


func reset():
    planet_names.clear()
    load_planet_names()


func get_random_planet_name() -> String:
    if planet_names.is_empty():
        return ""
    var idx = randi() % planet_names.size()
    return planet_names.pop_at(idx)
