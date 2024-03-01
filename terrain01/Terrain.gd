@tool
extends MeshInstance3D

@export var seed := "happy seed"
@export var x_size := 20
@export var z_size := 20
@export var center := true
@export_range(1, 100, 1, "suffix:vert/m") var resolution := 1
@export var update := false

var rng := RandomNumberGenerator.new()
@onready var grid := grid_definition()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.seed = hash(seed)
	generate_terrain()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if update:
		grid = grid_definition()
		generate_terrain()
		update = false

func generate_terrain():
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in z_size * resolution + 1:
		for x in x_size * resolution + 1:
			var z_offset := 0.0
			var x_offset := 0.0
			if center:
				z_offset = -z_size / 2.0
				x_offset = -x_size / 2.0
			
			var z_pos := z * (1.0 / resolution) + z_offset
			var y_pos := perlin_noise(x * (1.0 / resolution), z * (1.0 / resolution))
			var x_pos := x * (1.0 / resolution) + x_offset
			
			var p = Vector3(x_pos, y_pos, z_pos)
			st.add_vertex(p)
 	
	var idx := 0
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
	
	st.generate_normals()
	mesh = st.commit()
	
	
func grid_definition() -> PackedVector2Array:
	var arr := PackedVector2Array()
	for z in z_size + 1:
		for x in x_size + 1:
			var theta := rng.randf() * 2 * PI
			var v := Vector2(cos(theta), sin(theta)).normalized()
			arr.append(v)
	return arr

func perlin_noise(x: float, z: float) -> float:
	var p := Vector2(x, z)
	var c0 := Vector2(floorf(x), floorf(z))
	var c1 := Vector2(floorf(x), ceilf(z))
	var c2 := Vector2(ceilf(x), floorf(z))
	var c3 := Vector2(ceilf(x), ceilf(z))
	
	var s := row_major_index(c0.x, c1.y).dot(p - c0)
	var t := row_major_index(c1.x, c1.y).dot(p - c1)
	var u := row_major_index(c2.x, c2.y).dot(p - c2)
	var v := row_major_index(c3.x, c3.y).dot(p - c3)
	
	var sx := smoothstep(0, 1, p.x - c0.x)
	var a := lerpf(s, t, sx)
	var b := lerpf(u, v, sx)
	
	var sy := smoothstep(0, 1, p.y - c0.y)
	return lerpf(a, b, sy)

func row_major_index(x:int, z:int) -> Vector2:
	return grid[x + x_size * z]
