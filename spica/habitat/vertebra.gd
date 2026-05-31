class_name Vertebra
extends Node2D

const DAMAGE_FX = preload("res://spica/habitat/damage_fx.tscn")

func animate_damaged():
   add_child(DAMAGE_FX.instantiate())

func remove_damage_animation():
    var fx = find_child("SpineDamageFX")

    if fx:
        fx.queue_free()
