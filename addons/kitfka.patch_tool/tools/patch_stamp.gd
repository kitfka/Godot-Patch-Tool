tool
extends Resource
class_name PatchStamp
#TODO, think of a better name before putting this in the AssetLib!

var type = "PatchStamp"

export(Dictionary) var data 


export(Array, String) var patchHistory



func _init(_data={}, _patchHistory=[]):
	data = _data
	patchHistory = _patchHistory
