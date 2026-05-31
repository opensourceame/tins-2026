class_name QuickLoad
extends Control

@onready var saves_container: VBoxContainer = %Saves
@onready var back_button: Button = %BackButton

var save_manager: Node


func _ready():
    back_button.pressed.connect(_on_back_pressed)

    if not save_manager:
        return

    var saves = save_manager.get_recent_saves()

    if saves.is_empty():
        var empty_label = Label.new()
        empty_label.text = "No saves found"
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty_label.theme_override_font_sizes["font_size"] = 32
        saves_container.add_child(empty_label)
    else:
        for save in saves:
            var entry = _create_save_entry(save)
            saves_container.add_child(entry)


func _create_save_entry(save: Dictionary) -> Button:
    var btn = Button.new()
    btn.size_flags_horizontal = SIZE_EXPAND_FILL

    var dt = Time.get_datetime_dict_from_unix_time(save.get("timestamp", 0))
    var date_str = "%04d-%02d-%02d %02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
    btn.text = date_str

    btn.pressed.connect(_on_save_selected.bind(save))

    return btn


func _on_save_selected(save: Dictionary):
    if save_manager:
        save_manager.quick_load(save.get("data", {}))


func _on_back_pressed():
    queue_free()
