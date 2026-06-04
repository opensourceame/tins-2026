extends Node

const TRAP_LAUNCHER    = preload("res://spica/trap_launcher.tscn")
const DETECTOR_DISH    = preload("res://spica/detector_dish.tscn")
const ENERGY_COLLECTOR = preload("res://spica/energy_collector.tscn")
const HABITAT          = preload("res://spica/habitat/habitat.tscn")
const MOON_TRAP        = preload("res://moon_trap.tscn")
const REPAIR_MODULE    = preload("res://spica/repair_module.tscn")

func trap_launcher():
    return TRAP_LAUNCHER.instantiate()

func detector_dish():
    return DETECTOR_DISH.instantiate()

func habitat():
    return HABITAT.instantiate()

func moon_trap():
    return MOON_TRAP.instantiate()

func energy_collector():
    return ENERGY_COLLECTOR.instantiate()

func repair_module():
    return REPAIR_MODULE.instantiate()
