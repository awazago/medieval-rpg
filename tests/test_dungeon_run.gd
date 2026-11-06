extends SceneTree

func _init() -> void:
	print("--- Starting 2D Dungeon Gameplay Verification ---")
	call_deferred("run_test")

func run_test() -> void:
	var main_scene = load("res://src/scenes/main.tscn")
	if not main_scene:
		printerr("FAIL: Could not load main.tscn")
		quit(1)
		return
		
	var main_node = main_scene.instantiate()
	root.add_child(main_node)
	
	# Process multiple frames
	for frame in range(40):
		await process_frame
		
	print("Main scene initialized successfully!")
	var player = main_node.get_node_or_null("Player")
	if not player:
		printerr("FAIL: Player node not found!")
		quit(1)
		return
	print("Player found at position: ", player.global_position)
	print("Player HP: ", player.hp, " Stamina: ", player.stamina, " Level: ", player.level)
	
	var dungeon = main_node.get_node_or_null("Dungeon")
	if not dungeon:
		printerr("FAIL: Dungeon node not found!")
		quit(1)
		return
		
	var enemies = dungeon.get_node("Enemies").get_children()
	print("Spawned enemies count: ", enemies.size())
	assert(enemies.size() >= 5, "Enemies count should be at least 5")
	
	var props = dungeon.get_node("Props").get_children()
	print("Spawned props & torches count: ", props.size())
	assert(props.size() >= 10, "Props count should be at least 10")
	
	# Test Player attacking
	print("Testing sword attack...")
	player.perform_attack()
	
	for frame in range(15):
		await process_frame
		
	# Test Player taking damage and healing
	print("Testing damage & heal...")
	player.take_damage(20)
	assert(player.hp == 80, "Player HP should be 80 after 20 damage")
	player.heal(15)
	assert(player.hp == 95, "Player HP should be 95 after 15 heal")
	
	# Test Gold & XP
	player.add_gold(10)
	assert(player.gold == 10, "Player gold should be 10")
	player.add_xp(120) # Level up trigger
	assert(player.level == 2, "Player should be level 2 after 120 XP")
	print("Level Up successful! Level: ", player.level, " Max HP: ", player.max_hp)
	
	# Capture screenshot
	var img = root.get_texture().get_image()
	if img:
		var err = img.save_png("/tmp/screen_2d_dungeon.png")
		if err == OK:
			print("Screenshot captured successfully to /tmp/screen_2d_dungeon.png")
			
	print("--- ALL 2D DUNGEON GAMEPLAY TESTS PASSED! ---")
	quit(0)
