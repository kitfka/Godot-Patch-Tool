tool
extends Resource
class_name PatchStamp
#TODO, think of a better name before putting this in the AssetLib!

export(String) var name
var type = "PatchStamp"

export(Array, Resource) var data





func _init(_name = "", _data=[]):
	name = _name
	data = _data
