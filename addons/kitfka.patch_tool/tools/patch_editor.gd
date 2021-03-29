tool
extends Panel

const Util = preload("./util/util.gd")
const Logger = preload("./util/logger.gd")


#file menu options
const EDITMENU_RESET_COMPLETE = 1
const EDITMENU_SCAN = 2







onready var _fileMenu_menuButton : MenuButton = $VBoxContainer/MenuBar/FileMenu
onready var _editMenu_menuButton : MenuButton = $VBoxContainer/MenuBar/EditMenu

onready var _build_button : Button = $VBoxContainer/Main/LeftPane/StringListActions/BuildButton
onready var _status_label : Label = $VBoxContainer/StatusBar/Label
onready var _fileChangeList_itemList : ItemList = \
$VBoxContainer/Main/RightPane/VSplitContainer/FileChangeList
onready var _fileName_lineEdit : LineEdit = $VBoxContainer/Main/LeftPane/Search/FileName

onready var _packtool : Node = $Node

var _base_control : Control = null

var _logger = Logger.get_for(self)

var patchName:String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if Util.is_in_edited_scene(self):
		return
	
	_status_label.text = "Need to load stuff"
	_fileName_lineEdit.text = "patch_0"
	
	#Filemenu
	_fileMenu_menuButton.get_popup().connect("id_pressed", self, "_on_fileMenu_pressed")

	#Editmenu
	_editMenu_menuButton.get_popup().connect("id_pressed", self, "_on_editMenu_pressed")
	_editMenu_menuButton.get_popup().add_item("complete reset", EDITMENU_RESET_COMPLETE)
	_editMenu_menuButton.get_popup().add_item("complete scan", EDITMENU_SCAN)

func configure_for_godot_integration(base_control: Control):
	# You have to call this before adding to the tree
	assert(not is_inside_tree())
	_base_control = base_control
	# Make underlying panel transparent because otherwise it looks bad in the editor
	# TODO Would be better to not draw the panel background conditionally
	self_modulate = Color(0, 0, 0, 0)
	

#signal stuff
func _on_LoadButton_pressed():
	_fileChangeList_itemList.clear()
	var l:Array = _packtool.to_patch()
	for a in l:
		_fileChangeList_itemList.add_item(a, null, false)

func _on_BuildButton_pressed():
	_packtool.create_patch("res://addons/kitfka.patch_tool/data/", patchName+".pck")


func _on_FileName_text_changed(new_text):
	patchName = new_text

func _on_fileMenu_pressed(id):
	pass
	
func _on_editMenu_pressed(id):
	match id:
		EDITMENU_RESET_COMPLETE:
			print("EDITMENU_RESET_COMPLETE")
			_packtool.reset_complete()
			_packtool.save_data()
			
		EDITMENU_SCAN:
			print("EDITMENU_SCAN")
			_packtool.load_data()
			_packtool.save_data()
			
	
