extends Node

enum ACTION { WAITING, ACTIVE, ATTACKING, CASTING, DEFENDING, USING }
enum SLOTS { HAND_RIGHT, RING, ARMOR, BOOTS, AMULET, HAND_LEFT }
enum EFFECT_TYPE { HEAL }
enum DAMAGE_TYPE { FIRE, COLD, LIGHTNING, PHYSICAL }
const damageTypes:= {
	fire = 0,
	cold = 1,
	lightning = 2,
	physical = 3
}

# this doesnt work:
#func getDamageType(str):
#	return DAMAGE_TYPE[damageTypes[str]]
#
#func _ready():
#	print(getDamageType('fire'))

# maybe like this instead:
const STATE := {
	IDLE = "IDLE",
	JUMPING = "JUMPING",
	FALLING = "FALLING",
	ATTACKING = "ATTACKING",
}

#print(STATE.IDLE) # "IDLE"
