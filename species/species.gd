class_name Species
extends Node2D

var ability_longevity: bool = false
var greed: int = 0

const SPECIES = [
    preload("res://species/humans.gd"),
    preload("res://species/wibbles.gd"),
]

func init_random():
    return SPECIES.pick_random().new()
