extends Node3D

class_name Cell

@onready var bottom: MeshInstance3D = $bottom
@onready var top: MeshInstance3D = $top
@onready var left: MeshInstance3D = $left
@onready var right: MeshInstance3D = $right
@onready var front: MeshInstance3D = $front
@onready var back: MeshInstance3D = $back

var faceIdxToHide = 0
var sideFaces

func updateFaces(cellList, gridSize):
	var myGridPosition = Vector2i(position.x / gridSize, position.z / gridSize)
	if cellList.has(myGridPosition + Vector2i.RIGHT):
		right.hide()
	if cellList.has(myGridPosition + Vector2i.LEFT):
		left.hide()
	if cellList.has(myGridPosition + Vector2i.DOWN):
		back.hide()
	if cellList.has(myGridPosition + Vector2i.UP):
		front.hide()

const nameToMaterialName = {
	ao = 'ao_texture',
	diffuseOriginal = 'albedo_texture',
	edge = 'roughness_texture',
	height = 'heightmap_texture',
	normal = 'normal_texture'
}

func setFaces(sideTextures, bottomTextures, topTextures):
	sideFaces = [ left, right, front, back ]
	for key in sideTextures.keys():
		if sideTextures[key] != null:
			for face in sideFaces:
				face.get_surface_override_material(0)[nameToMaterialName[key]] = load(sideTextures[key])
	for key in bottomTextures.keys():
		if bottomTextures[key] != null:
			bottom.get_surface_override_material(0)[nameToMaterialName[key]] = load(bottomTextures[key])
			if topTextures == null:
				top.get_surface_override_material(0)[nameToMaterialName[key]] = load(bottomTextures[key])
	if topTextures == null:
		return
	for key in topTextures.keys():
		if topTextures[key] != null:
			top.get_surface_override_material(0)[nameToMaterialName[key]] = load(topTextures[key])

func _input(_event):
	if Input.is_action_pressed('ui_cancel'):
		if left && faceIdxToHide == 0:
			left.hide()
			faceIdxToHide += 1
			return
		if right && faceIdxToHide == 1:
			right.hide()
			faceIdxToHide += 1
			return
		if front && faceIdxToHide == 2:
			front.hide()
			faceIdxToHide += 1
			return
