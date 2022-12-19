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
class_name NetworkServer

# Default port to run a server on.
const DEFAULT_PORT: int = 8989

# Reference to the Server Multiplayer API
var server_multiplayer_api: MultiplayerAPI

func _ready() -> void:
	server_multiplayer_api = MultiplayerAPI.create_default_interface()
	
	# Connecting server signals.
	server_multiplayer_api.peer_connected.connect(_on_network_peer_connected)
	server_multiplayer_api.peer_disconnected.connect(_on_network_peer_disconnected)
	
	get_tree().set_multiplayer(server_multiplayer_api, self.get_path())

func _process(_delta: float) -> void:
	# Ensures that the server multiplayer API service is being polled for
	# network events.
	server_multiplayer_api.poll()

# Attempts to start a server on a designated port. If no port is provided will
# start a server on the DEFAULT_PORT. Will return true if the server was
# successfully created.
func start_server(port: int = DEFAULT_PORT) -> bool:
	print("SERVER: Attempting to create game server on port %s..." % port)
	
	# Ensuring a server connection does not already exist.
	if server_multiplayer_api.has_multiplayer_peer():
		server_multiplayer_api.multiplayer_peer.close()
	
	# Creating and validating the network peer.
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		print("SERVER: Could not create a game server on port %s, aborting..." % port)
		return false
	
	# Connecting network peer to server network API.
	server_multiplayer_api.multiplayer_peer = peer
	
	print("SERVER: Successfully created game server on port %s!" % port)
	return true

# Gets called when a client connects to the server.
func _on_network_peer_connected(peer_id: int) -> void:
	print("SERVER: Network peer %s has connected to the server..." % peer_id)

# Gets called when a client disconnects from the server.
func _on_network_peer_disconnected(peer_id: int) -> void:
	print("SERVER: Network peer %s has disconnected from the server..." % peer_id)
