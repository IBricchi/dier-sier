extends Node2D


var poolballsprite_res : Resource = preload("res://scenes/Poolballsprite.tscn") 
var poolball_res  : Resource = preload("res://scenes/PoolBall.tscn") 
var boss1_res : Resource = preload("res://scenes/Boss1.tscn")
var boss2_res : Resource = preload("res://scenes/Boss2.tscn")
var boss_health_bar : Resource = preload("res://scenes/Boss_health.tscn")
var boss_respawns = 1 
 
var wave_number = 0


var boss1_wave_number = 5
var boss2_wave_number = 10

export var wave_cooldown : int = 40 

func _ready():
	get_tree().paused = false
	randomize()
	state.start_timer(true)
	$SpawnTimer.wait_time = wave_cooldown
	$SpawnTimer.start()

func spawn_wave( ): 
	# maybe have a UI thing indicating the wave number 
	
	state.wave += 1 
	wave_cooldown += 4
	$SpawnTimer.wait_time = wave_cooldown
	var spawns = $Spawns.get_children() 
	spawns.shuffle()
	var spawn_num : int = min( int( (randf() * state.wave + 1)) + 1, 6)
		
	for i in range( spawn_num ) :
		var spawn_point = spawns[i]
		var init_dir = (- spawn_point.position).normalized()
		
		var poolballsprite = poolballsprite_res.instance()
		add_child(poolballsprite)
		poolballsprite.set_health( 1 + (randi() % state.wave)/ 2 )
		poolballsprite.position = spawn_point.position + $Spawns.position
		poolballsprite.velocity = (1 + randf()) * 80 * init_dir
		poolballsprite.start_spawn_anim()
		yield(get_tree().create_timer(0.5), "timeout")
	 
	yield(get_tree().create_timer(0.75), "timeout")
	var spawn_point = spawns[randi()%6]
	var init_dir = (- spawn_point.position).normalized()
	
	var poolballsprite = poolballsprite_res.instance()
	add_child(poolballsprite)
	poolballsprite.set_health( min(state.wave , 6))
	poolballsprite.position = spawn_point.position + $Spawns.position
	poolballsprite.velocity = (1 + randf()) * 100 * init_dir
	poolballsprite.start_spawn_anim()
	
	$SpawnTimer.start()
	
	
	

func spawn_rigid_poolball( pos , vel, hp) : 
	var poolball : Node
	if hp == 7 :
		poolball = boss1_res.instance()
	elif hp == 8 :
		poolball = boss2_res.instance()
	else:
		poolball  = poolball_res.instance()
		poolball.set_health(hp)
		
	add_child(poolball)
	poolball.set_linear_velocity( 1.2 * vel)
	poolball.position = pos
	
	
	
func _process(delta):
	if get_tree().get_nodes_in_group("balls").empty() and $SpawnTimer.wait_time > 2  : 
		$SpawnTimer.stop()
		$SpawnTimer.set_wait_time(1)
		$SpawnTimer.start()
		
		
	if state.win:
		win_game()	



func _on_SpawnTimer_timeout():
 
	if state.wave == boss1_wave_number:
		first_boss_battle()
	elif state.wave == boss2_wave_number:
		second_boss_battle()
	else:
		spawn_wave()

func update_health_bar(hp):

	
	if get_node("boss_health"):
		get_node("boss_health").get_child(0).value = hp
		if hp <= 0:
				get_node("boss_health").queue_free()
	elif hp > 20:
		var boss_health:Node = boss_health_bar.instance()
		boss_health.get_node("health_bar").value = hp
		add_child_below_node(get_node("tally_system"),boss_health)

func first_boss_battle():
	
	while not get_tree().get_nodes_in_group("balls").empty():
		yield(get_tree().create_timer(0.5), "timeout")
	
	var spawns = $Spawns.get_children() 
	spawns.shuffle()
	var spawn_point = spawns[0]
	var init_dir = (- spawn_point.position).normalized()
	
	var poolballsprite = poolballsprite_res.instance()
	add_child(poolballsprite)
	poolballsprite.set_health( 7 )
	
	poolballsprite.position = spawn_point.position + $Spawns.position
	poolballsprite.velocity = 180 * init_dir
	poolballsprite.start_spawn_anim()
	
 
	var boss_health:Node = boss_health_bar.instance()
	
	# boss_health.get_node("health_bar").value = poolballsprite.get("health")
	#yield(get_tree().create_timer(2), "timeout")
	add_child_below_node(get_node("tally_system"),boss_health)
	# get_node("Boss1").connect("boss_hurt", get_node("main"), "update_health_bar")
	
	update_health_bar(100)
 
	while not get_tree().get_nodes_in_group("balls").empty():
		yield(get_tree().create_timer(5), "timeout")
	
	
	
	while not get_tree().get_nodes_in_group("boss").empty():
		yield(get_tree().create_timer(2), "timeout")
		
	if boss_respawns :
		boss_respawns -= 1
	else:
		state.wave += 1
		
	$SpawnTimer.wait_time = 1	
	$SpawnTimer.start()
	
	

func second_boss_battle():
	
	
	while not get_tree().get_nodes_in_group("balls").empty():
		yield(get_tree().create_timer(0.5), "timeout")
	
	var spawns = $Spawns.get_children() 
	spawns.shuffle()
	var spawn_point = spawns[0]
	var init_dir = (- spawn_point.position).normalized()
	
	var poolballsprite = poolballsprite_res.instance()
	add_child(poolballsprite)
	poolballsprite.set_health( 8 )
	poolballsprite.position = spawn_point.position + $Spawns.position
	poolballsprite.velocity = 90 * init_dir
	poolballsprite.start_spawn_anim()
	
	# spawn health bar 
	var boss_health:Node = boss_health_bar.instance() 
	add_child_below_node(get_node("tally_system"),boss_health)
	update_health_bar(100)
	
	while not get_tree().get_nodes_in_group("balls").empty():
		yield(get_tree().create_timer(5), "timeout")
		
	while not get_tree().get_nodes_in_group("boss").empty():
		yield(get_tree().create_timer(2), "timeout")
	$SpawnTimer.wait_time = 1	
	$SpawnTimer.start()
	
	state.wave += 1
	
	

 
onready var death_popup:Node = load("res://UI/death_popup.tscn").instance()
onready var win_popup:Node = load("res://UI/win_popup.tscn").instance()
func _on_tally_system_game_over():
	var music_position = $AudioStreamPlayer.get_playback_position()
	$"AudioStreamPlayer".stop()
	$"death_sound".play()
	yield($"death_sound","finished")
	$"AudioStreamPlayer".play(music_position)
	
	$"player".queue_free()
	$".".add_child(death_popup) 

func win_game():
	$".".add_child(win_popup) 
