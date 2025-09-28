extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var attack = false
var attack_timer = 0.0
var player_health = 100
var max_health = 100
var target_health = 100
var invincible = false
var invincible_timer = 0.0

var enemy_health = {}
var enemy_health_bars = {}

func _ready():
	print("Player ready - enemy detection enabled")
	print("Player Health: ", player_health)

func _physics_process(delta: float) -> void:
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false
			print("Player no longer invincible")
	
	# Keep the death check
	if player_health <= 0 and target_health <= 0:
		player_died()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("z"):
		attack = true
		attack_timer = 0.0
		print("Attack started!")
		
		var animated_sprite = find_animated_sprite()
		if animated_sprite:
			animated_sprite.play("attack")
	
	if attack:
		attack_timer += delta
		if attack_timer >= 0.2:
			print("Attack hitting - checking for enemies...")
			check_enemy_collisions()
			attack = false
			attack_timer = 0.0
	else:
		handle_movement_animations()
	
	check_enemy_damage()
	
	update_enemy_health_bars()
	
	move_and_slide()

func find_animated_sprite():
	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = get_node_or_null("AnimatedSprite")
	if not sprite:
		for child in get_children():
			if child is AnimatedSprite2D:
				sprite = child
				break
	return sprite

func handle_movement_animations():
	var animated_sprite = find_animated_sprite()
	if not animated_sprite:
		return
	
	if velocity.y == 0:
		if velocity.x != 0:
			animated_sprite.play("walk")
			animated_sprite.flip_h = velocity.x < 0
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")
		if not "-" in str(velocity.y):
			animated_sprite.play("fall")

func check_enemy_collisions():
	print("=== CHECKING FOR ENEMY COLLISIONS ===")
	
	var area_node = get_node_or_null("Area2D")
	if not area_node:
		print("ERROR: Area2D node not found!")
		return
	
	var overlapping_bodies = area_node.get_overlapping_bodies()
	print("Overlapping bodies count: ", overlapping_bodies.size())
	
	for body in overlapping_bodies:
		print("Found overlapping body: ", body.name, " (", body.get_class(), ")")
		
		if body.is_in_group("enemies") or body.is_in_group("enemy"):
			damage_enemy(body)
	
	if overlapping_bodies.size() == 0:
		print("NO overlapping bodies found")
		test_distance_based_attack()
	
	print("=== END COLLISION CHECK ===")

func damage_enemy(enemy):
	var enemy_name = enemy.name
	
	if not enemy_health.has(enemy_name):
		enemy_health[enemy_name] = 3
		print("New enemy tracked: ", enemy_name, " with 3 health")
	
	enemy_health[enemy_name] -= 1
	print("Hit enemy: ", enemy_name, " - Health remaining: ", enemy_health[enemy_name])
	
	update_enemy_health_bar(enemy)
	
	flash_enemy_red(enemy)
	
	if enemy_health[enemy_name] <= 0:
		print("Enemy killed: ", enemy_name)
		enemy_health.erase(enemy_name)
		remove_enemy_health_bar(enemy)
		enemy.visible = false
		enemy.queue_free()
	else:
		print("Enemy ", enemy_name, " survives with ", enemy_health[enemy_name], " health")

func flash_enemy_red(enemy):
	if enemy.has_method("modulate"):
		var original_color = enemy.modulate
		enemy.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(enemy):
			enemy.modulate = original_color

func check_enemy_damage():
	if invincible:
		return
	
	var area_node = get_node_or_null("Area2D")
	if not area_node:
		return
	
	var overlapping_bodies = area_node.get_overlapping_bodies()
	for body in overlapping_bodies:
		if (body.is_in_group("enemies") or body.is_in_group("enemy")) and body != self:
			take_damage(10, body)
			break

func take_damage(damage_amount, enemy = null):
	if invincible:
		return
	
	print("TAKING DAMAGE: ", damage_amount)
	
	# Reduce BOTH target health AND current health immediately
	target_health -= damage_amount
	player_health -= damage_amount
	
	if target_health < 0:
		target_health = 0
	if player_health < 0:
		player_health = 0
	
	print("Health after damage - player_health: ", player_health, " target_health: ", target_health)
	
	# Set invincibility
	invincible = true
	invincible_timer = 1.0
	
	# Flash player red
	flash_player_red()
	
	# Check if player should die
	if target_health <= 0:
		player_died()

func flash_player_red():
	var animated_sprite = find_animated_sprite()
	if animated_sprite:
		var original_color = animated_sprite.modulate
		animated_sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(animated_sprite):
			animated_sprite.modulate = original_color

