extends Node

const SAVE_PATH = "user://simple_save.tscn"


func quick_save() -> bool:
    var root = get_tree().current_scene
    if not root:
        return false

    set_owner_recursive(root, root)

    var packed_scene = PackedScene.new()
    packed_scene.pack(root)
    var result = ResourceSaver.save(packed_scene, SAVE_PATH)
    return result == OK


func set_owner_recursive(node: Node, new_owner: Node):
    for child in node.get_children():
        child.owner = new_owner
        set_owner_recursive(child, new_owner)


func get_recent_saves() -> Array:
    if not FileAccess.file_exists(SAVE_PATH):
        return []

    var file_time = FileAccess.get_modified_time(SAVE_PATH)
    return [{
        "filename": "simple_save.tscn",
        "path": SAVE_PATH,
        "timestamp": file_time,
        "data": {},
    }]


func quick_load(_data: Dictionary):
    if not FileAccess.file_exists(SAVE_PATH):
        return

    var current_scene = get_tree().current_scene
    if not current_scene:
        return

    get_tree().root.remove_child(current_scene)
    current_scene.queue_free()

    var saved_scene = load(SAVE_PATH)
    var new_scene = saved_scene.instantiate()
    get_tree().root.add_child(new_scene)
    get_tree().current_scene = new_scene

    _apply_after_load()


func _apply_after_load():
    var game = get_tree().current_scene as Game
    if not game:
        return

    game.hud.capacity_changed(null)
    SignalBus.spica_damage.emit()
    game.add_child(preload("res://screens/pause.tscn").instantiate())
