extends Node

class_name Enemy

@export var enemyName: String = ''
@export var spriteScene: AnimatedSprite2D
@export var maxHP: int = 0
var currHP: int = 0
@export var maxMP: int = 0
var currMP: int = 0
@export var attackDamage: int = 0
@export var armor: int = 0
@export var speed: int = 1

@onready var hpLabel = get_node("Control/HP Label")
@onready var hpBar = get_node("Control/HP Bar")
@onready var enemyButton = get_node("ReferenceRect/Button")

func onAttackDamageRecieved(target, attackDamage):
	if target == self:
		currHP = currHP - attackDamage
		hpBar.value = currHP
		hpLabel.text = str(currHP, '/', maxHP)

func onSelected():
	print('selected, ', self)
	Signals.emit_signal('enemyTargeted', self)

func _ready():
	currHP = maxHP
	currMP = maxMP
	hpLabel.text = str(currHP, '/', maxHP)
	hpBar.max_value = maxHP
	hpBar.value = currHP

	Signals.connect('attackDamageRecieve', onAttackDamageRecieved)
#	enemyButton.pressed.connect(onEnemyButtonFocused)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
