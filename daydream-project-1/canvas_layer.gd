extends CanvasLayer

@onready var soul_label = $Label  # update if deeper in hierarchy

func _ready() -> void:
	# Set starting text from Globals
	soul_label.text = "Souls: " + str(Globals.soul_count)
	
	# Connect signals from all coins in group
	for coin in get_tree().get_nodes_in_group("Souls"):
		coin.connect("collected", Callable(self, "_on_soul_collected"))

func _on_soul_collected():
	Globals.soul_count += 1
	print("Souls collected:", Globals.soul_count)
	soul_label.text = "Souls: " + str(Globals.soul_count)
