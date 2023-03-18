extends Node2D

class_name Character

var cursor

var charName = ''
var maxHP = 0
var currHP = 0
var maxMP = 0
var currMP = 0
var attackDamage = 0
var armor = 0
var speed = 0
var enemyTargeted

var choosableActions = [
	Enums.ACTION.ATTACKING,
	Enums.ACTION.CASTING,
	Enums.ACTION.DEFENDING,
	Enums.ACTION.USING
]
var currentAction = Enums.ACTION.WAITING

func onAttackDamageRecieved(target, damage):
	if target != self:
		return
	var damageDealt = damage - armor if damage - armor > 0 else 1
	currHP = currHP - damageDealt
	Signals.emit_signal('statsChanged', charName, 'HP', currHP, maxHP)

func onBattlerActivated(battler):
	if self != battler:
		return
	currentAction = Enums.ACTION.ACTIVE
	cursor.show()
	Signals.emit_signal('characterActivated', self)

func onEnemyTargeted(enemy):
	enemyTargeted = enemy

func onChoseAction(action, character):
	if self != character:
		return
	if action == Enums.ACTION.ATTACKING:
		Signals.emit_signal('selectingEnemies')
	currentAction = action
	cursor.hide()


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

	cursor = get_node("CursorContainer")
	cursor.hide()

	Signals.connect('battlerActivated', onBattlerActivated)
	Signals.connect('enemyTargeted', onEnemyTargeted)
	Signals.connect('choseAction', onChoseAction)
	Signals.connect('attackDamageRecieve', onAttackDamageRecieved)

	return self

func attack():
	print('attacker: ', charName)
	Signals.emit_signal('attackDamageRecieve', enemyTargeted, attackDamage)
	currentAction = Enums.ACTION.WAITING
	Signals.emit_signal('battlerFinishedTurn')

func _input(event):
	if currentAction == Enums.ACTION.WAITING:
		return
	if currentAction == Enums.ACTION.ATTACKING:
		if event.is_action_released("ui_accept"):
			attack()

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
