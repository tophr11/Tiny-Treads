extends Node2D

@export var attack_range: float = 240.0
@export var damage: float = 55.0
@export var fire_cooldown: float = 0.85
@export var splash_radius: float = 0.0
@export var projectile_scene: PackedScene
@export var draw_range_ring: bool = true

var cooldown_left: float = 0.0
var enemies_parent: Node2D
var projectiles_parent: Node2D

func setup_turret(enemies_node: Node2D, proj_node: Node2D) -> void:
	enemies_parent = enemies_node
	projectiles_parent = proj_node
	queue_redraw()

func _process(delta: float) -> void:
	if cooldown_left > 0.0:
		cooldown_left -= delta

	var target: Node2D = _find_nearest_enemy()
	if target != null:
		var dir: Vector2 = (target.global_position - global_position).normalized()
		rotation = dir.angle() - PI / 2.0
		if cooldown_left <= 0.0:
			_fire(target)
			cooldown_left = fire_cooldown

func _find_nearest_enemy() -> Node2D:
	if not is_instance_valid(enemies_parent):
		return null

	var closest: Node2D = null
	var min_dist: float = INF

	for enemy in enemies_parent.get_children():
		# Euclidean Distance Formula: d = sqrt((x2 - x1)^2 + (y2 - y1)^2)
		var dx: float = enemy.global_position.x - global_position.x
		var dy: float = enemy.global_position.y - global_position.y
		var dist: float = sqrt(dx * dx + dy * dy)

		if dist <= attack_range and dist < min_dist:
			min_dist = dist
			closest = enemy

	return closest

func _fire(target: Node2D) -> void:
	if projectile_scene == null:
		return
	if not is_instance_valid(projectiles_parent):
		projectiles_parent = get_tree().current_scene.get_node_or_null("Projectiles")
	if not is_instance_valid(projectiles_parent):
		return

	var proj = projectile_scene.instantiate()
	projectiles_parent.add_child(proj)
	var enemies_ref := enemies_parent if is_instance_valid(enemies_parent) else get_tree().current_scene.get_node_or_null("Enemies")
	proj.init_projectile(global_position, target, damage, splash_radius, enemies_ref)

func _draw() -> void:
	if draw_range_ring:
		draw_arc(Vector2.ZERO, attack_range, 0.0, TAU, 64, Color(1.0, 0.75, 0.2, 0.45), 2.0)
