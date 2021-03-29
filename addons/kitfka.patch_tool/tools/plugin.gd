tool
extends EditorPlugin
# I used zylann.translation_editor as a template. His stuff is great :D
const PatchEditor = preload("./patch_editor.gd")
const PatchEditorScene = preload("./patch_editor.tscn")
const Logger = preload("./util/logger.gd")

const _default_settings = {
	"patch_tool/search_root": "res://",
	"patch_tool/ignored_folders": [
		"res://addons", 
		"res://.import",
		],
	"patch_tool/data_folder": "res://addons/kitfka.patch_tool/data",
	"patch_tool/excluded_extensions": ["cs", "import"]
}

var _main_control : PatchEditor = null
var _logger = Logger.get_for(self)


func _enter_tree():
	for key in _default_settings:
		if not ProjectSettings.has_setting(key):
			var v = _default_settings[key]
			ProjectSettings.set_setting(key, v)
			ProjectSettings.set_initial_value(key, v)
	ProjectSettings.save()
	_logger.debug("PatchTool plugin Enter tree")
	var editor_interface := get_editor_interface()
	var base_control := editor_interface.get_base_control()
	
	_main_control = PatchEditorScene.instance()
	_main_control.configure_for_godot_integration(base_control)
	_main_control.hide()
	editor_interface.get_editor_viewport().add_child(_main_control)
	



func _exit_tree():
	_logger.debug("PatchTool plugin Exit tree")
	# The main control is not freed when the plugin is disabled
	_main_control.queue_free()
	_main_control = null


func has_main_screen() -> bool:
	return true


func get_plugin_name() -> String:
	return "PatchTool"


func get_plugin_icon() -> Texture:
	return preload("icons/icon_translation_editor.svg")


func make_visible(visible: bool):
	_main_control.visible = visible


