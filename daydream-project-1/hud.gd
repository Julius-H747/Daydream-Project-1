extends CanvasLayer

@onready var soul_label = $Souls
var soul_count = 0

func _ready() -> void:
	for soul in get_tree().get_node_count_in_group("souls"):
		soul.connect("collected", Callable(self, "_on_soul_collected"))
		
func on_soul_collected():
	soul_count += 1
	print("Soul Collected", soul_count)
	soul_label.text = "Souls: " + str(soul_count)
