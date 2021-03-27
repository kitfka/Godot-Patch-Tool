tool
extends Resource
#TODO, think of a better name before putting this in the AssetLib!

#name of this diff
export(String) var name

export(int) var number
var type = "PatchDiff"
#filepath: hash
export(Dictionary) var data






func _init(_name = "",_number=-1, _data={}):
	name = _name
	number = _number
	data = _data
