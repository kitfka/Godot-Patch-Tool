tool
extends EditorPlugin
# I used zylann.translation_editor as a template. His stuff is great :D
# https://github.com/Zylann/godot_translation_editor 

const PatchEditor = preload("./patch_editor.gd")
const PatchEditorScene = preload("./patch_editor.tscn")


const _default_settings = {
	"patch_tool/print_verbose": false,
	"patch_tool/search_root": "res://",
	"patch_tool/ignored_folders": [
		"addons", 
		".import",
		".mono",
		],
	"patch_tool/data_folder": "res://addons/kitfka.patch_tool/data",
	"patch_tool/excluded_extensions": ["cs", "import", "csproj", "sln"],
	"patch_tool/excluded_filepaths": ["res://export_presets.cfg"], #res://example.tscn
}

var _main_control : PatchEditor = null



func _enter_tree():
	for key in _default_settings:
		if not ProjectSettings.has_setting(key):
			var v = _default_settings[key]
			ProjectSettings.set_setting(key, v)
			ProjectSettings.set_initial_value(key, v)
	ProjectSettings.save()

	var editor_interface := get_editor_interface()
	var base_control := editor_interface.get_base_control()
	
	_main_control = PatchEditorScene.instance()
	_main_control.configure_for_godot_integration(base_control)
	_main_control.hide()
	editor_interface.get_editor_viewport().add_child(_main_control)
	



func _exit_tree():
	# The main control is not freed when the plugin is disabled
	_main_control.queue_free()
	_main_control = null


func has_main_screen() -> bool:
	return true


func get_plugin_name() -> String:
	return "PatchTool"


func get_plugin_icon() -> Texture:
	return preload("icons/patch_icon.png")


func make_visible(visible: bool):
	_main_control.visible = visible


