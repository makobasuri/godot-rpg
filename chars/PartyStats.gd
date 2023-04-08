extends Node

var xp: int = 0
var currency: int = 0
var items: Array[Item] = []
var world: String = ''
var position: Vector2 = Vector2()
var inventory: InventoryData = preload('res://items/InventoryData.tres')
var partyMemberOneInventory: InventoryDataEquip = preload('res://items/PartyMemberOneEquipment.tres')
var partyMemberTwoInventory: InventoryDataEquip = preload('res://items/PartyMemberTwoEquipment.tres')
var partyMemberThreeInventory: InventoryDataEquip = preload('res://items/PartyMemberThreeEquipment.tres')
var partyMemberFourInventory: InventoryDataEquip = preload('res://items/PartyMemberFourEquipment.tres')

var baseStats = {
	currHP = 8,
	maxHP = 8,
	currMP = 0,
	maxMP = 0,
	HPregen = 0,
	MPregen = 0,
	damageMin = 0,
	damageMax = 1,
	spellDamageMin = 0,
	spellDamageMax = 0,
	armor = 0,
	speed = 1,
	level = 1,
	fireRes = 0,
	coldRes = 0,
	lightningRes = 0,
	criticalChance = 0,
	criticalMultiplier = 100,
	increases = [],
	buffs = [],
	debuffs = [],
}

var partyMembers = [
	{
		charName = 'Niira',
		spriteScene = 'res://chars/sprites/char_one_animated_sprite_2d.tscn',
		strength = 16,
		dexterity = 14,
		mind = 10,
		statsBeforeEquipment = {},
		equipment = partyMemberOneInventory
	},
	{
		charName = 'Nai',
		spriteScene = 'res://chars/sprites/char_two_animated_sprite_2d.tscn',
		strength = 18,
		dexterity = 10,
		mind = 8,
		statsBeforeEquipment = {},
		equipment = partyMemberTwoInventory
	},
	{
		charName = 'Naevis',
		spriteScene = 'res://chars/sprites/char_three_animated_sprite_2d.tscn',
		strength = 8,
		dexterity = 20,
		mind = 10,
		statsBeforeEquipment = {},
		equipment = partyMemberThreeInventory
	},
	{
		charName = 'Braern',
		spriteScene = 'res://chars/sprites/char_fout_animated_sprite_2d.tscn',
		strength = 8,
		dexterity = 12,
		mind = 18,
		statsBeforeEquipment = {},
		equipment = partyMemberFourInventory
	}
]

var calcStatFuncs = {
	maxHP = func(member): return baseStats.maxHP + (floor(member.strength / 4)),
	currHP = func(member): return baseStats.maxHP + (floor(member.strength / 4)),
	maxMP = func(member): return baseStats.maxMP + (floor(member.mind / 4)),
	currMP = func(member): return baseStats.maxMP + (floor(member.mind / 4)),
	damageMin = func(member):
		return baseStats.damageMin + (floor(member.strength / 8)) + + (floor(member.dexterity / 8)),
	damageMax = func(member):
		return baseStats.damageMax + (floor(member.strength / 8)) + + (floor(member.dexterity / 8)),
	spellDamageMax = func(member): return baseStats.spellDamageMax + (floor(member.mind / 4)),
	armor = func(member): return baseStats.armor + (floor(member.strength / 8)),
	speed = func(member): return baseStats.speed + (floor(member.dexterity / 16)),
	criticalChance = func(member): return baseStats.criticalChance + (floor(member.dexterity / 16))
}

func getMember(memberName):
	return partyMembers.filter(func(member): return member.charName == memberName)[0]

func getMemberOfInventory(inventory):
	return partyMembers.filter(func(member): return member.equipment == inventory)[0]

func healHP(target, amount):
	target.currHP += amount
	if target.currHP > target.maxHP:
		target.currHP = target.maxHP
func healMP(target, amount):
	target.currMP += amount
	if target.currMP > target.maxMP:
		target.currMP = target.maxMP
func rollAttackDamage(member):
	return randi_range(member.damageMin, member.damageMax)
func rollSpellDamage(member):
	return randi_range(member.spellDamageMin, member.spellDamageMax)

var actions = {
	healHP = healHP,
	healMP = healMP,
	rollAttackDamage = rollAttackDamage,
	rollSpellDamage = rollSpellDamage,
}

func onInventoryUpdated(inventoryData, parent):
	if inventoryData is InventoryDataEquip:
		var member = getMemberOfInventory(inventoryData)
		applyEquipmentStats(member)
		Signals.emit_signal('statsChanged', member)

func calcStats(member):
	for stat in baseStats:
		if stat in calcStatFuncs:
			member.statsBeforeEquipment[stat] = calcStatFuncs[stat].call(member)
		else:
			member.statsBeforeEquipment[stat] = baseStats[stat]

func applyEquipmentStats(member):
	for stat in member.statsBeforeEquipment:
		member[stat] = member.statsBeforeEquipment[stat]
	for data in member.equipment.slotData:
		if data:
			for prop in data.get_property_list():
				if prop.name in member && typeof(data[prop.name]) == TYPE_INT:
					member[prop.name] += data[prop.name]

func _ready():
	# check if savedata, else calcStats()
	for member in partyMembers:
		calcStats(member)
		applyEquipmentStats(member)
	Signals.connect('inventoryUpdated', onInventoryUpdated)
