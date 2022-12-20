# ┌──────────────────────────────────────────────────────────────────────────┐
# │ Copyright 2022 James Minor                                               │
# │                                                                          │
# │ Licensed under the MIT License (the "License"); you may not use this     │
# │ file except in compliance with the license. You can obtain a copy of the │
# │ License at:                                                              │
# │  https://mit-license.org/                                                │
# │                                                                          │
# │ Buy me a coffee: https://www.buymeacoffee.com/jamesminor                 │
# └──────────────────────────────────────────────────────────────────────────┘

## An interface for handling network client connections in Godot. Inherits from
## [NetworkBase].
## 
## Implements a custom [MultiplayerAPI] for a network server.
## Useful for allowing simultaneous client and server networking on the same
## game instance, allowing for easy scalability and maintainability between 
## singleplayer and multiplayer modes.
## [br][b]See:[/b] [NetworkBase]
class_name NetworkServer
extends NetworkBase

## Default number of maximum simultaneous connections to the server.
const DEFAULT_MAX_PEERS: int = 16

func _ready() -> void:
	multiplayer_api = MultiplayerAPI.create_default_interface()
	
	# Connecting server networking signals.
	multiplayer_api.peer_connected.connect(_on_network_peer_connected)
	multiplayer_api.peer_disconnected.connect(_on_network_peer_disconnected)
	
	set_network_root()


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
	if multiplayer_api.has_multiplayer_peer():
		multiplayer_api.multiplayer_peer.close()
	
	# Creating and validating the network peer.
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_peers)
	if error != OK:
		print("SERVER: Could not create a game server on port %s, aborting..." % port)
		return false
	
	# Connecting network peer to server network API.
	multiplayer_api.multiplayer_peer = peer
	
	print("SERVER: Successfully created game server on port %s!" % port)
	return true


## Gets called when a client connects to the server. [code]peer_id[/code]
## will be the [b]network ID[/b] of the connected peer.
func _on_network_peer_connected(peer_id: int) -> void:
	print("SERVER: Network peer %s has connected to the server..." % peer_id)


## Gets called when a client disconnects from the server. [code]peer_id[/code]
## will be the [b]network ID[/b] of the disconnected peer.
func _on_network_peer_disconnected(peer_id: int) -> void:
	print("SERVER: Network peer %s has disconnected from the server..." % peer_id)
