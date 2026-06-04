class_name PauseOverlay
extends Control

@onready var resume_button: Button = %ResumeButton

func _ready():
    Engine.time_scale = 0.0
    resume_button.pressed.connect(_on_resume_pressed)


func _on_resume_pressed():
    Engine.time_scale = 1.0
    queue_free()
