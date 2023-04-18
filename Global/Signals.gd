extends Node

signal positionChanged
signal slotClicked(parent, index: int, button: int)
signal inventoryInteract(inventoryData: InventoryData, index: int, button: int)
signal inventoryUpdated(inventoryData: InventoryData)
signal openedChest(items: InventoryData)
signal chestClosed(chest: Chest)
signal quitInteractingWithInventory(chest: Chest)
signal playerEntered
signal enteredDungeon
signal enterBattle
signal battleIsOver

signal enemiesSpawned
signal charactersSpawned

signal battlerActivated
signal characterActivated
signal characterWaiting
signal choosingActions
signal choseAction
signal enemyTargeted
signal selectingEnemies
signal choseEnemy

signal attackDamageDealt
signal attackDamageRecieve
signal statsChanged

signal battlerFinishedTurn

signal died
signal victory
signal gainedLoot
signal gainedExp
signal gainedCurrency
