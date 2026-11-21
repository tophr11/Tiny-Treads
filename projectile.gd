extends Node2D

var target: Node2D = null
var aim_pos: Vector2 = Vector2.ZERO
@export var speed: float = 460.0
@export var damage: float = 20.0
@export var splash_radius: float = 0.0
@export var point_radius: float = 6.0
@export var point_color: Color = Color(1.0, 0.85, 0.15, 1.0)

var enemies_parent: Node
var has_initialized: bool = false

func init_projectile(start_pos: Vector2, enemy_target: Node2D, dmg: float, blast_r: float, enemies_node: Node) -> void:
	global_position = start_pos
	target = enemy_target
	if target != null and is_instance_valid(target):
		aim_pos = target.global_position
	else:
		aim_pos = start_pos + Vector2.RIGHT * 100.0
	damage = dmg
	splash_radius = blast_r
	enemies_parent = enemies_node
	has_initialized = true
	queue_redraw()

func _process(delta: float) -> void:
	if not has_initialized:
		return

	if target != null and is_instance_valid(target) and not target.is_queued_for_deletion():
		aim_pos = target.global_position

	var to_aim: Vector2 = aim_pos - global_position
	var step: float = speed * delta

	if to_aim.length() <= max(step, 8.0):
		_on_hit()
	else:
		var dir: Vector2 = to_aim.normalized()
		global_position += dir * step
		rotation = dir.angle() - PI / 2.0
		queue_redraw()

func _on_hit() -> void:
	_spawn_hit_point(global_position)

	if enemies_parent == null or not is_instance_valid(enemies_parent):
		enemies_parent = get_tree().current_scene.get_node_or_null("Enemies")

	if splash_radius > 0.0 and enemies_parent != null and is_instance_valid(enemies_parent):
		# Euclidean Distance Formula: d = sqrt((x2 - x1)^2 + (y2 - y1)^2)
		for enemy in enemies_parent.get_children():
			if enemy == null or not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
				continue
			var dx: float = enemy.global_position.x - global_position.x
			var dy: float = enemy.global_position.y - global_position.y
			var dist: float = sqrt(dx * dx + dy * dy)
			if dist <= splash_radius:
				_apply_damage(enemy)
	elif target != null and is_instance_valid(target) and not target.is_queued_for_deletion():
		_apply_damage(target)

	queue_free()

func _apply_damage(enemy: Node) -> void:
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	elif "hp" in enemy:
		enemy.hp -= damage
		if enemy.hp <= 0:
			enemy.queue_free()

func _spawn_hit_point(hit_pos: Vector2) -> void:
	var parent_container: Node = get_parent()
	if parent_container == null:
		return
	var flash := _HitPointFlash.new()
	flash.global_position = hit_pos
	flash.color = point_color
	flash.radius = point_radius * 1.5
	parent_container.add_child(flash)

func _draw() -> void:
	# Bright bullet point core + outer glow so shots are clearly visible
	draw_circle(Vector2.ZERO, point_radius * 1.4, Color(point_color.r, point_color.g, point_color.b, 0.35))
	draw_circle(Vector2.ZERO, point_radius, point_color)

class _HitPointFlash:
	extends Node2D

	var color: Color = Color(1.0, 0.85, 0.15, 1.0)
	var radius: float = 9.0
	var life: float = 0.14

	func _process(delta: float) -> void:
		life -= delta
		if life <= 0.0:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var alpha: float = clampf(life / 0.14, 0.0, 1.0)
		draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, alpha))
