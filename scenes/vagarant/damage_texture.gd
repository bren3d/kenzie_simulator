@tool
class_name DamageTexture extends TextureRect

@export var alpha_per_sec: float = 3.0

func _init() -> void:
	if Engine.is_editor_hint(): return
	modulate.a = 0.0

func tick() -> void:
	modulate.a = 1.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	modulate.a = move_toward(modulate.a, 0.0, alpha_per_sec * delta)
	
