extends Node2D
class_name Dungeon

const TILE_SIZE: int = 32

const SLIME_SCENE = preload("res://src/scenes/enemy_slime.tscn")
const SKELETON_SCENE = preload("res://src/scenes/enemy_skeleton.tscn")
const BOSS_SCENE = preload("res://src/scenes/boss_necromancer.tscn")
const POT_SCENE = preload("res://src/scenes/prop_pot.tscn")
const CHEST_SCENE = preload("res://src/scenes/prop_chest.tscn")
const TORCH_SCENE = preload("res://src/scenes/torch.tscn")
const TILES_TEX = preload("res://assets/sprites/tiles_dungeon.png")

@onready var floors_node: Node2D = $Floors
@onready var walls_node: Node2D = $Walls
@onready var props_node: Node2D = $Props
@onready var enemies_node: Node2D = $Enemies

# Dungeon Grid: 0 = Wall, 1 = Cobblestone Floor, 2 = Mossy Floor
var grid: Dictionary = {}
const GRID_W: int = 42
const GRID_H: int = 44

func _ready() -> void:
	generate_dungeon_layout()
	build_visuals_and_collisions()
	spawn_entities()

func generate_dungeon_layout() -> void:
	# Default all to Wall (0)
	for x in range(GRID_W):
		for y in range(GRID_H):
			grid[Vector2i(x, y)] = 0
			
	# Room 1: Entrance Hall (y: 32..40, x: 14..28)
	carve_room(14, 32, 28, 40, 1)
	
	# Corridor 1: (y: 24..32, x: 19..23)
	carve_corridor(19, 24, 23, 32, 1)
	
	# Room 2: Crypt of Bones (y: 14..24, x: 8..34)
	carve_room(8, 14, 34, 24, 2)
	
	# Corridor 2: Sanctum Gate (y: 8..14, x: 19..23)
	carve_corridor(19, 8, 23, 14, 1)
	
	# Room 3: Boss Sanctum of Malakor (y: -4..8, x: 6..36)
	carve_room(6, -4, 36, 8, 2)

func carve_room(x1: int, y1: int, x2: int, y2: int, floor_type: int) -> void:
	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			grid[Vector2i(x, y)] = floor_type

func carve_corridor(x1: int, y1: int, x2: int, y2: int, floor_type: int) -> void:
	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			grid[Vector2i(x, y)] = floor_type

func is_floor(cell: Vector2i) -> bool:
	return grid.get(cell, 0) > 0

func build_visuals_and_collisions() -> void:
	# Find bounds
	var min_x = 0
	var max_x = GRID_W
	var min_y = -6
	var max_y = GRID_H + 2
	
	for x in range(min_x, max_x):
		for y in range(min_y, max_y):
			var cell = Vector2i(x, y)
			var world_pos = Vector2(x * TILE_SIZE + TILE_SIZE * 0.5, y * TILE_SIZE + TILE_SIZE * 0.5)
			
			if is_floor(cell):
				# Create Floor Tile
				var spr = Sprite2D.new()
				spr.texture = TILES_TEX
				spr.region_enabled = true
				if grid[cell] == 2:
					# Mossy floor (0, 32, 32, 32)
					spr.region_rect = Rect2(0, 32, 32, 32)
				else:
					# Cobblestone (32, 0, 32, 32)
					spr.region_rect = Rect2(32, 0, 32, 32)
				spr.position = world_pos
				spr.z_index = -10
				floors_node.add_child(spr)
			else:
				# Check if this wall borders any floor cell (only render wall perimeter)
				var borders_floor = false
				for ox in [-1, 0, 1]:
					for oy in [-1, 0, 1]:
						if is_floor(Vector2i(x + ox, y + oy)):
							borders_floor = true
							break
					if borders_floor:
						break
						
				if borders_floor:
					# Wall StaticBody2D with collision
					var wall_body = StaticBody2D.new()
					wall_body.collision_layer = 2
					wall_body.collision_mask = 7
					wall_body.position = world_pos
					
					var spr = Sprite2D.new()
					spr.texture = TILES_TEX
					spr.region_enabled = true
					# Wall face (0, 0, 32, 32)
					spr.region_rect = Rect2(0, 0, 32, 32)
					wall_body.add_child(spr)
					
					var col = CollisionShape2D.new()
					var shape = RectangleShape2D.new()
					shape.size = Vector2(TILE_SIZE, TILE_SIZE)
					col.shape = shape
					wall_body.add_child(col)
					
					walls_node.add_child(wall_body)

