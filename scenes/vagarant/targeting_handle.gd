@tool
class_name TargetingHandle extends Node

const UPDATE_SHOOT_DELAY_SEC: float = 1.0

@export var ally_parent: Node3D
@export var enemy_parent: Node3D

var allies: Array[Node3D]
var enemies: Array[Combatant]

var player: Node3D

var update_shoot_timer: float = UPDATE_SHOOT_DELAY_SEC

func _ready() -> void:
	if Engine.is_editor_hint(): return
	ally_parent.child_entered_tree.connect(_on_allies_child_entered_tree)
	#ally_parent.child_exiting_tree.connect(_on_allies_child_exiting_tree)
	enemy_parent.child_entered_tree.connect(_on_enemies_child_entered_tree)
	#enemy_parent.child_exiting_tree.connect(_on_enemies_child_exiting_tree)
	
	for ally: Node3D in ally_parent.get_children():
		allies.push_back(ally)
	
	for enemy: Combatant in enemy_parent.get_children():
		enemies.push_back(enemy)
	
	for enemy: Combatant in enemies:
		enemy.start(self)
		
	for ally: Node3D in allies:
		ally.start(self)
		
	var update_shoot_tween: Tween = create_tween().set_loops(0)
	update_shoot_tween.tween_callback(update_shooting).set_delay(UPDATE_SHOOT_DELAY_SEC)

func update_shooting() -> void:
	for enemy: Combatant in enemies:
		if not enemy: continue
		enemy.shooting_target = null
		for ally: Node3D in allies:
			if not ally or not enemy.is_shootable(ally): continue
			enemy.shooting_target = ally
			enemy.shoot(enemy.get_shot_count())
			
			if ally is Combatant:
				ally.shoot(ally.get_shot_count())
				var loser: Combatant = get_shootout_loser(enemy, ally)
				loser.is_dead = true
				
				if loser in allies:
					allies.erase(loser)
				
				else:
					enemies.erase(loser)
			
			break
			

func get_shootout_loser(shooter_a: Combatant, shooter_b: Combatant) -> Combatant:
	return shooter_a if bool(randi() % 2) else shooter_b

func get_movement_target(comb: Combatant) -> Node3D:
	var target_pool: Array[Node3D] = enemies if comb.is_ally else allies
	var closest_target: Node3D
	var closest_distance_squared: float = 0.0
	for node: Node3D in target_pool:
		var target_distance_squared: float = comb.global_position.distance_squared_to(node.global_position)
		if not closest_target or closest_distance_squared > target_distance_squared:
			closest_target = node
			closest_distance_squared = target_distance_squared
	
	return closest_target


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	update_shoot_timer -= delta
	if update_shoot_timer <= 0.0:
		update_shoot_timer += UPDATE_SHOOT_DELAY_SEC
		update_shooting()

func _on_allies_child_entered_tree(node: Node) -> void:
	assert(node is Combatant or node is VagarantPlayer)
	allies.append(node)
#
#func _on_allies_child_exiting_tree(node: Node) -> void:
	#assert(node is Combatant or node is VagarantPlayer)
	#allies.erase(node)

func _on_enemies_child_entered_tree(node: Node) -> void:
	assert(node is Combatant)
	enemies.append(node)
#
#func _on_enemies_child_exiting_tree(node: Node) -> void:
	#assert(node is Combatant)
	#enemies.erase(node)
