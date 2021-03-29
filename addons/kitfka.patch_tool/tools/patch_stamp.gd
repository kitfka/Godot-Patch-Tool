tool
extends Resource
class_name PatchStamp
#TODO, think of a better name before putting this in the AssetLib!

export(String) var name
var type = "PatchStamp"

export(Array, Resource) var data

#this is the temp data store location, Please kitfka Fix me!
export(Dictionary) var ddata 

export(Array, String) var patchHistory



func _init(_name = "", _data=[], _ddata={}, _patchHistory=[]):
	name = _name
	data = _data
	ddata = _ddata
	patchHistory = _patchHistory
