class_name SpicaAnchor
extends Area2D

@onready var component_marker: Marker2D = $ComponentMarker

var component = null

func attach_component(c):
    component_marker.add_child(c)
    component = c

func has_component():
    return component_marker.get_child_count() > 0
