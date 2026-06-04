class_name Vertebra
extends Node2D

const DAMAGE_FX = preload("res://spica/habitat/damage_fx.tscn")

var fx: SpineDamageFX

func animate_damaged():
    fx = DAMAGE_FX.instantiate()
    add_child(fx)

func clear_damage():
    if fx:
        fx.reset()
        fx.queue_free()
