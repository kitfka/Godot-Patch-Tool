extends Control


func _ready():
	ProjectSettings.load_resource_pack("test.pck", true)
	get_tree().change_scene("res://lala/new scene.tscn")
