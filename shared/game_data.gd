# res://shared/game_data.gd
# Gerenciador global de dados estáticos do jogo (Data-Driven Architecture)
extends Node

var races: Dictionary = {}
var items: Dictionary = {}
var monsters: Dictionary = {}
var skills: Dictionary = {}
var quests: Array = []
var selected_character_name: String = "Valente"
var selected_race_id: String = "human"
var selected_archetype: String = "warrior"

func get_class_display_name(r_id: String, arch: String) -> String:
	match arch:
		"mystic", "mage":
			match r_id:
				"human": return "Místico Humano"
				"light_elf": return "Mago Élfico"
				"dark_elf": return "Mago Sombrio"
				"orc": return "Xamã Orc"
				"dwarf": return "Caçador de Espólios"
				_: return "Místico"
		_:
			match r_id:
				"human": return "Guerreiro Humano"
				"light_elf": return "Guerreiro Élfico"
				"dark_elf": return "Paladino Sombrio"
				"orc": return "Guerreiro Orc"
				"dwarf": return "Artífice Anão"
				_: return "Guerreiro"

func _ready() -> void:
	load_all_data()

func load_all_data() -> void:
	races = _load_json("res://data/races.json")
	var items_doc: Dictionary = _load_json("res://data/items.json")
	if items_doc.has("items"):
		for item in items_doc["items"]:
			items[item["id"]] = item
			
	var monsters_doc: Dictionary = _load_json("res://data/monsters.json")
	if monsters_doc.has("monsters"):
		for mob in monsters_doc["monsters"]:
			monsters[mob["id"]] = mob
			
	var skills_doc: Dictionary = _load_json("res://data/skills.json")
	if skills_doc.has("skills"):
		for sk in skills_doc["skills"]:
			skills[sk["id"]] = sk
			
	var quests_doc: Dictionary = _load_json("res://data/quests.json")
	if quests_doc.has("quests"):
		quests = quests_doc["quests"]
		
	print("[GameData] Dados carregados com sucesso: ", items.size(), " itens, ", monsters.size(), " monstros, ", skills.size(), " habilidades.")

func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[GameData] Arquivo não encontrado: " + path)
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var err = json.parse(content)
	if err == OK and json.data is Dictionary:
		return json.data
	return {}

func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})

func get_monster(mob_id: String) -> Dictionary:
	return monsters.get(mob_id, {})

func get_skill(skill_id: String) -> Dictionary:
	return skills.get(skill_id, {})

func get_race(race_id: String) -> Dictionary:
	return races.get(race_id, {})
