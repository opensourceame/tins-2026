extends Node

const TRAP_LAUNCHER = preload("res://spica/trap_launcher.tscn")
const DETECTOR_DISH = preload("res://spica/detector_dish.tscn")
const HABITAT       = preload("res://habitat.tscn")
const MOON_TRAP     = preload("res://moon_trap.tscn")

func trap_launcher():
    return TRAP_LAUNCHER.instantiate()

func detector_dish():
    return DETECTOR_DISH.instantiate()

func habitat():
    return HABITAT.instantiate()

func moon_trap():
    return MOON_TRAP.instantiate()
