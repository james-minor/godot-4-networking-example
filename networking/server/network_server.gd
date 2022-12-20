# ┌──────────────────────────────────────────────────────────────────────────┐
# │ Copyright 2022 James Minor                                               │
# │                                                                          │
# │ Licensed under the MIT License (the "License"); you may not use this     │
# │ file except in compliance with the license. You can obtain a copy of the │
# │ License at:                                                              │
# │  https://mit-license.org/                                                │
# │   OR                                                                     │
# │  The file "LICENSE" located at the root directory of this repository     │
# │                                                                          │
# │ I'd love some public credit if this gets used in a project!              │
# │ If you've found this project useful (and you have the means), I'd        │
# │ appreciate if you could buy me a coffee :)                               │
# │  https://www.buymeacoffee.com/jamesminor                                 │
# └──────────────────────────────────────────────────────────────────────────┘
extends Node

## An interface for handling network client connections in Godot.
## 
## Implements a custom [MultiplayerAPI] for a network client.
## Useful for allowing simultaneous client and server networking on the same
## game instance, allowing for easy scalability and maintainability between 
## singleplayer and multiplayer modes.
class_name NetworkServer

## Default port to open the server on.
const DEFAULT_PORT: int = 8989

## Default number of maximum simultaneous connections to the server.
const DEFAULT_MAX_PEERS: int = 16

## Reference to the custom Server MultiplayerAPI. See [MultiplayerAPI] for
## more information on how custom multiplayer is implemented.
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


## Attempts to start a server on a designated port, [code]port[/code] with an 
## amount of maximum simultaneous connections, [code]max_peers[/code]. If no
## port is provided the server will open on port [constant DEFAULT_PORT]. If
## max_peers is not given the server will have [constant DEFAULT_MAX_PEERS]
## maximum simultaneous connections. Will return [code]true[/code] if the server
## was successfully created, otherwise returns [code]false[/code]
func start_server(
		port: int = DEFAULT_PORT, 
		max_peers: int = DEFAULT_MAX_PEERS
	) -> bool:
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


## Gets called when a client connects to the server. [code]peer_id[/code]
## will be the [b]network ID[/b] of the connected peer.
func _on_network_peer_connected(peer_id: int) -> void:
	print("SERVER: Network peer %s has connected to the server..." % peer_id)
	
	var player_node = load("res://scenes/player/player.tscn").instantiate()
	player_node.name = str(peer_id)
	player_node.position = Vector3(0, 1, 0)
	
	get_node("./MultiplayerSpawner").add_child(player_node)


## Gets called when a client disconnects from the server. [code]peer_id[/code]
## will be the [b]network ID[/b] of the disconnected peer.
func _on_network_peer_disconnected(peer_id: int) -> void:
	print("SERVER: Network peer %s has disconnected from the server..." % peer_id)
