tool
extends Node

export(bool) var testRun setget testRunSet
#export(bool) var testExport setget testExportRunSet thiss will bring problems

export(Resource) var data

var ValidData = false
var allFiles : Array

var ExcludedExtensions : Array
var ExcludedPaths : Array



func _ready():
	check_data()
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
		
func check_data():
	if data:
		if not data.type == "PatchStamp":
			ValidData = false
			return
			
		ValidData = true

func testRunSet(value):
	_ready()
	print("extension ignored: ", ExcludedExtensions)
	print("Folders ignored: ", ExcludedPaths)
	load_data()
	JSON.print(data.ddata, "\t")
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
				if is_valid_folder(file_name):
					find_all_files("res://"+file_name+"/")
				else:
					print("Skipped directory: " + file_name)
				
			else:
				if is_valid_file(path, file_name): 
					print("Found file: " + file_name, "-",get_hash(path + file_name))
					handle_file(path+file_name, get_hash(path + file_name))
				else:
					print("Skipped file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func is_valid_folder(path) -> bool:
	if (ExcludedPaths == []):#When we hit this, somthing will have gone wrong.
		return false
	
	if path in ExcludedPaths:
		return false
	return true

func is_valid_file(path:String, fileName:String) -> bool:
	if (ExcludedExtensions == []):#for safty, we are going to ignore everything
		return false
	
	if fileName.find(".") == -1:
		print("Will not have a extension?", fileName)
		return false
	
	var fullPath = path+fileName
	var extension = fullPath.get_extension()
	if extension in ExcludedExtensions:
		print("We are going to ignore the file: ", fileName)
		return false
	return true

func handle_file(filePath:String, fileHash:String):
	if data.ddata.has(filePath):
		if data.ddata[filePath].current_file_hash != fileHash:
			data.ddata[filePath].current_file_hash = fileHash
			data.ddata[filePath].updated_file = true
	else:
		data.ddata[filePath] = {
			"current_file_hash": fileHash,
			"updated_file": true
		}

func is_there_a_updated_file() -> bool:
	var result = false
	for k in data.ddata:
		if data.ddata[k].updated_file:
			result = true
	return result
	
func create_patch(ExportPath:String="res://", packName:String="test.pck"):
	if is_there_a_updated_file():
		print("start patch")
	else:
		print("nothing to patch")
		return
	
	var packer = PCKPacker.new()
	data.patchHistory.append(packName)
	packer.pck_start(ExportPath+packName)
	for k in data.ddata:
		if data.ddata[k].updated_file:
			print(k,"-", data.ddata[k].current_file_hash)
			data.ddata[k].updated_file = false # mark this file as procesed
			packer.add_file(k, k)
	packer.flush(true)

func to_patch() -> Array:
	var resultArray = []
	for k in data.ddata:
		if data.ddata[k].updated_file:
			resultArray.append(k)

	return resultArray

func reset_complete():
	data.ddata.clear()
	
func initial_setup():
	if data:
		print("data not null")
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
		print(filepath)
		var f = File.new()
		if f.file_exists(filepath):
			ResourceSaver.save(filepath, data)
		else:
			print("File did not exist?")

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
	print(filePath)
	var file = File.new()
#	file.open(filePath, File.READ)
#	file.store_string(content)
#	file.close()
	return file.get_md5(filePath)
