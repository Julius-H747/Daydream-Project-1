extends CanvasLayer

@onready var soul_label = $soul_label  # path to your Label
var soul_count = 0

func _ready() -> void:
	# Find all coins in the scene and connect their signals
	for soul in get_tree().get_nodes_in_group("Souls"):
		soul.connect("collected", Callable(self, "_on_coin_collected"))

func _on_coin_collected():
	soul_count += 1
	print("Souls collected:", soul_count)  # <- This will print in the output
	soul_label.text = "Souls: " + str(soul_count)
