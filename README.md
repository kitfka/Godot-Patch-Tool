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

`patch_tool/excluded_filepaths = []`
excluded files with path. For example: `res://addons/kitfka.patch_tool/tools/patch_stamp.gd`
