@icon("res://assets/icons/icon_door_group.png")
@tool
class_name DoorGroup extends Resource

signal group_changed(property: StringName, value: Variant)

@export var sync_locked: bool = true
@export var sync_open: bool = true

func _init() -> void:
	resource_local_to_scene = true

func update(door: Door) -> void:
	if sync_locked:
		group_changed.emit(&"locked", door.locked)
	if sync_open:
		group_changed.emit(&"open", door.open)

func add_door(door: Door) -> void:
	var doors:= get_group_doors()
	if not doors.is_empty():
		if sync_locked:
			door.locked = doors[0].locked
		if sync_open:
			door.open = doors[0].open
	if not group_changed.is_connected(door.set):
		group_changed.connect(door.set)

func remove_door(door: Door) -> void:
	if not group_changed.is_connected(door.set):
		group_changed.connect(door.set)

func get_group_doors() -> Array[Door]:
	var doors: Array[Door]
	for dict: Dictionary in group_changed.get_connections():
		var obj: Object = dict.callable.get_object()
		if obj is Door: doors.push_back(obj)
	return doors
