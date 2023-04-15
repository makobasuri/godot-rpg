extends Node

class_name DungeonBuilder

@export var numRoomTries: int

# The inverse chance of adding a connector between two regions that have
# already been joined. Increasing this leads to more loosely connected
# dungeons.
@export var extraConnectorChance = 20

# Increasing this allows rooms to be larger.
@export var roomExtraSize = 0

@export var windingPercent = 0

@export var _rooms = [] #Rect

# For each open position in the dungeon, the index of the connected region
# that that position is a part of.
var _regions = []

# The index of the current region being carved.
var _currentRegion = -1

func generate(stage):
	if stage.width % 2 == 0 || stage.height % 2 == 0:
		push_error("The stage must be odd-sized.")


	fill(Tiles.wall);
	_regions = Vector2(stage.width, stage.height)

	_addRooms();

	# Fill in all of the empty space with mazes.
	for y in range(1, bounds.height, 2):
		for x in range(1, bounds.width, 2):
			var pos = Vector2(x, y)
			if (getTile(pos) != Tiles.wall): continue
			_growMaze(pos);

	_connectRegions();
	_removeDeadEnds();

	_rooms.forEach(onDecorateRoom);

func onDecorateRoom(room):
	pass

# Implementation of the "growing tree" algorithm from here:
# http://www.astrolog.org/labyrnth/algrithm.htm.
func _growMaze(start):
	var cells = []
	var lastDir

	_startRegion();
	_carve(start);

	cells.append(start)
	while cells.isNotEmpty:
		var cell = cells.last

	# See which adjacent cells are open.
	var unmadeCells = []

	for dir in Direction.CARDINAL:
		if _canCarve(cell, dir):
			unmadeCells.add(dir)

		if unmadeCells.isNotEmpty:
		# Based on how "windy" passages are, try to prefer carving in the
		# same direction.
			if unmadeCells.contains(lastDir) && rng.range(100) > windingPercent:
				dir = lastDir
			else:
				dir = rng.item(unmadeCells)

			_carve(cell + dir)
			_carve(cell + dir * 2)

			cells.add(cell + dir * 2)
			lastDir = dir
		else:
			# No adjacent uncarved cells.
			cells.removeLast()

			# This path has ended.
			lastDir = null

# TOODO
#func connectRegions
#func addRooms

func _addJunction(pos):
	if rng.oneIn(4):

		var tileType = Tiles.floor
		if randi_range(1, 3) == 3:
			tileType = Tiles.door
		setTile(pos, tileType);
		return
	setTile(pos, Tiles.closedDoor);

func _removeDeadEnds():
	var done = false;

	while !done:
		done = true;

		for pos in bounds.inflate(-1):
			if (getTile(pos) == Tiles.wall):
				continue

			# If it only has one exit, it's a dead end.
			var exits = 0;
			for dir in Direction.CARDINAL:
				if getTile(pos + dir) != Tiles.wall:
					exits += 1

				if exits != 1:
					continue

				done = false;
				setTile(pos, Tiles.wall);

# Gets whether or not an opening can be carved from the given starting
# [Cell] at [pos] to the adjacent Cell facing [direction]. Returns `true`
# if the starting Cell is in bounds and the destination Cell is filled
# (or out of bounds).</returns>
func _canCarve(pos, direction):
	# Must end in bounds.
	if !bounds.contains(pos + direction * 3):
		return false

	# Destination must not be open.
	return getTile(pos + direction * 2) == Tiles.wall;

func _startRegion():
	_currentRegion += 1

func _carve(pos, type):
	if type == null:
		type = Tiles.floor;
	setTile(pos, type)
	_regions[pos] = _currentRegion;

func getTile(pos): return stage[pos].type;

func setTile(pos, type):
	stage[pos].type = type

func fill(tile):
	for y in range(0, stage.height):
		for x in range(0, stage.width):
			setTile(Vector2(x, y), tile)



# Randomly turns some [wall] tiles into [floor] and vice versa.
func erode(iterations, floor, wall):
	if (floor == null): floor = Tiles.floor;
	if (wall == null): wall = Tiles.wall;

	bounds = stage.bounds.inflate(-1);
	for i in range(0, iterations):
		# TODO: This way this works is super inefficient. Would be better to
		# keep track of the floor tiles near open ones and choose from them.
		var pos = rng.vecInRect(bounds);

		var here = getTile(pos);
		if (here != wall): continue

		# Keep track of how many floors we're adjacent too. We will only erode
		# if we are directly next to a floor.
		var floors = 0;

		for dir in Direction.ALL:
			var tile = getTile(pos + dir)
			if (tile == floor): floors += 1

			# Prefer to erode tiles near more floor tiles so the erosion isn't too
			# spiky.
			if (floors < 2): continue;
			if (rng.oneIn(9 - floors)): setTile(pos, floor)
