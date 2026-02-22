@tool
class_name SettingsMenu extends Control

const CONFIG_FILE_PATH: String = "user://settings.cfg"

signal request_close

@export var settings_properties: Array[SettingsProperty]
@export var bus_volume_setting_properties: Dictionary[SettingsProperty, int]

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	for sp: SettingsProperty in bus_volume_setting_properties:
		sp.value_changed.connect(_on_audio_bus_volume_changed.bind(bus_volume_setting_properties[sp]))
	
	hide()
	
	if FileAccess.file_exists(CONFIG_FILE_PATH):
		load_config(CONFIG_FILE_PATH)

func load_config(config_file_path: String) -> ConfigFile:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.load(config_file_path)
	for sp: SettingsProperty in settings_properties:
		sp.read_file(cfg)
	return cfg

func store_config(config_file_path: String) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	for sp: SettingsProperty in settings_properties:
		sp.write_file(cfg)
	cfg.save(config_file_path)

func open() -> void:
	show()

func close() -> void:
	store_config(CONFIG_FILE_PATH)
	hide()

func _on_back_button_pressed() -> void:
	request_close.emit()

func _on_audio_bus_volume_changed(new_percent_value: float, bus: int) -> void:
	var linear_value: float = clampf(new_percent_value /100.0, 0.0, 1.0)
	AudioServer.set_bus_volume_linear(bus, linear_value)
