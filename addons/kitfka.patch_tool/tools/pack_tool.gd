tool
extends Node

export(bool) var testRun setget testRunSet
export(Resource) var data

var ValidData = false
var allFiles : Array

var ExcludedExtensions : Array


func _ready():
	check_data()
	ExcludedExtensions = ProjectSettings.get_setting("patch_tool/excluded_extensions")

func check_data():
	if data:
		if not data.type == "PatchStamp":
			ValidData = false
			return
			
		ValidData = true

func testRunSet(value):
	load_data()
	testRun = false
	
func load_data():
	var filepath:String
	if ProjectSettings.has_setting("patch_tool/data_folder"):
		filepath = ProjectSettings.get_setting("patch_tool/data_folder")
		filepath += "main.tres"
		print(filepath)
	else:
		print("Did not find the file")
		return
		

	data = ResourceLoader.load(filepath, "res://addons/kitfka.patch_tool/tools/patch_stamp.gd")
	check_data()

func new_diff(complete:bool = false):
	if !ValidData:
		print("No valid data found")
		return
	
	if data.data.size() == 0:
		complete = true
	
func find_all_files(path:String):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

static func is_valid_file(path:String, fileName:String) -> bool:
	var fullPath = path+fileName
	var extension = fullPath.get_extension()
	if extension in ExcludedExtensions:
		return false
	
	return true

static func get_hash(filePath:String) -> String:
	var file = File.new()
#	file.open(filePath, File.READ)
#	file.store_string(content)
#	file.close()
	return file.get_md5(filePath)
