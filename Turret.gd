extends Node2D

@export var is_cannon: bool = false
@export var attack_range: float = 220.0
@export var damage: float = 25.0
@export var fire_cooldown: float = 0.75
@export var splash_radius: float = 65.0
@export var projectile_scene: PackedScene
@export var draw_range_ring: bool = true

var cooldown_left: float = 0.0
var enemies_parent: Node2D
var projectiles_parent: Node2D

func setup_turret(enemies_node: Node2D, proj_node: Node2D) -> void:
	enemies_parent = enemies_node
	projectiles_parent = proj_node
	if is_cannon:
		attack_range = 145.0
		damage = 35.0
		fire_cooldown = 1.3
	else:
		attack_range = 230.0
		damage = 22.0
		fire_cooldown = 0.7
		splash_radius = 0.0
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
		# Distance formula: d = sqrt((x2 - x1)^2 + (y2 - y1)^2)
		var dx: float = enemy.global_position.x - global_position.x
		var dy: float = enemy.global_position.y - global_position.y
		var dist: float = sqrt(dx * dx + dy * dy)

		if dist <= attack_range and dist < min_dist:
			min_dist = dist
			closest = enemy

	return closest

func _fire(target: Node2D) -> void:
	if projectile_scene == null or not is_instance_valid(projectiles_parent):
		return
	var proj = projectile_scene.instantiate()
	projectiles_parent.add_child(proj)
	proj.init_projectile(global_position, target, damage, splash_radius, enemies_parent)

func _draw() -> void:
	if draw_range_ring:
		draw_arc(Vector2.ZERO, attack_range, 0.0, TAU, 64, Color(0.2, 0.9, 1.0, 0.45), 2.0)
