extends Camera2D

@onready var ship = get_node("/root/main/Ship")

func _process(_delta):
	global_position = ship.global_position
