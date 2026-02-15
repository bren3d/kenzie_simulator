@tool
class_name Katie extends Node3D

const DEFAULT_ANIMATION_SPEED: float = 1.0

@export var anim_player: AnimationPlayer
@export var mesh_material: StandardMaterial3D
@export var default_texture: Texture
@export var bloody_texture: Texture
@export var crabwalk_speed: float = 1.0:
	set(val):
		crabwalk_speed = val
		if anim_player: 
			anim_player.speed_scale = crabwalk_speed if anim_player.current_animation == &"crabwalk" else DEFAULT_ANIMATION_SPEED

func _ready() -> void:
	anim_player.current_animation_changed.connect(_on_animation_changed)

func set_texture(texture: Texture) -> void:
	mesh_material.albedo_texture = texture

func play(anim_name: StringName) -> void:
	anim_player.play(anim_name)

func _on_animation_changed(anim_name: StringName) -> void:
	set_texture(bloody_texture if anim_name == &"crabwalk" else default_texture)
	anim_player.speed_scale = crabwalk_speed if anim_name == &"crabwalk" else DEFAULT_ANIMATION_SPEED

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary]
	
	props.push_back({
		name = &"current_animation",
		type = TYPE_STRING_NAME,
		hint = PROPERTY_HINT_ENUM_SUGGESTION,
		hint_string = ",".join(anim_player.get_animation_list()) if anim_player else ""
	})
	
	return props

func _get(property: StringName) -> Variant:
	match property:
		&"current_animation":
			return anim_player.current_animation if anim_player else &""
	return null

func _set(property: StringName, value: Variant) -> bool:
	match property:
		&"current_animation" when anim_player:
			if value: anim_player.play(value)
			return true
	return false
