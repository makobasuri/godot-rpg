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
@export var skills: Array[Skill] = []

@onready var hpLabel = get_node("Control/HP Label")
@onready var hpBar = get_node("Control/HP Bar")
@onready var enemyButton = get_node("ReferenceRect/Button")

@onready var tween = null

var characterNodes = null

func onCharactersSpawned(nodes):
	characterNodes = nodes

func onAttackDamageRecieved(target, damage):
	if target == self:
		currHP = currHP - damage
		hpBar.value = currHP
		hpLabel.text = str(currHP, '/', maxHP)


func onSelected():
	self.modulate = Color(1, 1, 1, 1)
	tween = self.create_tween()
	tween.set_loops()
	tween.tween_property(self, 'modulate', Color(1.5, 1.5, 1.5, 1.5), 0.5)
	tween.tween_property(self, 'modulate', Color(1, 1, 1, 1), 0.5)
	Signals.emit_signal('enemyTargeted', self)


func executeSkill(skill):
	var skillTarget = null

	if skill.target == Skill.TARGET.SINGLE:
		if skill.targetSide == Skill.TARGET_SIDE.OPPONENTS:
			var rng = RandomNumberGenerator.new()
			var targetIndex = rng.randi_range(0, len(characterNodes) - 1)
			skillTarget = characterNodes[targetIndex]

	if skill.name == 'Attack':
		#play attack animation, wait for finish
		Signals.emit_signal('attackDamageRecieve', skillTarget, attackDamage)
	Signals.emit_signal('battlerFinishedTurn')


func onBattlerActivated(battler):
	if battler != self:
		return
	if len(skills) == 0:
		Signals.emit_signal('battlerFinishedTurn')
		return
	if len(skills) > 1:
		var rng = RandomNumberGenerator.new()
		var skillIndex = rng.randi_range(0, len(skills) - 1)
		var skill = skills[skillIndex]
		executeSkill(skill)
		return
	var skill = skills[0]
	executeSkill(skill)


func _ready():
	currHP = maxHP
	currMP = maxMP
	hpLabel.text = str(currHP, '/', maxHP)
	hpBar.max_value = maxHP
	hpBar.value = currHP

	Signals.connect('attackDamageRecieve', onAttackDamageRecieved)
	Signals.connect('battlerActivated', onBattlerActivated)
	Signals.connect('charactersSpawned', onCharactersSpawned)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
