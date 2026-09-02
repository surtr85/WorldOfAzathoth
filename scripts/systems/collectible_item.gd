class_name CollectibleItem
extends Area2D
## Item pickup script for weapons, abilities, keys, and collectibles.

enum ItemType {
	WEAPON,
	ABILITY,
	KEY,
	CONSUMABLE,
	LORE_FRAGMENT,
}

@export var item_type: ItemType = ItemType.CONSUMABLE
@export var item_id: String = "health_potion"
@export var item_name: String = "Health Potion"
@export var description: String = "Restores 30 HP"
@export var value: int = 30

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		_collect(body)

func _collect(player: Node2D) -> void:
	match item_type:
		ItemType.WEAPON:
			if GameManager:
				GameManager.unlock_weapon(item_id)
				GameManager.equip_weapon(item_id)
		ItemType.ABILITY:
			if GameManager:
				GameManager.unlock_ability(item_id)
		ItemType.KEY:
			if GameManager:
				GameManager.add_to_inventory(item_id)
		ItemType.CONSUMABLE:
			if item_id.begins_with("health") and player.has_method("heal"):
				player.heal(value)
		ItemType.LORE_FRAGMENT:
			if GameManager:
				GameManager.add_lore_fragment(item_id)
	
	queue_free()
