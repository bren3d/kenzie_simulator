@tool
class_name SettingsProperty extends Resource

@export_placeholder("master_volume") 
var name: String: set = set_property_name

## Section name in Config file.
@export var section: String = ""

## Value of settings property.
@export var value: Variant #: set = set_value, get = get_value

## Sets value and emits changed signal.
func set_value(val: Variant) -> void:
	value = val
	changed.emit()

func set_value_no_signal(val: Variant) -> void:
	value = val

func get_value() -> Variant:
	return value

## Reads property from [param cfg].
func read_file(cfg: ConfigFile) -> void:
	if not cfg.has_section_key(section, name):
		push_warning("Section (%s) - Key (%s) does not exist in file." % [section, name])
		changed.emit()
		return
		
	var file_value: Variant = cfg.get_value(section, name)
	
	if typeof(file_value) == typeof(value):
		set_value(file_value)
		return
	
	push_warning("Value type mismatch for setting %s. File: %s (%s) | Setting: %s (%s)" % [name, file_value, type_string(typeof(file_value)), value, type_string(typeof(value))])
	changed.emit()

## Writes property to [param cfg].
func write_file(cfg: ConfigFile) -> void:
	cfg.set_value(section, name, value)

## Rejects [param prop_name] if spaces are included.
func set_property_name(prop_name: String) -> void:
	if prop_name.contains(" "):
		push_warning("Name cannot contain spaces.")
		return
	name = prop_name

## Returns human formatted version of [member name].
func get_display_name() -> String:
	return name.capitalize()

## Returns human formatted version of [member section].
func get_display_section() -> String:
	return section.capitalize()
