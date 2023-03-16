extends Panel

class_name Statblock

func setStatsBlock(membersStats):
	var statContainer = $VBoxContainer
	var memberStatContainers = statContainer.get_children()

	for index in len(membersStats):
		var memberStats = membersStats[index]
		var barHP = memberStatContainers[index].get_node('PanelContainer/ProgressBar')
		var labelHP = memberStatContainers[index].get_node('PanelContainer/Label')
		var barMP = memberStatContainers[index].get_node('PanelContainer2/ProgressBar')
		var labelMP = memberStatContainers[index].get_node('PanelContainer2/Label')

		barHP.max_value = memberStats.maxHP
		barHP.value = memberStats.currHP
		barMP.max_value = memberStats.maxMP
		barMP.value = memberStats.currMP

		var formatText = '{curr}/{max}'
		labelHP.text = formatText.format({'curr': memberStats.currHP, 'max': memberStats.maxHP})
		labelMP.text = formatText.format({'curr': memberStats.currMP, 'max': memberStats.maxMP})
	return self

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
