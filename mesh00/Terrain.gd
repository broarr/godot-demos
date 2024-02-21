@tool
extends MeshInstance3D

@export var x_size:int = 200
@export var z_size:int = 200
@export var update := false
@export var clear := false

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_terrain() # Replace with function body.
	
func _process(_delta:float):
	if update:
		generate_terrain()
		update = false

func generate_terrain() -> void:
	var st := SurfaceTool.new()

	# NOTE (@broarr): The surface tool generates meshes for us. It basically has
	#                 two main arrays the vertex array and the index array.
	#
	#                 The vertex array contains the positions of each of the
	#                 verticies of the mesh
	#
	#                 The offset array is an array of vertices. The offset array
	#                 determines the winding of the triangles. This is super
	#                 important for generating terrain.
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Create a 2D array of vertexes
	for z: int in z_size + 1:
		for x: int in x_size + 1:
			st.add_vertex(Vector3(x, 0, z))


	# Create the index array
	var idx := 0
	for _z: int in z_size:
		for _x: int in x_size:
			print(Vector2(_x, _z))
			# NOTE (@broarr): Generate a single quad based on the index of the
			#                 vertex we're on. On my newb eyes, it looks like
			#                 this should require more indexes, but this is
			#                 sufficient. Here's an example:
			#
			#                  A --- B
			#                  |   / |
			#                  |  /  |
			#                  | /   |
			#                  C --- D
			#
			#                 Given the rectangle ABCD, we have two triangles,
			#                 DCB and BCA. Godot uses a clockwise winding for
			#                 the triangles. We're defining the triangle, not
			#                 the edges. Edges might look like BCAB where we go
			#                 from B to C, C to A, A to B. But since we're
			#                 defining triagles we can give the vertexes (in the
			#                 right winding order) and the drivers will handle
			#                 drawing the edges
			#
			#                 The order DCB, BCA is how the code below builds
			#                 the triangles
			st.add_index(idx + 0)
			st.add_index(idx + 1)
			st.add_index(idx + x_size + 1)
			
			st.add_index(idx + x_size + 1)
			st.add_index(idx + 1)
			st.add_index(idx + x_size + 2)
			
			idx += 1
		# NOTE (@broarr): This extra incerment is to bump us to the next line up
		#                 e.g. The next triangles will start with BAx where x is
		#                 the theoretical vertex above B.
		idx += 1
	
	mesh = st.commit()
