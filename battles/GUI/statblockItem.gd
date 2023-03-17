extends HBoxContainer

@onready var partyMemberLabel = $PartyMemberLabel
@onready var barHP = $PanelContainerHP/ProgressBarHP
@onready var labelHP = $PanelContainerHP/LabelHP
@onready var barMP = $PanelContainerMP/ProgressBarMP
@onready var labelMP = $PanelContainerMP/LabelMP

func init(memberName, currHP, maxHP, currMP, maxMP):
	partyMemberLabel.text = memberName
	barHP.max_value = maxHP
	barHP.value = currHP
	barMP.max_value = maxMP
	barMP.value = currMP

	var formatText = '{curr}/{max}'
	labelHP.text = formatText.format({'curr': currHP, 'max': maxHP})
	labelMP.text = formatText.format({'curr': currMP, 'max': maxMP})
	return self

func onStatsChanged(charName, stat, value, maxValue = 0):
	if charName != partyMemberLabel.text:
		return

	if stat == 'HP':
		barHP.value = value
		barHP.max_value = maxValue
		var formatText = '{curr}/{max}'
		labelHP.text = formatText.format({'curr': value, 'max': maxValue})
	if stat == 'MP':
		barMP.value = value
		barMP.max_value = maxValue
		var formatText = '{curr}/{max}'
		labelMP.text = formatText.format({'curr': value, 'max': maxValue})

func _ready():
	Signals.connect('statsChanged', onStatsChanged)
