tool
extends Panel

const Util = preload("./util/util.gd")
const Logger = preload("./util/logger.gd")

onready var _build_button : Button = $VBoxContainer/Main/LeftPane/StringListActions/BuildButton
onready var _status_label : Label = $VBoxContainer/StatusBar/Label
onready var _fileChangeList_itemList : ItemList = \
$VBoxContainer/Main/RightPane/VSplitContainer/FileChangeList

var _base_control : Control = null

var _logger = Logger.get_for(self)


# Called when the node enters the scene tree for the first time.
func _ready():
	if Util.is_in_edited_scene(self):
		return
	
	_status_label.text = "Need to load stuff"
	

func configure_for_godot_integration(base_control: Control):
	# You have to call this before adding to the tree
	assert(not is_inside_tree())
	_base_control = base_control
	# Make underlying panel transparent because otherwise it looks bad in the editor
	# TODO Would be better to not draw the panel background conditionally
	self_modulate = Color(0, 0, 0, 0)


func _on_LoadButton_pressed():
	pass # Replace with function body.


func _on_BuildButton_pressed():
	pass # Replace with function body.
