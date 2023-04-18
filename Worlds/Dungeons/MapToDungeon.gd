extends Node3D

const Cell = preload('res://Worlds/Dungeons/Cell.tscn')
const sideTextureDir = 'res://Worlds/Dungeons/textures/rustic-brick-wall/'
const bottomTextureDir = 'res://Worlds/Dungeons/textures/concrete-architectures/'
const topTextureDir = null

@onready var mazeGenerator = $MazeGenerator
@onready var dungeonPlayer = $DungeonPlayer

const GRID_SIZE = 2

var cells = []
var usedTiles

func getOrderedTextures(path):
	if path == null: return null
	var textureDirs = {
		ao = null,
		diffuseOriginal = null,
		edge = null,
		height = null,
		normal = null
	}

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while fileName != "":
			for key in textureDirs.keys():
				if fileName.contains(key):
					textureDirs[key] = path + fileName.replace('.import', '')
			fileName = dir.get_next()
	return textureDirs

func generateMap():
	var blueprintCell = Cell.instantiate()
	add_child(blueprintCell)
	var sideTextures = getOrderedTextures(sideTextureDir)
	var bottomTextures = getOrderedTextures(bottomTextureDir)
	var topTextures = getOrderedTextures(topTextureDir)
	blueprintCell.setFaces(sideTextures, bottomTextures, topTextures)

	var tileMap = mazeGenerator.init()
	usedTiles = tileMap.getWalkableTiles()
	var startCell = blueprintCell.duplicate()
	add_child(startCell)

	startCell.translate(Vector3(tileMap.start.x * GRID_SIZE, 0, tileMap.start.y * GRID_SIZE))
	dungeonPlayer.translate(Vector3(tileMap.start.x * GRID_SIZE, dungeonPlayer.position.y, tileMap.start.y * GRID_SIZE))

	for tile in usedTiles:
		var cell = blueprintCell.duplicate()
		add_child(cell)
		cell.translate(Vector3(tile.x * GRID_SIZE, 0, tile.y * GRID_SIZE))
		cells.append(cell)
		for instancedCell in cells:
			instancedCell.updateFaces(usedTiles, GRID_SIZE)
	startCell.updateFaces(usedTiles, GRID_SIZE)
	await get_tree().create_timer(0.2).timeout
	dungeonPlayer.rotateAtStart()
