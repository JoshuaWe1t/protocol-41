extends Control

@onready var item_icon: TextureRect = $ItemIcon
@onready var cooldown_bar: TextureProgressBar = $ItemIcon/CooldownOverlay


var max_charges: int = 3
var current_charges: int = 3
var is_on_cooldown: bool = false

func _ready() -> void:
	Events.item_uses.connect(_on_item_uses)
	Events.item_used.connect(_on_item_used)


func _on_item_uses(item_number: int) -> void:
	pass


func _on_item_used(item_number: int) -> void:
	pass


# Вызывай эту функцию при старте игры, чтобы настроить слот
func setup(texture: Texture2D, charges: int) -> void:
	item_icon.texture = texture
	max_charges = charges
	current_charges = charges


# Вызывай эту функцию, когда игрок нажимает 1, 2 или 3
func use_item(item_number: int, cooldown_time: float) -> void:
	print("item_slot.use_item.item_number: ", item_number)
	if current_charges > 0 and not is_on_cooldown:
		current_charges -= 1
		_start_cooldown(cooldown_time)
		print("Предмет использован!")
	elif current_charges <= 0:
		print("Нет зарядов!")


func _start_cooldown(time: float) -> void:
	is_on_cooldown = true
	cooldown_bar.max_value = time
	cooldown_bar.value = time
	
	var tween = create_tween()
	tween.tween_property(cooldown_bar, "value", 0.0, time)
	
	tween.finished.connect(func(): is_on_cooldown = false)
