extends Node2D

class_name Char

var maxHP = 0
var currHP = 0
var maxMP = 0
var currMP = 0
var attackDamage = 0
var armor = 0
var speed = 0

func init(stats):
	maxHP = stats.maxHP
	currHP = stats.currHP
	maxMP = stats.maxMP
	currMP = stats.currMP
	attackDamage = stats.attackDamage
	armor = stats.armor
	speed = stats.speed
	
	var spriteScene = load(stats.spriteScene).instantiate()
	add_child(spriteScene)
	add_to_group('character')
	
	return self
	
func test():
	print('jo', maxHP)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
