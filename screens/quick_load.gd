class_name QuickLoad
extends Control

@onready var saves_container: VBoxContainer = %Saves
@onready var back_button: Button = %BackButton
@onready var clear_all_button: Button = %ClearAllButton

var save_manager: Node

func _ready():
    back_button.pressed.connect(_on_back_pressed)
    clear_all_button.pressed.connect(_on_clear_all_pressed)

    if not save_manager:
        return

    _populate_saves()


func _populate_saves():
    for child in saves_container.get_children():
        child.queue_free()

    var saves = save_manager.get_recent_saves()

    if saves.is_empty():
        var empty_label = Label.new()
        empty_label.text = "No saves found"
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        saves_container.add_child(empty_label)
    else:
        for save in saves:
            var entry = _create_save_entry(save)
            saves_container.add_child(entry)


func _create_save_entry(save: Dictionary) -> Button:
    var btn = Button.new()
    btn.size_flags_horizontal = SIZE_EXPAND_FILL
    btn.add_theme_font_size_override("font_size", 32)

    var dt = Time.get_datetime_dict_from_unix_time(save.get("timestamp", 0))
    var date_str = "%04d-%02d-%02d %02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
    btn.text = date_str

    btn.pressed.connect(_on_save_selected.bind(save))

    return btn


func _on_save_selected(save: Dictionary):
    if save_manager:
        save_manager.quick_load(save.get("data", {}))


func _on_clear_all_pressed():
    if save_manager and save_manager.has_method("delete_all_saves"):
        save_manager.delete_all_saves()
        _populate_saves()


func _on_back_pressed():
    queue_free()
