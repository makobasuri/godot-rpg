extends Node

var xp: int = 0
var currency: int = 0
var items: Array[Item] = []
var world: String = ''
var position: Vector2 = Vector2()
var inventory: InventoryData = preload('res://items/InventoryData.tres')

var partyMembers = [
	{
		charName = 'one',
		spriteScene = 'res://chars/sprites/char_one_animated_sprite_2d.tscn',
		maxHP = 16,
		currHP = 16,
		maxMP = 4,
		currMP = 4,
		attackDamage = 6,
		armor = 2,
		speed = 3,
		level = 1,
		equipment = {
			armor = '',
			boots = '',
			handLeft = '',
			handRight = '',
			ring = '',
			amulet = ''
		}
	},
	{
		charName = 'two',
		spriteScene = 'res://chars/sprites/char_two_animated_sprite_2d.tscn',
		maxHP = 18,
		currHP = 18,
		maxMP = 2,
		currMP = 2,
		attackDamage = 5,
		armor = 3,
		speed = 2,
		level = 1
	},
	{
		charName = 'three',
		spriteScene = 'res://chars/sprites/char_three_animated_sprite_2d.tscn',
		maxHP = 12,
		currHP = 12,
		maxMP = 6,
		currMP = 6,
		attackDamage = 4,
		armor = 1,
		speed = 4,
		level = 1
	},
	{
		charName = 'four',
		spriteScene = 'res://chars/sprites/char_fout_animated_sprite_2d.tscn',
		maxHP = 10,
		currHP = 10,
		maxMP = 8,
		currMP = 8,
		attackDamage = 2,
		armor = 1,
		speed = 1,
		level = 1
	}
]

func getMember(memberName):
	return partyMembers.filter(func(member): return member.charName == memberName)[0]

var actions = {
	healHP = func(target, amount):
		target.currHP += amount
		print(target.currHP)
}