func spawn_entities() -> void:
	# Torches in Entrance Room
	add_torch(Vector2(16 * TILE_SIZE, 33 * TILE_SIZE))
	add_torch(Vector2(26 * TILE_SIZE, 33 * TILE_SIZE))
	add_torch(Vector2(16 * TILE_SIZE, 39 * TILE_SIZE))
	add_torch(Vector2(26 * TILE_SIZE, 39 * TILE_SIZE))
	
	# Torches in Crypt
	add_torch(Vector2(10 * TILE_SIZE, 15 * TILE_SIZE))
	add_torch(Vector2(32 * TILE_SIZE, 15 * TILE_SIZE))
	add_torch(Vector2(10 * TILE_SIZE, 23 * TILE_SIZE))
	add_torch(Vector2(32 * TILE_SIZE, 23 * TILE_SIZE))
	
	# Torches in Boss Sanctum
	add_torch(Vector2(8 * TILE_SIZE, -3 * TILE_SIZE))
	add_torch(Vector2(34 * TILE_SIZE, -3 * TILE_SIZE))
	add_torch(Vector2(8 * TILE_SIZE, 6 * TILE_SIZE))
	add_torch(Vector2(34 * TILE_SIZE, 6 * TILE_SIZE))
	add_torch(Vector2(21 * TILE_SIZE, -3 * TILE_SIZE))
	
	# Entrance Props: Pots & Starter Chest
	add_chest(Vector2(16 * TILE_SIZE, 38 * TILE_SIZE))
	add_pot(Vector2(25 * TILE_SIZE, 38 * TILE_SIZE))
	add_pot(Vector2(26 * TILE_SIZE, 38 * TILE_SIZE))
	add_pot(Vector2(26 * TILE_SIZE, 37 * TILE_SIZE))
	
	# Crypt Props & Loot
	add_chest(Vector2(10 * TILE_SIZE, 16 * TILE_SIZE))
	add_chest(Vector2(32 * TILE_SIZE, 16 * TILE_SIZE))
	add_pot(Vector2(12 * TILE_SIZE, 22 * TILE_SIZE))
	add_pot(Vector2(30 * TILE_SIZE, 22 * TILE_SIZE))
	
	# Crypt Enemies (Slimes & Skeletons)
	add_slime(Vector2(15 * TILE_SIZE, 20 * TILE_SIZE))
	add_slime(Vector2(27 * TILE_SIZE, 20 * TILE_SIZE))
	add_slime(Vector2(21 * TILE_SIZE, 18 * TILE_SIZE))
	add_skeleton(Vector2(13 * TILE_SIZE, 17 * TILE_SIZE))
	add_skeleton(Vector2(29 * TILE_SIZE, 17 * TILE_SIZE))
	add_skeleton(Vector2(21 * TILE_SIZE, 15 * TILE_SIZE))
	
	# Corridor Guards
	add_skeleton(Vector2(21 * TILE_SIZE, 10 * TILE_SIZE))
	
	# Boss Sanctum: Boss Malakor
	var boss = BOSS_SCENE.instantiate()
	boss.position = Vector2(21 * TILE_SIZE, 1 * TILE_SIZE)
	enemies_node.add_child(boss)
	
	# Boss Sanctum Royal Chests
	add_chest(Vector2(10 * TILE_SIZE, -2 * TILE_SIZE))
	add_chest(Vector2(32 * TILE_SIZE, -2 * TILE_SIZE))

func add_torch(pos: Vector2) -> void:
	var t = TORCH_SCENE.instantiate()
	t.position = pos
	props_node.add_child(t)

func add_pot(pos: Vector2) -> void:
	var p = POT_SCENE.instantiate()
	p.position = pos
	props_node.add_child(p)

func add_chest(pos: Vector2) -> void:
	var c = CHEST_SCENE.instantiate()
	c.position = pos
	props_node.add_child(c)

func add_slime(pos: Vector2) -> void:
	var s = SLIME_SCENE.instantiate()
	s.position = pos
	enemies_node.add_child(s)

func add_skeleton(pos: Vector2) -> void:
	var sk = SKELETON_SCENE.instantiate()
	sk.position = pos
	enemies_node.add_child(sk)
