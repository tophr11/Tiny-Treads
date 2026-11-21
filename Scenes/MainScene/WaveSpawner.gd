extends Node2D

@export var tank_scene: PackedScene
@export var wave_1_tank_count: int = 5
@export var spawn_interval: float = 1.2

var waypoints: Array[Vector2] = []
var spawned_in_wave: int = 0

@onready var waypoints_node: Node2D = $Waypoints
@onready var enemies_node: Node2D = $Enemies
@onready var projectiles_node: Node2D = $Projectiles
@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_label: Label = $UI/HUD/InfoBar/H/WaveLabel

func _ready() -> void:
	for child in waypoints_node.get_children():
		if child is Marker2D:
			waypoints.append(child.global_position)

	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_spawn_single_tank)

	_setup_all_turrets(self)
	_update_wave_ui(0)

	# Auto-start Wave 1 shortly after the scene loads
	await get_tree().create_timer(0.5).timeout
	_spawn_single_tank()

func _setup_all_turrets(node: Node) -> void:
	for child in node.get_children():
		if child.has_method("setup_turret"):
			child.setup_turret(enemies_node, projectiles_node)
		_setup_all_turrets(child)

func _spawn_single_tank() -> void:
	if spawned_in_wave >= wave_1_tank_count or tank_scene == null:
		return

	var tank = tank_scene.instantiate()
	enemies_node.add_child(tank)
	tank.start_path(waypoints)

	spawned_in_wave += 1
	_update_wave_ui(spawned_in_wave)

	if spawned_in_wave < wave_1_tank_count:
		spawn_timer.start(spawn_interval)

func _update_wave_ui(spawned_count: int) -> void:
	if wave_label != null:
		wave_label.text = "Wave 1: %d / %d" % [spawned_count, wave_1_tank_count]
