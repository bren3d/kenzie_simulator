@tool
class_name SettingsUI extends Control

@export_tool_button("Populate Display")
var callable_populate: Callable = populate

@export var settings_display_properties: Array[SettingsPropertyDisplay]
@export var settings_hbox: HBoxContainer

var settings_display_controls: Dictionary[SettingsPropertyDisplay, Control]

func _ready() -> void:
	if Engine.is_editor_hint(): return
	settings_hbox.hide()
	populate()
	#"uid://ds4tahw8spshu"
	#"uid://ds4tahw8spshu"

func populate() -> void:
	for spd: SettingsPropertyDisplay in settings_display_properties:
		if not spd or not spd.settings_property or spd.mode == SettingsPropertyDisplay.DisplayMode.HIDDEN: continue
		add_child(create_control(spd))
		

func create_control(spd: SettingsPropertyDisplay) -> Control:
	var hbox: HBoxContainer = settings_hbox.duplicate()
	hbox.show()
	
	var name_label: Label = hbox.get_child(0)
	name_label.text = spd.settings_property.get_display_name()
	
	var slider: HSlider = hbox.get_child(1).get_child(0)
	var spinbox: SpinBox = hbox.get_child(1).get_child(1)
	spinbox.share(slider)
	spinbox.value_changed.connect(_on_value_changed.bind(spd.settings_property))
	settings_display_controls[spd] = spinbox
	spd.settings_property.changed.connect(_on_settings_property_changed.bind(spd))
	
	match spd.mode:
		SettingsPropertyDisplay.DisplayMode.SPINBOX:
			slider.free()
	
	return hbox

## Fetches value from resource if changed.
func update_display() -> void:
	for spd: SettingsPropertyDisplay in settings_display_controls.keys():
		settings_display_controls[spd].set_value_no_signal(spd.settings_property.value)

func get_settings_properties() -> Array[SettingsProperty]:
	var settings_properties: Array[SettingsProperty]
	for spd: SettingsPropertyDisplay in settings_display_properties:
		if not spd or not spd.settings_property: continue
		settings_properties.push_back(spd.settings_property)
	return settings_properties

func _on_value_changed(value: float, sp: SettingsProperty) -> void:
	sp.set_value(value)

func _on_settings_property_changed(spd: SettingsPropertyDisplay) -> void:
	var spinbox: SpinBox = settings_display_controls[spd]
	spinbox.set_value_no_signal(spd.settings_property.get_value())
