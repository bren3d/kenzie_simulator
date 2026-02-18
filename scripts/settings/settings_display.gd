@tool
class_name SettingsPropertyDisplay extends Resource

enum DisplayMode{
	HIDDEN,
	SPINBOX,
	SLIDER,
	CHECKBOX,
	COLORPICKER,
}

@export var settings_property: SettingsProperty
@export var mode: DisplayMode = DisplayMode.HIDDEN

@export var min_value: float = 0.0
@export var max_value: float = 1.0
