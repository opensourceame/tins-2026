extends Node

func quick_save() -> bool:
    var game = get_tree().current_scene as Game
    if not game:
        return false

    var data = _collect_all_data(game)
    var timestamp = Time.get_unix_time_from_system()
    data["timestamp"] = timestamp

    var dir = DirAccess.open("user://")
    if not dir.dir_exists("quick_saves"):
        dir.make_dir("quick_saves")

    var file_path = "user://quick_saves/save_%d.json" % timestamp
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))
    file.close()

    _cleanup_old_saves()
    return true


func get_recent_saves() -> Array:
    var dir = DirAccess.open("user://quick_saves")
    if not dir:
        return []

    var saves = []
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".json"):
            var file = FileAccess.open("user://quick_saves/" + file_name, FileAccess.READ)
            if file:
                var content = file.get_as_text()
                if content:
                    var json = JSON.parse_string(content)
                    if json is Dictionary:
                        saves.append({
                            "filename": file_name,
                            "path": "user://quick_saves/" + file_name,
                            "timestamp": json.get("timestamp", 0),
                            "data": json,
                        })
        file_name = dir.get_next()

    saves.sort_custom(func(a, b): return a.timestamp > b.timestamp)
    return saves.slice(0, 5)


func quick_load(data: Dictionary):
    get_tree().reload_current_scene()
    await get_tree().process_frame
    await get_tree().process_frame

    var game = get_tree().current_scene as Game
    if not game:
        return

    _apply_all_data(game, data)
    game.hud.capacity_changed(null)
    SignalBus.spica_damage.emit()
    game.add_child(preload("res://screens/pause.tscn").instantiate())


func _cleanup_old_saves():
    var saves = get_recent_saves()
    var dir = DirAccess.open("user://quick_saves")
    if not dir:
        return

    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".json"):
            var keep = false
            for s in saves:
                if s["filename"] == file_name:
                    keep = true
                    break
            if not keep:
                dir.remove(file_name)
        file_name = dir.get_next()


func _collect_all_data(game: Game) -> Dictionary:
    return {
        "game": _collect_game_data(game),
        "spica": _collect_spica_data(game.spica),
        "solar_systems": _collect_solar_systems(game),
        "moon_traps": _collect_moon_traps(game),
        "item_queue": _collect_item_queue(game),
    }


func _collect_game_data(game: Game) -> Dictionary:
    return {
        "energy": game.energy,
        "visitor_interest": game.visitor_interest,
        "visitors": game.visitors,
        "years_elapsed": game.years_elapsed,
        "zoomed_out": game.zoomed_out,
        "planet_names": game.planet_names.duplicate(),
    }


func _collect_spica_data(spica: Spica) -> Dictionary:
    var data = {
        "damage": spica.damage,
        "captured_species": _collect_species_list(spica.captured_species),
        "components": [],
    }

    for component in spica.components:
        var comp_data = _collect_component_data(spica, component)
        if comp_data:
            data["components"].append(comp_data)

    return data


func _collect_species_list(species_list: Array) -> Array:
    var result = []
    for s in species_list:
        if is_instance_valid(s):
            result.append(_collect_species(s))
    return result


func _collect_species(s: Species) -> Dictionary:
    return {
        "script_path": s.get_script().resource_path,
        "environment": s.environment,
        "ability_longevity": s.ability_longevity,
        "greed": s.greed,
    }


func _collect_component_data(spica: Spica, component: Node) -> Dictionary:
    var data = {
        "script_path": component.get_script().resource_path,
        "anchor_index": -1,
    }

    for i in range(spica.anchors.size()):
        var anchor = spica.anchors[i]
        if anchor.component == component:
            data["anchor_index"] = i
            break

    if component is Habitat:
        data["habitat"] = {
            "capacity": component.capacity,
            "captured": component.captured,
            "vertebrae": component.vertebrae,
            "environment": component.environment,
            "current_state": component.current_state,
        }

    return data


func _collect_solar_systems(game: Game) -> Array:
    var systems = []
    var world = game.world

    for child in world.get_children():
        if child is SolarSystem:
            var planets = []
            for p in child.planets:
                if not is_instance_valid(p):
                    continue
                planets.append({
                    "planet_name": p.planet_name,
                    "environment": p.environment,
                    "size": p.size,
                    "distance_from_sun": p.distance_from_sun,
                    "has_advanced_life": p.has_advanced_life,
                    "has_moon_trap": p.has_moon_trap,
                    "position_x": p.position.x,
                    "position_y": p.position.y,
                    "species_script_path": p.species.get_script().resource_path if p.species else "",
                })

            systems.append({
                "position_x": child.position.x,
                "position_y": child.position.y,
                "rotation": child.rotation,
                "planets": planets,
            })

    return systems


