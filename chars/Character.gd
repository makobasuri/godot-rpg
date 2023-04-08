extends Node2D

class_name Character

var cursor
var enemyTargeted
var stats = null

var choosableActions = [
	Enums.ACTION.ATTACKING,
	Enums.ACTION.CASTING,
	Enums.ACTION.DEFENDING,
	Enums.ACTION.USING
]
var currentAction = Enums.ACTION.WAITING
var tween
var damageTween
var deathTween
var globalPosition
var isDead

func onDamageRecieved(damage):
	stats.currHP = stats.currHP - damage
	if tween:
		tween.kill()
	if damageTween:
		damageTween.kill()
	if stats.currHP <= 0:
		isDead = true
		Signals.emit_signal('died', self)
		# TODO: deathanimation
		deathTween = create_tween()
		deathTween.tween_property(self, 'position', Vector2(5, 5), 0.1).set_trans(Tween.TRANS_ELASTIC)
		deathTween.tween_property(self, 'position', Vector2(-5, -5), 0.1).set_trans(Tween.TRANS_ELASTIC)
		deathTween.parallel().tween_property(self, 'modulate', Color(1.5, 0.5, 0.5, 0), 0.25)
		await deathTween.finished
		self.modulate = Color(1, 1, 1, 0)
	else:
		damageTween = create_tween()
		damageTween.tween_property(self, 'position', Vector2(-3, 0), 0.05).set_trans(Tween.TRANS_ELASTIC)
		damageTween.parallel().tween_property(self, 'modulate', Color(1.5, 1.5, 1.5), 0.1)
		damageTween.tween_property(self, 'modulate', Color(0.8, 0.8, 0.8), 0.1)
		damageTween.tween_property(self, 'position', Vector2(3, 0), 0.05).set_trans(Tween.TRANS_ELASTIC)
		damageTween.parallel().tween_property(self, 'modulate', Color(1.5, 1.5, 1.5), 0.1)
		damageTween.tween_property(self, 'modulate', Color(1, 1, 1), 0.1)

func onAttackDamageRecieved(target, damage):
	if target != self:
		return
	var trueDamageRecieved = damage - stats.armor if damage - stats.armor > 0 else 1
	onDamageRecieved(trueDamageRecieved)
	Signals.emit_signal('statsChanged', stats)

func onBattlerActivated(battler):
	if self != battler:
		return
	currentAction = Enums.ACTION.ACTIVE
	cursor.show()
	Signals.emit_signal('characterActivated', self)

func onEnemyTargeted(enemy):
	if !enemy:
		return
	enemyTargeted = enemy

func onChoseAction(action, character):
	if self != character:
		return
	if action == Enums.ACTION.ATTACKING:
		Signals.emit_signal('selectingEnemies')
	currentAction = action
	cursor.hide()

func onVictory():
	# TODO: victoryanimations
	cursor.hide()
	tween = create_tween()
	tween.tween_property(self, 'position', Vector2(0, -5), 0.2)
	tween.tween_property(self, 'position', Vector2(0, 20), 0.4).set_trans(Tween.TRANS_ELASTIC)


func init(passedStats):
	stats = passedStats

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
	Signals.connect('victory', onVictory)

	return self

func attack():
	var startingPosition = self.global_position
	var finalPosition = Vector2(enemyTargeted.global_position.x - 64, enemyTargeted.global_position.y - 1)
	tween = self.create_tween()
	currentAction = Enums.ACTION.WAITING
	tween.tween_property(self, 'global_position', finalPosition, 0.25)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	var damage = PartyStats.rollAttackDamage(stats)
	Signals.emit_signal('attackDamageRecieve', enemyTargeted, damage)
	tween = self.create_tween()
	tween.tween_property(self, 'global_position', startingPosition, 0.15)
	await tween.finished
	Signals.emit_signal('battlerFinishedTurn')
	Signals.emit_signal('choseEnemy')
#
#func healHP(value):
#	print('healed')
#	stats.currHP += value

func _input(event):
	if currentAction == Enums.ACTION.WAITING:
		return
	if currentAction == Enums.ACTION.ATTACKING:
		if event.is_action_released("ui_accept"):
			attack()
