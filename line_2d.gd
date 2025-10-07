extends Line2D

@export var segment_length: float = 10
@export var speed: float = 500
@export var points_count: int = 40
@export var min_x: float = 0
@export var min_y: float = 0
@export var max_x: float = 582
@export var max_y: float = 323

@export var eye_offset: float = 10
@export var eye_forward_offset: float = -20

@onready var eye_left = preload("res://eyeball.tscn").instantiate()
@onready var eye_right = preload("res://eyeball.tscn").instantiate()

@export var has_eyes: bool = true

var snake_points: Array = []

func _ready():
	for i in range(points_count):
		snake_points.append(Vector2(-i * segment_length, 0))
	points = snake_points
	
	if has_eyes:
		add_child(eye_left)
		add_child(eye_right)

func _process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		snake_points[0] += input_vector * speed * delta
	
	snake_points[0].x = clamp(snake_points[0].x, min_x, max_x)
	snake_points[0].y = clamp(snake_points[0].y, min_y, max_y)

	for i in range(1, snake_points.size()):
		var dir = snake_points[i] - snake_points[i - 1]
		var distance = dir.length()
		if distance > segment_length:
			dir = dir.normalized()
			snake_points[i] = snake_points[i - 1] + dir * segment_length

	points = snake_points

	if has_eyes and snake_points.size() > 1:
		var head_pos = to_global(snake_points[0])
		var neck_pos = to_global(snake_points[1])
		var head_dir = (head_pos - neck_pos).normalized()
		var perp = Vector2(-head_dir.y, head_dir.x)
		eye_left.global_position = head_pos + head_dir * eye_forward_offset + perp * eye_offset
		eye_right.global_position = head_pos + head_dir * eye_forward_offset - perp * eye_offset

		if input_vector.length() > 0:
			var angle = input_vector.angle() + PI
			eye_left.rotation = angle
			eye_right.rotation = angle
