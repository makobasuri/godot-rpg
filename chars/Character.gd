extends Node2D

class_name Character

var charName = ''
var maxHP = 0
var currHP = 0
var maxMP = 0
var currMP = 0
var attackDamage = 0
var armor = 0
var speed = 0
var enemyTargeted
var isActive = false
var isAttacking = false

func onAttackDamageRecieved():
	print('hello')

func onEnemyTargeted(enemy):
	enemyTargeted = enemy
	print(enemyTargeted)

func init(stats):
	charName = stats.charName
	maxHP = stats.maxHP
	currHP = stats.currHP
	maxMP = stats.maxMP
	currMP = stats.currMP
	attackDamage = stats.attackDamage
	armor = stats.armor
	speed = stats.speed

	var placeHolderSprite = get_node('AnimatedSprite2D')
	remove_child(placeHolderSprite)

	var spriteScene = load(stats.spriteScene).instantiate()
	add_child(spriteScene)
	add_to_group('character')

	Signals.connect('enemyTargeted', onEnemyTargeted)
	Signals.connect('attackDamageRecieve', onAttackDamageRecieved)

	return self

func attack():
	Signals.emit_signal('attackDamageRecieve', enemyTargeted, attackDamage)

func test():
	print('jo', maxHP)

func _input(event):
	if !isActive:
		return
	if isAttacking:
		if event.is_action_pressed("ui_accept"):
			attack()

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
