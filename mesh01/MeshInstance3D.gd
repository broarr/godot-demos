@tool
extends MeshInstance3D

@export var x_size := 20
@export var z_size := 20
@export var update := false

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_terrain()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float):
	if update:
		generate_terrain()
		update = false

func generate_terrain() -> void:
	var st := SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Create the vertex array
	for z in z_size + 1:
		for x in x_size + 1:
			var x_offset := -x_size/2.0
			var z_offset := -z_size/2.0
			var vertex := Vector3(x + x_offset, 0, z + z_offset)
			st.add_vertex(vertex)
	
	# Create the index array
	var idx := 0
	for z in z_size:
		for x in x_size:
			st.add_index(idx + 0)
			st.add_index(idx + 1)
			st.add_index(idx + x_size + 1)
			
			st.add_index(idx + x_size + 1)
			st.add_index(idx + 1)
			st.add_index(idx + x_size + 2)
			
			idx += 1
		idx += 1
		
	mesh = st.commit()
