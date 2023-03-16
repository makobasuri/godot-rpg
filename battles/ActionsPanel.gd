extends Panel

@onready var actionButtons = $Actions.get_children()

var choosingCharacter = null
var characterIsChoosingAction = false

func onCharacterActivated(character):
	choosingCharacter = character

	for idx in len(character.choosableActions):
		var possibleAction = character.choosableActions[idx]
		if possibleAction == Enums.ACTION.ATTACKING:
			actionButtons[0].show()
		if possibleAction == Enums.ACTION.CASTING:
			actionButtons[1].show()
		if possibleAction == Enums.ACTION.DEFENDING:
			actionButtons[2].show()
		if possibleAction == Enums.ACTION.USING:
			actionButtons[3].show()
	self.show()

	actionButtons.filter(
		func(item): return item.is_visible()
	)[0].grab_focus()

	characterIsChoosingAction = true

func onCharacterWaiting(character):
	if choosingCharacter == character:
		choosingCharacter = null

func onActionButtonPressed(button):
	var actionName = button.name
	var action = Enums.ACTION[actionName]
	button.release_focus()
	Signals.emit_signal('choseAction', action, choosingCharacter)

# Called when the node enters the scene tree for the first time.
func _ready():
	for idx in len(actionButtons):
		var actionButton = actionButtons[idx]

		actionButton.pressed.connect(func(): return onActionButtonPressed(actionButton))
		actionButton.hide()
	self.hide()
	Signals.connect('characterActivated', onCharacterActivated)
	Signals.connect('characterWaiting', onCharacterWaiting)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
