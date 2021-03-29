tool
extends Node


export(Resource) var data

var ValidData = false
var allFiles : Array

var ExcludedExtensions : Array
var ExcludedPaths : Array
var ExcludedFilePaths : Array
var VerbosePrinting : bool



func _ready():
	check_data()
	reload_settings()

#verbose printing. Not a great solution, mayby replace this.
func vprint(txt):
	if VerbosePrinting:
		print(txt)

func reload_settings():
	if ProjectSettings.has_setting("patch_tool/print_verbose"):
		VerbosePrinting = ProjectSettings.get_setting("patch_tool/print_verbose")
	else:
		VerbosePrinting = false
		
	if ProjectSettings.has_setting("patch_tool/excluded_extensions"):
		ExcludedExtensions = ProjectSettings.get_setting("patch_tool/excluded_extensions")
	else:
		ExcludedExtensions = ["cs", "import"]
	
	if ProjectSettings.has_setting("patch_tool/ignored_folders"):
		ExcludedPaths = ProjectSettings.get_setting("patch_tool/ignored_folders")
	else:
		ExcludedPaths = [
		"addons", 
		".import",
		".mono",
		]
	if ProjectSettings.has_setting("patch_tool/excluded_filepaths"):
		ExcludedFilePaths = ProjectSettings.get_setting("patch_tool/excluded_filepaths")
	else:
		ExcludedFilePaths = []


func check_data():
	if data:
		if not data.type == "PatchStamp":
			ValidData = false
			return
			
		ValidData = true


func load_data():
	var filepath:String
#	print(ProjectSettings.get_setting("patch_tool/data_folder"))
	if !data:
		if ProjectSettings.has_setting("patch_tool/data_folder"):
			filepath = ProjectSettings.get_setting("patch_tool/data_folder")
			filepath += "/main.tres"
			vprint(filepath)
			var f = File.new()
			if f.file_exists(filepath):
				data = ResourceLoader.load(filepath)
			else:
				vprint("File did not exist?")
#			data = ResourceLoader.load(filepath, "res://addons/kitfka.patch_tool/tools/patch_stamp.gd")
			
		else:
			vprint("The option patch_tool/data_folder did not exist")
			return
	else:
		vprint("Data was already found")
	check_data()
	
	find_all_files("res://")


func new_diff(complete:bool = false):
	if !ValidData:
		vprint("No valid data found")
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
				if is_valid_folder(file_name):
					vprint("Loop through directory: " + path+file_name+"/")
					find_all_files(path+file_name+"/")
				else:
					vprint("Skipped directory: " + file_name)
				
			else:
				if _is_valid_file(path, file_name): 
					vprint("Found file: " + file_name+"-"+get_hash(path + file_name))
					_handle_file(path+file_name, get_hash(path + file_name))
				else:
					vprint("Skipped file: " + file_name)
			file_name = dir.get_next()
	else:
		vprint("An error occurred when trying to access the path.")


func is_valid_folder(path) -> bool:
	if (ExcludedPaths == []):#When we hit this, somthing will have gone wrong.
		return false
	
	if path in ExcludedPaths:
		return false
	return true


func _is_valid_file(path:String, fileName:String) -> bool:
	if (ExcludedExtensions == []):#for safty, we are going to ignore everything
		return false
	
	if fileName.find(".") == -1:
		vprint("Will not have a extension?"+fileName)
		return false
	
	var fullPath = path+fileName
	if fullPath in ExcludedFilePaths:
		return false
	
	var extension = fullPath.get_extension()
	if extension in ExcludedExtensions:
		vprint("We are going to ignore the file: "+fileName)
		return false
	return true


func _handle_file(filePath:String, fileHash:String):
	if data.data.has(filePath):
		if data.data[filePath].current_file_hash != fileHash:
			data.data[filePath].current_file_hash = fileHash
			data.data[filePath].updated_file = true
	else:
		data.data[filePath] = {
			"current_file_hash": fileHash,
			"updated_file": true
		}


func is_there_a_updated_file() -> bool:
	var result = false
	for k in data.data:
		if data.data[k].updated_file:
			result = true
	return result


func create_patch(ExportPath:String="res://", packName:String="test.pck"):
	if is_there_a_updated_file():
		vprint("start patch")
	else:
		vprint("nothing to patch")
		return
	
	var packer = PCKPacker.new()
	data.patchHistory.append(packName)
	packer.pck_start(ExportPath+packName)
	for k in data.data:
		if data.data[k].updated_file:
			vprint(k+"-"+ data.data[k].current_file_hash)
			data.data[k].updated_file = false # mark this file as procesed
			packer.add_file(k, k)
	packer.flush(true)


func to_patch() -> Array:
	var resultArray = []
	for k in data.data:
		if data.data[k].updated_file:
			resultArray.append(k)

	return resultArray


func reset_complete():
	data = PatchStamp.new()
	save_data()


func initial_setup():
	if data:
		vprint("data not null")
		return ERR_ALREADY_EXISTS
	else:
		data = PatchStamp.new()
		save_data()
		return OK


func save_data():
	var filepath:String
	if ProjectSettings.has_setting("patch_tool/data_folder"):
		filepath = ProjectSettings.get_setting("patch_tool/data_folder")
		filepath += "/main.tres"
		var f = File.new()
		if f.file_exists(filepath):
			ResourceSaver.save(filepath, data)
		else:
			vprint("File did not exist?")


func get_patchHistory() -> Array:
	if data:
		return data.patchHistory
	else:
		return []


func get_defaultPatchName() -> String:
	var r = get_patchHistory()
	if r == []:
		return "patch_000"
	else:
		return r.back()


static func get_hash(filePath:String) -> String:
	var file = File.new()
	return file.get_md5(filePath)
