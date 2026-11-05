# res://client/scripts/ui/private_store_sign_3d.gd
# Placa 3D Flutuante de Loja Pessoal (Billboard Canônico de Lineage II)
class_name PrivateStoreSign3D
extends Node3D

enum StoreType { NONE = 0, SELL = 1, BUY = 2 }

@onready var label_title: Label3D = $LabelTitle
@onready var plaque_mesh: CSGBox3D = $PlaqueBackground

var current_type: int = StoreType.SELL
var current_title: String = "Loja Pessoal"

func _ready() -> void:
	update_visuals()

func setup(store_type: int, title: String) -> void:
	current_type = store_type
	current_title = title
	update_visuals()

func update_visuals() -> void:
	if not label_title:
		return
		
	var prefix = "[VENDA]" if current_type == StoreType.SELL else "[COMPRA]"
	label_title.text = "%s %s" % [prefix, current_title]
	
	if current_type == StoreType.SELL:
		# Cor dourada / laranja canônica de Lineage II para Venda
		label_title.modulate = Color(1.0, 0.82, 0.25, 1.0)
		label_title.outline_modulate = Color(0.2, 0.12, 0.0, 1.0)
		if plaque_mesh:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.2, 0.14, 0.05, 0.9)
			mat.metallic = 0.3
			mat.roughness = 0.5
			plaque_mesh.material = mat
	else:
		# Cor azul / ciano canônica de Lineage II para Compra
		label_title.modulate = Color(0.3, 0.85, 1.0, 1.0)
		label_title.outline_modulate = Color(0.0, 0.12, 0.25, 1.0)
		if plaque_mesh:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.05, 0.15, 0.22, 0.9)
			mat.metallic = 0.3
			mat.roughness = 0.5
			plaque_mesh.material = mat
