class_name Species
extends Node2D

var ability_longevity: bool = false
var greed: int = 0
var environment: String = "oxygen"

const SPECIES = [
    preload("res://species/humans.gd"),
    preload("res://species/wibbles.gd"),
    preload("res://species/hegrons.gd"),
    preload("res://species/sherzat.gd"),
    preload("res://species/fishoids.gd"),
    preload("res://species/guppiez.gd"),
    preload("res://species/plasmoids.gd"),
    preload("res://species/embers.gd"),
]

func init_random():
    return SPECIES.pick_random().new()
