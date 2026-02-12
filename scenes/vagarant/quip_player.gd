@tool
class_name QuipPlayer extends AudioStreamPlayer

const COOLDOWN_DURATION_SEC: float = 15.0
const QUIP_CHANCE_PERCENTAGE: float = 0.4

@export var congrats_pool: Array[AudioStream]
@export var dead_pool: Array[AudioStream]

var cooldown_pool: Array[AudioStream]

func _on_combatant_died(combatant: Combatant, killer: Node3D) -> void:
	if playing or (randf() > QUIP_CHANCE_PERCENTAGE): return
	
	var pool: Array[AudioStream] = get_filtered_pool(dead_pool if combatant.is_ally else congrats_pool)
	if not pool.is_empty():
		play_quip(pool.pick_random())

func play_quip(quip: AudioStream) -> void:
	assert(not playing)
	assert(not quip in cooldown_pool)
	
	stream = quip
	play()
	cooldown_pool.push_back(quip)
	create_tween().tween_callback(refresh_quip.bind(quip)).set_delay(COOLDOWN_DURATION_SEC)

func refresh_quip(quip: AudioStream) -> void:
	assert(quip in cooldown_pool)
	cooldown_pool.erase(quip)

func get_filtered_pool(pool: Array[AudioStream]) -> Array[AudioStream]:
	var result: Array[AudioStream]
	for s: AudioStream in pool:
		if s in cooldown_pool: continue
		result.push_back(s)
	return result
