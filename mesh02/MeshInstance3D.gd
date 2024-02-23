@tool
extends MeshInstance3D

@export var x_size: int = 20
@export var z_size: int = 20
@export_range(1, 100, 1, 'suffix:vert/m') var resolution: float = 1
@export var update: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_terrain()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if update:
		generate_terrain()
		update = false

func generate_terrain():
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in z_size * resolution + 1:
		for x in x_size * resolution + 1:
			var z_offset := -z_size / 2.0
			var x_offset := -x_size / 2.0
			var v := Vector3(x * (1 / resolution) + x_offset, 0, z * (1 / resolution) + z_offset)
			st.add_vertex(v)
	
	var idx = 0
	for z in z_size * resolution:
		for x in x_size * resolution:
			st.add_index(idx + 0)
			st.add_index(idx + 1)
			st.add_index(idx + x_size * resolution + 1)
			
			st.add_index(idx + x_size * resolution + 1)
			st.add_index(idx + 1)
			st.add_index(idx + x_size * resolution + 2)
			
			idx += 1
		idx += 1
		
	mesh = st.commit()
