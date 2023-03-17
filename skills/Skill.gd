@tool
extends Resource

class_name Skill

enum TARGET_SIDE { FRIENDLY, OPPONENTS, SELF, ALL }
enum TARGET { SINGLE, ALL }
enum COST_TYPE { MP, HP }

@export var name: String = ''
@export var targetSide: TARGET_SIDE = TARGET_SIDE.OPPONENTS
@export var target: TARGET
@export var cost: int = 0
@export var costType: COST_TYPE
#@export var damageMin: int = 0
#@export var damageMax: int = 0
#@export var healingMin: int = 0
#@export var healingMax: int = 0
