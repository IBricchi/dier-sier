extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

onready var title_screen: PackedScene = load("res://UI/title_screen.tscn")

func _on_Exit_button_down():
	get_tree().change_scene_to(title_screen)
