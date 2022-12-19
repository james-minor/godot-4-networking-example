extends Node3D

var client: NetworkClient
var server: NetworkServer

func _ready() -> void:
	# Getting references to networking nodes.
	server = get_node("NetworkServer")
	client = get_node("NetworkClient")
	
	# Starts the client + server.
	server.start_server()
	client.connect_to_server()
