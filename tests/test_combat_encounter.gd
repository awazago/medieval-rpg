extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var main_scene = load("res://src/scenes/main.tscn")
	var main_node = main_scene.instantiate()
	root.add_child(main_node)
	
	for frame in range(10):
		await process_frame
		
	var player = main_node.get_node("Player")
	var dungeon = main_node.get_node("Dungeon")
	var enemies = dungeon.get_node("Enemies")
	
	# Spawn a slime right in front of player
	var slime_scene = load("res://src/scenes/enemy_slime.tscn")
	var slime = slime_scene.instantiate()
	slime.position = player.global_position + Vector2(24, 0)
	enemies.add_child(slime)
	
	# Spawn a pot nearby
	var pot_scene = load("res://src/scenes/prop_pot.tscn")
	var pot = pot_scene.instantiate()
	pot.position = player.global_position + Vector2(0, -28)
	dungeon.get_node("Props").add_child(pot)
	
	# Player swings sword towards slime
	player.perform_attack()
	
	for frame in range(10):
		await process_frame
		
	# Break pot
	pot.break_prop()
	
	for frame in range(15):
		await process_frame
		
	# Capture screenshot with combat vfx
	var img = root.get_texture().get_image()
	if img:
		img.save_png("/tmp/screen_2d_combat.png")
		print("Combat screenshot saved to /tmp/screen_2d_combat.png")
		
	print("Combat encounter test complete!")
	quit(0)
