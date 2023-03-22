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
var spriteNode = null
var isDead:bool = false
var deathTween
var selectedTween

func onCharactersSpawned(nodes):
	characterNodes = nodes

func onAttackDamageRecieved(target, damage):
	if target != self:
		return
	currHP = currHP - damage
	hpBar.value = currHP
	hpLabel.text = str(currHP, '/', maxHP)
	if currHP <= 0:
		if selectedTween:
			selectedTween.kill()
		if tween:
			tween.kill()
		isDead = true
		Signals.emit_signal('died', self)
		deathTween = create_tween()
		deathTween.tween_property(self, 'position', Vector2(5, 5), 0.1).set_trans(Tween.TRANS_ELASTIC)
		deathTween.tween_property(self, 'position', Vector2(-5, -5), 0.1).set_trans(Tween.TRANS_ELASTIC)
		deathTween.tween_property(self, 'modulate', Color(1.5, 0.5, 0.5, 0), 0.25)
		await deathTween.finished
		self.modulate = Color(1, 1, 1, 0)


func onSelected():
	self.modulate = Color(1, 1, 1, 1)
	selectedTween = create_tween()
	selectedTween.set_loops()
	selectedTween.tween_property(self, 'modulate', Color(1.5, 1.5, 1.5), 0.5)
	selectedTween.tween_property(self, 'modulate', Color(1, 1, 1), 0.5)
	Signals.emit_signal('enemyTargeted', self)


func executeSkill(skill):
	var skillTarget = null

	if skill.target == Skill.TARGET.SINGLE:
		if skill.targetSide == Skill.TARGET_SIDE.OPPONENTS:
			var rng = RandomNumberGenerator.new()
			var targetIndex = rng.randi_range(0, len(characterNodes) - 1)
			skillTarget = characterNodes[targetIndex]

	if skill.name == 'Attack':
		var startingPosition = self.global_position
		var finalPosition = Vector2(skillTarget.global_position.x + 64, skillTarget.global_position.y)
		tween = create_tween()
		tween.tween_property(self, 'global_position', finalPosition, 0.25)
		await tween.finished
		await get_tree().create_timer(0.5).timeout
		Signals.emit_signal('attackDamageRecieve', skillTarget, attackDamage)
		tween = create_tween()
		tween.tween_property(self, 'global_position', startingPosition, 0.15)
		await tween.finished
	Signals.emit_signal('battlerFinishedTurn')


func onBattlerActivated(battler):
	if battler != self:
		return
	await get_tree().create_timer(0.2).timeout
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
	# TODO: need way to get size or position of the sprite

#	var children = self.get_children()
#	spriteNode = self.get_children().filter(
#		func(node): return node.is_class('AnimatedSprite2D')
#	)[0]
#	print(spriteNode.sprite_frames.get_frame_texture('default', 0))
#	AtlasTexture

	Signals.connect('attackDamageRecieve', onAttackDamageRecieved)
	Signals.connect('battlerActivated', onBattlerActivated)
	Signals.connect('charactersSpawned', onCharactersSpawned)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
