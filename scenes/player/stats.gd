@tool
class_name StatComponent extends Node

signal changed(new_value: float)

## Name of stat and meta tag.
@export_placeholder("Stat")
var stat_name: String = "": set = set_stat_name

## Current value of stat.
@export_range(0.0, 100.0, 0.1, "suffix:%")
var value: float = 50.0: set = set_value

## How much the stat changes every second.
@export_range(-10.0, 10.0, 0.01, "or_less", "or_greater", "exp", "suffix:%/s" )
var delta_sec: float = 0.0

## Is timer paused.
@export 
var paused: bool = true :  set = set_paused, get = is_paused

## Current time scale. 
var time_scale: float = 1.0

var timer_value: float = 0.0

func _ready() -> void:
	assert(Engine.is_editor_hint() or stat_name, "No stat name set.")
	# Set again so _process does not run
	set_paused(paused) 

func _process(delta: float) -> void:
	timer_value += delta * time_scale
	if timer_value > 0.0:
		tick()

func tick() -> void:
	value -= delta_sec
	# Use subtraction in case timer is greater than 2.0
	timer_value = timer_value - 1.0 

func set_value(val: float) -> void:
	value = maxf(0.0, val)
	changed.emit(value)

func set_stat_name(val: String) -> void:
	stat_name = val
	set_name(stat_name)
	update_configuration_warnings()

func unpause() -> void:
	set_paused(false)

func pause() -> void:
	set_paused(true)

func set_paused(val: bool) -> void:
	paused = val
	set_process(!paused and not Engine.is_editor_hint())

func is_paused() -> bool:
	return paused

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if not stat_name:
		warnings.push_back("No stat name set.")
	return warnings

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED when not Engine.is_editor_hint():
			get_parent().set_meta(stat_name, self)
		NOTIFICATION_UNPARENTED when not Engine.is_editor_hint():
			get_parent().set_meta(stat_name, null)
