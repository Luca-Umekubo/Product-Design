extends Node

var peer = ENetMultiplayerPeer.new()

func start_server(port: int, max_clients: int):
	peer.create_server(port, max_clients)
	multiplayer.multiplayer_peer = peer
	print("Server started on port ", port)

func join_server(address: String, port: int):
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	print("Connecting to ", address, ":", port)