func _collect_moon_traps(game: Game) -> Array:
    var traps = []
    var world = game.world

    for child in world.get_children():
        if child is MoonTrap:
            var t = _collect_moon_trap(child)
            if t:
                traps.append(t)

    for child in world.get_children():
        if child is SolarSystem:
            for p in child.planets:
                if is_instance_valid(p):
                    for c in p.get_children():
                        if c is MoonTrap:
                            var t = _collect_moon_trap(c)
                            if t:
                                traps.append(t)

    return traps


func _collect_moon_trap(trap: MoonTrap) -> Dictionary:
    var t = {
        "state": trap.current_state,
        "position_x": trap.global_position.x,
        "position_y": trap.global_position.y,
        "moon_scale_x": trap.moon.scale.x,
        "moon_scale_y": trap.moon.scale.y,
    }

    if trap.species:
        t["species"] = _collect_species(trap.species)

    if trap.target_planet and is_instance_valid(trap.target_planet):
        t["target_planet_name"] = trap.target_planet.planet_name
        t["target_planet_environment"] = trap.target_planet.environment

    return t


func _collect_item_queue(game: Game) -> Array:
    var items = []
    for item in game.hud.item_queue.items:
        if not is_instance_valid(item):
            continue
        var item_data = {
            "type": item.type,
            "data": item.data.duplicate(),
        }
        items.append(item_data)
    return items


func _apply_all_data(game: Game, data: Dictionary):
    _clear_solar_system_planets(game)
    _clear_spica_components(game.spica)
    _clear_item_queue(game)

    _apply_game_data(game, data.get("game", {}))
    _apply_spica_data(game.spica, data.get("spica", {}))
    _apply_solar_systems(game, data.get("solar_systems", []))
    _apply_moon_traps(game, data.get("moon_traps", []))
    _apply_item_queue(game, data.get("item_queue", []))

    game.intelligent_planets.clear()
    for child in game.world.get_children():
        if child is SolarSystem:
            for p in child.planets:
                if p.has_advanced_life:
                    game.intelligent_planets.append(p)


func _clear_solar_system_planets(game: Game):
    for child in game.world.get_children():
        if child is PlanetLabel:
            child.queue_free()
        if child is SolarSystem:
            for p in child.get_children():
                if p is Planet:
                    p.queue_free()
            child.planets.clear()


func _clear_spica_components(spica: Spica):
    for component in spica.components:
        if is_instance_valid(component):
            component.queue_free()
    spica.components.clear()
    spica.captured_species.clear()
    spica.damage = 0


func _clear_item_queue(game: Game):
    for item in game.hud.item_queue.items:
        if is_instance_valid(item):
            item.queue_free()
    game.hud.item_queue.items.clear()


func _apply_game_data(game: Game, data: Dictionary):
    if data.is_empty():
        return

    game.energy = data.get("energy", Game.MAX_ENERGY)
    game.visitor_interest = data.get("visitor_interest", 3)
    game.visitors = data.get("visitors", 0.0)
    game.years_elapsed = data.get("years_elapsed", 0.0)
    game.planet_names = data.get("planet_names", game.planet_names)


func _apply_spica_data(spica: Spica, data: Dictionary):
    if data.is_empty():
        return

    spica.damage = data.get("damage", 0)

    for s_data in data.get("captured_species", []):
        var species = _restore_species(s_data)
        if species:
            spica.captured_species.append(species)

    for comp_data in data.get("components", []):
        _restore_component(spica, comp_data)


func _restore_species(data: Dictionary) -> Species:
    if data.is_empty():
        return null

    var script_path = data.get("script_path", "")
    if script_path.is_empty():
        return null

    var script = load(script_path)
    if not script:
        return null

    var s: Species = script.new()
    s.environment = data.get("environment", "oxygen")
    s.ability_longevity = data.get("ability_longevity", false)
    s.greed = data.get("greed", 0)
    return s


func _restore_component(spica: Spica, data: Dictionary):
    var script_path = data.get("script_path", "")
    if script_path.is_empty() or not ResourceLoader.exists(script_path):
        return

    var scene_path = _component_scene_from_script(script_path)
    if scene_path.is_empty():
        return

    var component = load(scene_path).instantiate()

    var anchor_idx = data.get("anchor_index", -1)
    if anchor_idx >= 0 and anchor_idx < spica.anchors.size():
        var anchor = spica.anchors[anchor_idx]
        spica.add_component(anchor, component)

    if component is Habitat:
        var h_data = data.get("habitat", {})
        component.capacity = h_data.get("capacity", component.capacity)
        component.captured = h_data.get("captured", component.captured)
        component.vertebrae = h_data.get("vertebrae", component.vertebrae)
        component.environment = h_data.get("environment", component.environment)

        for i in range(component.vertebrae):
            var v = preload("res://spica/habitat/vertebra.tscn").instantiate()
            component.spine.add_child(v)
            v.position.y = i * -96

        component.check_overcrowding()


