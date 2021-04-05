tool
extends Panel

const Util = preload("./util/util.gd")


#file menu options
const FILEMENU_MAIN_OPEN = 1

const PATCHMENU_PATCH_ROLLBACK = 1
const PATCHMENU_INIT = 2
const PATCHMENU_RESET = 3
const PATCHMENU_SCAN = 4

const DEBUGMENU_PRINT_VERBOSE = 1
const DEBUGMENU_PRINT_DEBUGDATA = 2

#OLD MENU CONST, remove on 0.3
const EDITMENU_RESET_COMPLETE = 1
const EDITMENU_SCAN = 2
const EDITMENU_INIT = 3
const EDITMENU_ROLLBACK = 4


onready var _fileMenu_menuButton : MenuButton = $VBoxContainer/MenuBar/FileMenu
onready var _patchMenu_menuButton : MenuButton = $VBoxContainer/MenuBar/PatchMenu
onready var _debugMenu_menuButton : MenuButton = $VBoxContainer/MenuBar/DebugMenu
onready var _editMenu_menuButton : MenuButton = $VBoxContainer/MenuBar/EditMenu

onready var _build_button : Button = \
$VBoxContainer/Main/LeftPane/StringListActions/BuildButton
onready var _status_label : Label = $VBoxContainer/StatusBar/Label
onready var _fileChangeList_itemList : ItemList = \
$VBoxContainer/Main/RightPane/VSplitContainer/FileChangeList
onready var _fileName_lineEdit : LineEdit = \
$VBoxContainer/Main/LeftPane/Search/FileName
onready var _stringList_itemList : ItemList = \
$VBoxContainer/Main/LeftPane/StringList

onready var _packtool : Node = $Node

var _base_control : Control = null

var patchName:String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if Util.is_in_edited_scene(self):
		return
	
	_fileName_lineEdit.text = _packtool.get_defaultPatchName().get_basename()
	patchName = _packtool.get_defaultPatchName().get_basename()
	reload_gui()
	
	#Filemenu
	_fileMenu_menuButton.get_popup().connect("id_pressed", self, "_on_fileMenu_pressed")
	_fileMenu_menuButton.get_popup().add_item("open main", FILEMENU_MAIN_OPEN)

	#Editmenu
	_patchMenu_menuButton.get_popup().connect("id_pressed", self, "_on_patchMenu_pressed")
	_patchMenu_menuButton.get_popup().add_item("rollback last patch", PATCHMENU_PATCH_ROLLBACK)
	_patchMenu_menuButton.get_popup().add_item("initial setup", PATCHMENU_INIT)
	_patchMenu_menuButton.get_popup().add_item("complete reset", PATCHMENU_RESET)
	_patchMenu_menuButton.get_popup().add_item("complete scan", PATCHMENU_SCAN)
	
	#debug menu
	_debugMenu_menuButton.get_popup().connect("id_pressed", self, "_on_debugMenu_pressed")
	_debugMenu_menuButton.get_popup().add_check_item("print verbose", DEBUGMENU_PRINT_VERBOSE)
	_debugMenu_menuButton.get_popup().add_item("DEBUGMENU_PRINT_DEBUGDATA", DEBUGMENU_PRINT_DEBUGDATA)
	
	#XD This should not be done, but it is a quick option for now.
	_on_debugMenu_pressed(DEBUGMENU_PRINT_VERBOSE)
	_on_debugMenu_pressed(DEBUGMENU_PRINT_VERBOSE)
	
func reload_gui():
	reload_history()
	if _packtool.ValidData:
		_status_label.text = "Press scan to start"
		_build_button.disabled = false
	else:
		_status_label.text = "no ValidData"
		_build_button.disabled = true


func reload_history():
	_stringList_itemList.clear()
	for item in _packtool.get_patchHistory():
		_stringList_itemList.add_item(item, null, false)


func configure_for_godot_integration(base_control: Control):
	# You have to call this before adding to the tree
	assert(not is_inside_tree())
	_base_control = base_control
	# Make underlying panel transparent because otherwise it looks bad in the editor
	# TODO Would be better to not draw the panel background conditionally
	self_modulate = Color(0, 0, 0, 0)


#signals
func _on_BuildButton_pressed():
	if patchName == "":
		_status_label.text = "Build failed, patch name is empty"
		return
	
	var f = File.new()
	if f.file_exists("res://addons/kitfka.patch_tool/data/"+patchName+".pck"):
		_status_label.text = "Build failed, patch file already exists."
		return
	
	if patchName+".pck" in _packtool.get_patchHistory():
		_status_label.text = "Build failed, patch file already in history."
		return
	
	_packtool.create_patch("res://addons/kitfka.patch_tool/data/", patchName+".pck")
	_status_label.text = "Build was a Succes"
	reload_gui()


func _on_FileName_text_changed(new_text):
	patchName = new_text


func _on_fileMenu_pressed(id):
	print("file menu not implemented", id)


func _on_patchMenu_pressed(id):
	match id:
		PATCHMENU_RESET:
			print("PATCHMENU_RESET")
			_packtool.reset_complete()
			reload_gui()
			call_deferred("_on_ScanButton_pressed") #18 BUG, this doesn't work 
#			_on_ScanButton_pressed()
			
		PATCHMENU_SCAN:
			print("PATCHMENU_SCAN")
			_packtool.load_data()
			_packtool.save_data()
			
		PATCHMENU_INIT:
			print("PATCHMENU_INIT")
			if _packtool.initial_setup() == OK:
				_status_label.text = "oke, init was done"
			else:
				_status_label.text = "Init failed"
		PATCHMENU_PATCH_ROLLBACK:
			print("PATCHMENU_PATCH_ROLLBACK")
			_packtool._rollback_patch()

func _on_debugMenu_pressed(id):
	match id:
		DEBUGMENU_PRINT_VERBOSE:
			if !ProjectSettings.has_setting("patch_tool/print_verbose"):
				ProjectSettings.set_setting("patch_tool/print_verbose", true)
			
			#invert the setting
			ProjectSettings.set_setting("patch_tool/print_verbose", \
			!ProjectSettings.get_setting("patch_tool/print_verbose"))

			#set the checkbox
			var itemIndex = _debugMenu_menuButton.get_popup().get_item_index(DEBUGMENU_PRINT_VERBOSE)
			_debugMenu_menuButton.get_popup().set_item_checked(itemIndex, \
			ProjectSettings.get_setting("patch_tool/print_verbose"))
			
		DEBUGMENU_PRINT_DEBUGDATA:
			for k in _packtool.data.data:
				print(_packtool.data.data[k])



func _on_ScanButton_pressed():
	_packtool.reload_settings()
	_packtool.load_data()
	_packtool.save_data()
	_fileChangeList_itemList.clear()
	var l:Array = _packtool.to_patch()
	for a in l:
		_fileChangeList_itemList.add_item(a, null, false)
	reload_gui()


func _on_ClearSearch_pressed():
	pass # Replace with function body.
