tool
extends Panel

const Util = preload("./util/util.gd")


#file menu options
const EDITMENU_RESET_COMPLETE = 1
const EDITMENU_SCAN = 2
const EDITMENU_INIT = 3

onready var _fileMenu_menuButton : MenuButton = $VBoxContainer/MenuBar/FileMenu
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

	#Editmenu
	_editMenu_menuButton.get_popup().connect("id_pressed", self, "_on_editMenu_pressed")
	_editMenu_menuButton.get_popup().add_item("complete reset", EDITMENU_RESET_COMPLETE)
	_editMenu_menuButton.get_popup().add_item("complete scan", EDITMENU_SCAN)
	_editMenu_menuButton.get_popup().add_item("initial setup", EDITMENU_INIT)


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
	pass


func _on_editMenu_pressed(id):
	match id:
		EDITMENU_RESET_COMPLETE:
			print("EDITMENU_RESET_COMPLETE")
			_packtool.reset_complete()
			reload_gui()
			call_deferred("_on_ScanButton_pressed") #18 BUG, this doesn't work 
#			_on_ScanButton_pressed()
			
		EDITMENU_SCAN:
			print("EDITMENU_SCAN")
			_packtool.load_data()
			_packtool.save_data()
			
		EDITMENU_INIT:
			if _packtool.initial_setup() == OK:
				_status_label.text = "oke, init was done"
			else:
				_status_label.text = "Init failed"


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
