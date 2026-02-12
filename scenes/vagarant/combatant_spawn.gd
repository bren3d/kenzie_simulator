@tool
class_name CombatantSpawner extends Node3D

signal spawned(comb: Node3D)

const POSITION_OFFSET: Vector3 = Vector3.UP

@export_tool_button("Spawn") var spawn_callable: Callable = spawn
@export var combatant_scene: PackedScene
@export var player_scene: PackedScene

@export var is_ally: bool = false
@export var is_player: bool = false

@export_placeholder("FredMustard") 
var display_name: String = ""

@export var targeting_handle: TargetingHandle
@export var event_handle: VagarantEventHandle

func spawn() -> void:
	if is_player:
		spawn_player()
		return
	
	var combatant: Combatant = combatant_scene.instantiate()
	combatant.display_name = display_name
	combatant.position = position + POSITION_OFFSET
	combatant.is_ally = is_ally
	combatant.targeting_handle = targeting_handle
	combatant.event_handle = event_handle
	add_sibling(combatant)
	
	if Engine.is_editor_hint():
		combatant.owner = owner
	
	spawned.emit(combatant)


func spawn_player() -> void:
	if Engine.is_editor_hint(): return
	var player: VagarantPlayer = player_scene.instantiate()
	player.position = position + POSITION_OFFSET
	player.targeting_handle = targeting_handle
	player.event_handle = event_handle
	add_sibling(player)
	spawned.emit(player)
