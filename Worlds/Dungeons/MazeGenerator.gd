extends TileMap

class_name MazeGenerator
# will generate a maze from start to finish, using tile colors from a simple tilemap
# can mark interesting points like intersections or dead ends
# will return coords to the interesting points, when called

const tiles = {
	black = Vector2i(0, 0),
	white = Vector2i(1, 0),
	red = Vector2i(2, 0),
	blue = Vector2i(3, 0),
	green = Vector2i(4, 0),
}

enum ORIENTATION {
	PORTRAIT,
	LANDSCAPE
}

var timeSinceTick = 0.0
var tickDuration = 0.01

# use these for randomized mazes
@export var randomStartExit:bool = true
@export var mazeOrientation: ORIENTATION = ORIENTATION.LANDSCAPE

# for more fine grained control, change these
@export var width:int = 41
@export var height:int = 19

@export var startX:int = 0
@export var startY:int = 3
@export var endX:int = width - 1
@export var endY:int = height - 4

var start
var end
var xScale
var yScale

var rdf_stack = []

func rdfInit():
	var offsets = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for offset in offsets:
		var coords = Vector2i(startX + offset[0], startY + offset[1])
		var atlasCoords = get_cell_atlas_coords(0, coords)
		if atlasCoords == tiles.white:
			rdf_stack.push_back(coords)
		set_cell(0, coords, 0, tiles.green)

func rdfStep():
	if len(rdf_stack) <= 0:
		return self
	var curr = rdf_stack.pop_back()
	var next
	var found = false
	var checkOrder = [Vector2i(2, 0), Vector2i(0, 2), Vector2i(-2, 0), Vector2i(0, -2)]
	checkOrder.shuffle()
	for value in checkOrder:
		next = value
		if get_cell_atlas_coords(0, next + curr) == tiles.white:
			found = true
			break

	if found:
		rdf_stack.push_back(curr)
		set_cell(0, curr + next/2, 0, tiles.red)
		set_cell(0, curr + next, 0, tiles.green)
		set_cell(0, curr, 0, tiles.red)
		rdf_stack.push_back(curr + next)
	else:
		set_cell(0, curr, 0, tiles.blue)
		for dir in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
			if (
			get_cell_atlas_coords(0, curr + dir) == tiles.red
			&& get_cell_atlas_coords(0, curr + (dir * 2)) == tiles.blue
			):
				set_cell(0, curr + dir, 0, tiles.blue)
		if len(rdf_stack) > 0 && rdf_stack[0] != null:
			set_cell(0, rdf_stack.back(), 0, tiles.green)
	rdfStep()

func markTileSurroundedBy(excludeAtlasCoords, atlasCoordsOfAdjacents, markingAtlasCoords = tiles.green):
	var markedCells:Array[Vector2i] = []
	for x in range(width):
		for y in range(height):
			if x == 0 or y == 0 or x == width -1 or y == height -1:
				continue
			var upAtlasCoords = get_cell_atlas_coords(0, Vector2i(x, y + 1))
			var rightAtlasCoords = get_cell_atlas_coords(0, Vector2i(x + 1, y))
			var downAtlasCoords = get_cell_atlas_coords(0, Vector2i(x, y - 1))
			var leftAtlasCoords = get_cell_atlas_coords(0, Vector2i(x - 1, y))
			var adjacentTilesAtlasCoords = [
				upAtlasCoords, rightAtlasCoords, downAtlasCoords, leftAtlasCoords
			]
			var adjacentTiles = adjacentTilesAtlasCoords.filter(
				func(atlasCoords): return atlasCoords == atlasCoordsOfAdjacents
			)
			if len(adjacentTiles) == 3 && (
				get_cell_atlas_coords(0, Vector2i(x, y)) != excludeAtlasCoords
			):
				markedCells.push_back(Vector2i(x, y))
				set_cell(0, Vector2i(x, y), 0, markingAtlasCoords)
	return markedCells

func markIntersection(markingAtlasCoords = tiles.green):
	return markTileSurroundedBy(tiles.black, tiles.blue, markingAtlasCoords)

func markDeadEnds(markingAtlasCoords = tiles.green):
	return markTileSurroundedBy(tiles.black, tiles.black, markingAtlasCoords)

func getOddRandomIntRange(minNum, maxNum):
	var randomInt = randi_range(minNum, maxNum)
	if randomInt % 2 == 1:
		return randomInt
	else:
		return getOddRandomIntRange(minNum, maxNum)

func init():
	if randomStartExit:
		if mazeOrientation == ORIENTATION.PORTRAIT:
			startX = 0
			startY = getOddRandomIntRange(1, height)
			endX = width - 1
			endY = getOddRandomIntRange(1, height - 3)
		else:
			startX = getOddRandomIntRange(1, width)
			startY = 0
			endX = getOddRandomIntRange(1, width - 3)
			endY = height - 1

	start = Vector2(startX, startY)
	end = Vector2(endX, endY)
	xScale = 1280 / (width * 16.0)
	yScale = 648 / (height * 16.0)

	scale = Vector2(xScale, yScale)
	if width % 2 != 1:
		width -= 1
	if height % 2 != 1:
		width -= 1

	for x in range(width):
		for y in range(height):
			if x == 0 or y == 0 or x == width -1 or y == height -1:
				set_cell(0, Vector2i(x, y), 0, tiles.black)
			elif x % 2 == 0 or y % 2 == 0:
				set_cell(0, Vector2i(x, y), 0, tiles.black)
			else:
				set_cell(0, Vector2i(x, y), 0, tiles.white)
	set_cell(0, start, 0, tiles.red)
	set_cell(0, end, 0, tiles.red)
	rdfInit()
	rdfStep()
	if len(getWalkableTiles()) == 0:
		print('start coords: ', startX, ' ', startY)
#		rdfInit()
#		rdfStep()
	return self

func getWalkableTiles():
	var walkableTiles = []
	for x in range(width):
		for y in range(height):
			if x == 0 or y == 0 or x == width -1 or y == height -1:
				continue
			if get_cell_atlas_coords(0, Vector2i(x, y)) == tiles.blue:
				walkableTiles.push_back(Vector2i(x, y))
	return walkableTiles

# for debugging:
#func _ready():
#	init()
