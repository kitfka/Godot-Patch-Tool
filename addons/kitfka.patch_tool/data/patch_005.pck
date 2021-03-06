GDPC                                                                                  res://.gitignore9      ?                          res://new folder/new scene.tscn?      ?                          res://project.godot?      E                         res://README.md?      ]                      # Godot-specific ignores
.import/
export.cfg
export_presets.cfg

# Imported translations (automatically generated from CSV files)
*.translation

# Mono-specific ignores
.mono/
data_*/[gd_scene format=2]

[node name="Control" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Node" type="Node" parent="."]
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=4

_global_script_classes=[ {
"base": "Resource",
"class": "PatchStamp",
"language": "GDScript",
"path": "res://addons/kitfka.patch_tool/tools/patch_stamp.gd"
} ]
_global_script_class_icons={
"PatchStamp": ""
}

[application]

config/name="Godot Patch Tool"

[editor_plugins]

enabled=PoolStringArray( "kitfka.patch_tool" )
Patch builder for Godot Engine
=====================================

This tool is able to make automate patch generation. However, there is stull a lot to do.
Works with godot3.2.3

Here is an [example](https://github.com/kitfka/Godot-Patch-Tool-Example) in progress!

Settings
-----------

`patch_tool/print_verbose = false`
print verbose for debuging

`patch_tool/search_root = "res://"`
Starting directory. If you need a tool to make DLC or somthing, you could change this to another folder and exclude this folder from your normal export. ps DLC capabilitys will be added at a later date to this addon

`patch_tool/ignored_folders = [ "addons", ".import", ".mono", ]`
Folders that will be ignored.

`patch_tool/data_folder = "res://addons/kitfka.patch_tool/data"`
The folder that will contain the json data with all the hashes.

`patch_tool/excluded_extensions = ["cs", "import"]`
extensions that will be ignored without a '.'

`patch_tool/excluded_filepaths = ["res://export_presets.cfg"]`
excluded files with path. For example: `res://addons/kitfka.patch_tool/tools/patch_stamp.gd`
