class_name TrapLauncher
extends Node2D

var trap: MoonTrap

func _ready():
    pass

func start_building():
    trap = Spawner.moon_trap()
