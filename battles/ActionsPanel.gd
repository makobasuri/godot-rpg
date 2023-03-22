extends Panel

@onready var actionButtons = $Actions.get_children()
@onready var actionsCursor = $ActionsCursor

var choosingCharacter = null
var characterIsChoosingAction = false

func onFocusChanged(control:Control):
	if control == null:
		actionsCursor.hide()
	if len(actionButtons.filter(func(button): return button == control)) > 0:
		actionsCursor.global_position.y = control.global_position.y + 16


func onCharacterActivated(character):
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

	var focusableButton = actionButtons.filter(
		func(item): return item.is_visible()
	)[0]
	actionsCursor.show()
	focusableButton.grab_focus()
	characterIsChoosingAction = true
	choosingCharacter = character

func onCharacterWaiting(character):
	if choosingCharacter == character:
		choosingCharacter = null

func onActionButtonPressed(button):
	if choosingCharacter == null:
		return
	button.release_focus()
	actionsCursor.hide()
	var actionName = button.name
	var action = Enums.ACTION[actionName]
	Signals.emit_signal('choseAction', action, choosingCharacter)

# Called when the node enters the scene tree for the first time.
func _ready():
	# perhaps solve with signal
	for idx in len(actionButtons):
		var actionButton = actionButtons[idx]

		actionButton.pressed.connect(func(): return onActionButtonPressed(actionButton))
		actionButton.hide()
	self.hide()
	get_viewport().connect("gui_focus_changed", onFocusChanged)
	Signals.connect('characterActivated', onCharacterActivated)
	Signals.connect('characterWaiting', onCharacterWaiting)

