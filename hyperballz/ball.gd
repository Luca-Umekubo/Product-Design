extends RigidBody3D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if not multiplayer.is_server():
		return
	if body.is_in_group("players"):
		body.respawn.rpc()
		queue_free()