func player_died():
	print("Game Over! Player will respawn or return to main menu...")
	
	# Keep the health bar visible but show death message
	show_death_message()
	
	await get_tree().create_timer(3.0).timeout
	
	# Option 1: Respawn player (uncomment this if you want respawning)
	# respawn_player()
	
	# Option 2: Return to main menu (current behavior)
	if get_tree().current_scene.scene_file_path != "":
		var main_menu_path = "res://main_menu.tscn"
		if ResourceLoader.exists(main_menu_path):
			get_tree().change_scene_to_file(main_menu_path)
		else:
			print("Main menu scene not found at: ", main_menu_path)
			get_tree().reload_current_scene()
	else:
		print("No scene file found, quitting game")
		get_tree().quit()

func show_death_message():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 1000
	get_tree().current_scene.add_child(canvas_layer)
	
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(background)
	
	var death_label = Label.new()
	death_label.text = "YOU DIED\n\nReturning to Main Menu..."
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_label.add_theme_font_size_override("font_size", 32)
	death_label.add_theme_color_override("font_color", Color.RED)
	canvas_layer.add_child(death_label)

func test_distance_based_attack():
	var all_enemies = get_tree().get_nodes_in_group("enemies") + get_tree().get_nodes_in_group("enemy")
	
	for enemy in all_enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < 80:
			damage_enemy(enemy)
			break

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	print("Body entered area: ", body.name, " - Groups: ", body.get_groups())
	
	var layer3 = get_node_or_null("TileMapLayer3")
	var layer4 = get_node_or_null("TileMapLayer4")
	
	if layer3:
		layer3.set_layer_enabled(1, false)
	if layer4:
		layer4.set_layer_enabled(1, true)

func create_enemy_health_bar(enemy):
	var enemy_name = enemy.name
	
	if enemy_health_bars.has(enemy_name):
		return
	
	var health_container = Control.new()
	health_container.size = Vector2(60, 12)
	
	var health_bg = ColorRect.new()
	health_bg.color = Color.BLACK
	health_bg.size = Vector2(60, 12)
	health_container.add_child(health_bg)
	
	var health_fill = ColorRect.new()
	health_fill.color = Color.RED
	health_fill.position = Vector2(1, 1)
	health_fill.size = Vector2(58, 10)
	health_container.add_child(health_fill)
	
	get_tree().current_scene.add_child(health_container)
	
	enemy_health_bars[enemy_name] = {
		"container": health_container,
		"fill": health_fill
	}

func update_enemy_health_bar(enemy):
	var enemy_name = enemy.name
	if not enemy_health_bars.has(enemy_name):
		return
	
	var health_bar_data = enemy_health_bars[enemy_name]
	var health_fill = health_bar_data["fill"]
	
	var current_health = enemy_health.get(enemy_name, 3)
	var health_percentage = float(current_health) / 3.0
	
	health_fill.size.x = 58 * health_percentage
	
	if health_percentage > 0.66:
		health_fill.color = Color.GREEN
	elif health_percentage > 0.33:
		health_fill.color = Color.YELLOW
	else:
		health_fill.color = Color.RED

func remove_enemy_health_bar(enemy):
	var enemy_name = enemy.name
	if enemy_health_bars.has(enemy_name):
		var health_bar_data = enemy_health_bars[enemy_name]
		if is_instance_valid(health_bar_data["container"]):
			health_bar_data["container"].queue_free()
		enemy_health_bars.erase(enemy_name)

func update_enemy_health_bars():
	var all_enemies = get_tree().get_nodes_in_group("enemies") + get_tree().get_nodes_in_group("enemy")
	
	for enemy in all_enemies:
		if not is_instance_valid(enemy):
			continue
		
		var enemy_name = enemy.name
		var distance = global_position.distance_to(enemy.global_position)
		
		if distance < 120:
			if not enemy_health_bars.has(enemy_name):
				create_enemy_health_bar(enemy)
				if not enemy_health.has(enemy_name):
					enemy_health[enemy_name] = 3
			
			update_enemy_health_bar(enemy)
			
			if enemy_health_bars.has(enemy_name):
				var health_container = enemy_health_bars[enemy_name]["container"]
				if is_instance_valid(health_container):
					var camera = get_viewport().get_camera_2d()
					if camera:
						var screen_pos = enemy.global_position - camera.global_position + Vector2(get_viewport().size) / 2
						health_container.position = screen_pos + Vector2(-30, -50)
					else:
						health_container.position = enemy.global_position + Vector2(-30, -50)
					
					health_container.visible = true
		else:
			if enemy_health_bars.has(enemy_name):
				var health_container = enemy_health_bars[enemy_name]["container"]
				if is_instance_valid(health_container):
					health_container.visible = false

# Optional respawn function
func respawn_player():
	player_health = max_health
	target_health = max_health
	invincible = false
	invincible_timer = 0.0
	
	print("Player respawned with full health!")

# Optional: Add a healing function for testing
func heal(amount):
	target_health += amount
	player_health += amount
	if target_health > max_health:
		target_health = max_health
	if player_health > max_health:
		player_health = max_health
	print("Player healed for ", amount, ". Health: ", target_health)
