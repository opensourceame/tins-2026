class_name Habitat
extends Node2D

const SNAP_DISTANCE: float = 48.0

@onready var drag_handle_left: Area2D = $DragHandleLeft
@onready var drag_handle_right: Area2D = $DragHandleRight

var dragging: bool = false
var active_handle_is_left: bool = false

func _ready():
    drag_handle_left.input_event.connect(_on_handle_input.bind(true))
    drag_handle_right.input_event.connect(_on_handle_input.bind(false))

func _on_handle_input(viewport: Node, event: InputEvent, shape_idx: int, is_left: bool):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            dragging = true
            active_handle_is_left = is_left
        elif dragging:
            dragging = false
            try_snap()

func _input(event: InputEvent):
    if dragging and event is InputEventMouseMotion:
        var mouse_global = get_global_mouse_position()
        var angle_to_mouse = (mouse_global - global_position).angle()
        if active_handle_is_left:
            rotation = angle_to_mouse - PI
        else:
            rotation = angle_to_mouse

func try_snap():
    var handle_pos = _get_active_handle_global_position()
    var anchors = _get_anchors()
    if anchors.is_empty():
        return

    var best_anchor = null
    var best_dist = SNAP_DISTANCE

    for anchor in anchors:
        var d = handle_pos.distance_to(anchor.global_position)
        if d < best_dist:
            best_dist = d
            best_anchor = anchor

    if best_anchor:
        var angle_to_anchor = (best_anchor.global_position - global_position).angle()
        if active_handle_is_left:
            rotation = angle_to_anchor - PI
        else:
            rotation = angle_to_anchor

func _get_active_handle_global_position() -> Vector2:
    var offset = Vector2(-480.0, 0.0) if active_handle_is_left else Vector2(480.0, 0.0)
    return global_position + offset.rotated(rotation)

func _get_anchors() -> Array:
    var parent = get_parent()
    if not parent:
        return []
    var anchors_node = parent.get_node_or_null("Anchors")
    if not anchors_node:
        return []
    return anchors_node.get_children()
