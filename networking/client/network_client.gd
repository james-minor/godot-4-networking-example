# +--------------------------------------------------------------------------+
# | Copyright 2022 James Minor                                               |
# |                                                                          |
# | Licensed under the MIT License (the "License"); you may not use this     |
# | file except in compliance with the license. You can obtain a copy of the |
# | License at:                                                              |
# |  https://mit-license.org/                                                |
# |   OR                                                                     |
# |  The file "license.txt" located at the root directory of this repository |
# |                                                                          |
# | I'd love some public credit if this gets used in a project!              |
# | If you've found this project useful (and you have the means), I'd        |
# | appreciate if you could buy me a coffee :)                               |
# |  https://www.buymeacoffee.com/jamesminor                                 |
# +--------------------------------------------------------------------------+

extends Node
class_name NetworkClient

const DEFAULT_PORT: int = 8989

# Reference to the Client Multiplayer API
var client_multiplayer_api: MultiplayerAPI

func _ready() -> void:
	client_multiplayer_api = MultiplayerAPI.create_default_interface()
	
	# Connecting client signals.
	client_multiplayer_api.peer_connected.connect(_on_network_peer_connected)
	client_multiplayer_api.peer_disconnected.connect(_on_network_peer_disconnected)
	client_multiplayer_api.connected_to_server.connect(_on_connection_ok)
	client_multiplayer_api.connection_failed.connect(_on_connection_fail)
	client_multiplayer_api.server_disconnected.connect(_on_server_disconnect)
	
	get_tree().set_multiplayer(client_multiplayer_api, self.get_path())


func _process(_delta: float) -> void:
	# Ensures that the client multiplayer API service is being polled for
	# network events.
	client_multiplayer_api.poll()


# Attempts to connect the client API to a passed server and port. Will return
# true if the client peer was successfully created.
# 
# address  The target IP address to connect to.
# port     The target port to connect to.
func connect_to_server(address: String = "127.0.0.1", port: int = DEFAULT_PORT) -> bool:
	print("CLIENT: Attempting to create network client for %s:%s..." % [address, port])
	
	# Ensuring a server connection does not already exist.
	if client_multiplayer_api.has_multiplayer_peer():
		client_multiplayer_api.multiplayer_peer.close()
	
	# Creating and validating the network peer.
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("CLIENT: Could not create network client for %s:%s, aborting..." % [address, port])
		return false
	
	# Connecting network peer to server network API.
	client_multiplayer_api.multiplayer_peer = peer
	
	print("CLIENT: Successfully created network client for %s:%s..." % [address, port])
	return true


# Gets called when ANY client connects to the connected server. It is important
# to note that this will be called for every client that is already connected
# to a server when joining, including the server.
func _on_network_peer_connected(peer_id: int) -> void:
	print("CLIENT: Network peer %s has connected to the server..." % peer_id)


# Gets called when ANY client disconnects from the connected server.
func _on_network_peer_disconnected(peer_id: int) -> void:
	print("CLIENT: Network peer %s has disconnected from the server..." % peer_id)


# Gets called when the client successfully connects to a server.
func _on_connection_ok() -> void:
	print("CLIENT: Successfully connected to the game server.")


# Gets called when the client successfully disconnects from a server.
func _on_connection_fail() -> void:
	print("CLIENT: Failed to connect to the game server.")


# Gets called when a server disconnects from the client.
func _on_server_disconnect() -> void:
	print("CLIENT: Server has disconnected.")
