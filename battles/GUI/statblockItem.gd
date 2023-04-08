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

func onStatsChanged(stats):
	if stats.charName != partyMemberLabel.text:
		return
	barHP.value = stats.currHP
	barHP.max_value = stats.maxHP
	barMP.value = stats.currMP
	barMP.max_value = stats.maxMP
	var formatText = '{curr}/{max}'
	labelHP.text = formatText.format({'curr': stats.currHP, 'max': stats.maxHP})
	labelMP.text = formatText.format({'curr': stats.currMP, 'max': stats.maxMP})

func _ready():
	Signals.connect('statsChanged', onStatsChanged)