func _component_scene_from_script(script_path: String) -> String:
    match script_path:
        "res://spica/habitat/habitat.gd":
            return "res://spica/habitat/habitat.tscn"
        "res://spica/trap_launcher.gd":
            return "res://spica/trap_launcher.tscn"
        "res://spica/detector_dish.gd":
            return "res://spica/detector_dish.tscn"
        "res://spica/energy_collector.gd":
            return "res://spica/energy_collector.tscn"
        "res://spica/repair_module.gd":
            return "res://spica/repair_module.tscn"
        _:
            return ""


func _apply_solar_systems(game: Game, systems_data: Array):
    var solar_systems = []
    for child in game.world.get_children():
        if child is SolarSystem:
            solar_systems.append(child)

    for i in range(min(systems_data.size(), solar_systems.size())):
        var ss = solar_systems[i]
        var ss_data = systems_data[i]

        ss.position.x = ss_data.get("position_x", ss.position.x)
        ss.position.y = ss_data.get("position_y", ss.position.y)
        ss.rotation = ss_data.get("rotation", ss.rotation)

        for p_data in ss_data.get("planets", []):
            var planet = preload("res://solar_system/planet.tscn").instantiate()

            planet.size = p_data.get("size", 20)
            planet.distance_from_sun = p_data.get("distance_from_sun", 100)
            planet.environment = p_data.get("environment", "oxygen")
            planet.has_moon_trap = p_data.get("has_moon_trap", false)
            planet.position.x = p_data.get("position_x", 0.0)
            planet.position.y = p_data.get("position_y", 0.0)
            planet.planet_name = p_data.get("planet_name", "")

            var species_script_path = p_data.get("species_script_path", "")
            if not species_script_path.is_empty():
                var script = load(species_script_path)
                if script:
                    planet.species = script.new()
            else:
                planet.species = Species.new()

            var had_advanced_life = p_data.get("has_advanced_life", false)
            planet.has_advanced_life = false

            ss.add_child(planet)
            ss.planets.append(planet)

            planet.calculate_color()

            if had_advanced_life:
                planet.has_advanced_life = true
                planet.get_node("PlanetDetectArea").monitorable = true
                planet.get_node("OrbitArea").body_entered.connect(planet._on_orbit_entered)

                var bc = preload("res://solar_system/broadcasting_component.tscn").instantiate()
                planet.add_child(bc)

                planet.add_label()


func _apply_moon_traps(game: Game, traps_data: Array):
    for t_data in traps_data:
        var trap = preload("res://moon_trap.tscn").instantiate()
        game.world.add_child(trap)

        trap.global_position.x = t_data.get("position_x", 0.0)
        trap.global_position.y = t_data.get("position_y", 0.0)

        trap.moon.scale.x = t_data.get("moon_scale_x", 1.0)
        trap.moon.scale.y = t_data.get("moon_scale_y", 1.0)

        var species_data = t_data.get("species", {})
        if not species_data.is_empty():
            trap.species = _restore_species(species_data)

        var target_name = t_data.get("target_planet_name", "")
        var target_env = t_data.get("target_planet_environment", "")
        if not target_name.is_empty():
            for child in game.world.get_children():
                if child is SolarSystem:
                    for p in child.planets:
                        if is_instance_valid(p) and p.planet_name == target_name and p.environment == target_env:
                            trap.target_planet = p
                            trap.target = p
                            break

        var state = t_data.get("state", MoonTrap.State.IDLE)
        if state == MoonTrap.State.ORBITING:
            if trap.target_planet:
                trap.reparent(trap.target_planet)
                trap.current_state = MoonTrap.State.ORBITING
                trap.orbit_timer = Timer.new()
                trap.add_child(trap.orbit_timer)
                trap.orbit_timer.wait_time = randi_range(3, 6)
                trap.orbit_timer.timeout.connect(trap.return_home)
                trap.orbit_timer.start()


func _apply_item_queue(game: Game, items_data: Array):
    for item_data in items_data:
        game.hud.item_queue.add_item(item_data.get("type", ""), item_data.get("data", {}))
