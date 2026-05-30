class_name Species
extends Node2D

var ability_longevity: bool = false
var greed: int = 0
var environment: String = "air"

const SPECIES = [
    preload("res://species/humans.gd"),
    preload("res://species/wibbles.gd"),
    preload("res://species/bzzaps.gd"),
    preload("res://species/fishoids.gd"),
]

func init_random():
    return SPECIES.pick_random().new()
