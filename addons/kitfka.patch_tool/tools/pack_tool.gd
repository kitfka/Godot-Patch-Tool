tool
extends Node

export(bool) var testRun setget testRunSet
export(Resource) var data

var ValidData = false
var allFiles : Array

var ExcludedExtensions : Array
var ExcludedPaths : Array



func _ready():
	check_data()
	if ProjectSettings.has_setting("patch_tool/excluded_extensions"):
		ExcludedExtensions = ProjectSettings.get_setting("patch_tool/excluded_extensions")
		print(ExcludedExtensions)
		
	if ProjectSettings.has_setting("patch_tool/ignored_folders"):
		ExcludedPaths = ProjectSettings.get_setting("patch_tool/excluded_extensions")
		print(ExcludedPaths)
		
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
#	print(ProjectSettings.get_setting("patch_tool/data_folder"))
	if !data:
		if ProjectSettings.has_setting("patch_tool/data_folder"):
			filepath = ProjectSettings.get_setting("patch_tool/data_folder")
			filepath += "/main.tres"
			print(filepath)
			var f = File.new()
			if f.file_exists(filepath):
				data = ResourceLoader.load(filepath)
			else:
				print("File did not exist?")
#			data = ResourceLoader.load(filepath, "res://addons/kitfka.patch_tool/tools/patch_stamp.gd")
			
		else:
			print("The option patch_tool/data_folder did not exist")
			return
	else:
		print("Data was already found")
	check_data()
	
	find_all_files("res://")

func new_diff(complete:bool = false):
	if !ValidData:
		print("No valid data found")
		return
	
	if data.data.size() == 0:
		complete = true
	
func find_all_files(path:String):
	if !ValidData:
		return
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if is_valid_file(path, file_name): 
					print("Found file: " + file_name)
				else:
					print("Skipped file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func is_valid_folder(path) -> bool:
	if (ExcludedExtensions == null):
		return false
	
	return false

func is_valid_file(path:String, fileName:String) -> bool:
	if (ExcludedExtensions == null):
		return false
	
	if fileName.find("."):
		pass
	var fullPath = path+fileName
	var extension = fullPath.get_extension()
	print("extension: ", extension)
#	if extension in ExcludedExtensions:
#		return false
	
	return true

static func get_hash(filePath:String) -> String:
	var file = File.new()
#	file.open(filePath, File.READ)
#	file.store_string(content)
#	file.close()
	return file.get_md5(filePath)
