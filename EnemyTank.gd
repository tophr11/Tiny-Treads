extends Node2D

@export var speed: float = 95.0
@export var max_hp: float = 150.0

var hp: float = 150.0
var waypoints: Array[Vector2] = []
var current_index: int = 0
var moving: bool = false

func _ready() -> void:
	hp = max_hp

func start_path(points: Array[Vector2]) -> void:
	waypoints = points.duplicate()
	current_index = 0
	if waypoints.size() > 0:
		global_position = waypoints[0]
		current_index = 1
		moving = current_index < waypoints.size()
		if moving:
			_face_point(waypoints[current_index])

func _process(delta: float) -> void:
	if not moving or current_index >= waypoints.size():
		return

	var target_pos: Vector2 = waypoints[current_index]
	var to_target: Vector2 = target_pos - global_position
	var step: float = speed * delta

	if to_target.length() <= step:
		global_position = target_pos
		current_index += 1
		if current_index >= waypoints.size():
			moving = false
			queue_free()
		else:
			_face_point(waypoints[current_index])
	else:
		var dir: Vector2 = to_target.normalized()
		global_position += dir * step
		_face_point(target_pos)

func _face_point(point: Vector2) -> void:
	var dir: Vector2 = (point - global_position).normalized()
	if dir.length() > 0.0:
		rotation = dir.angle() + PI / 2.0

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		moving = false
		queue_free()
