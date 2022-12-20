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
## Implements a custom [MultiplayerAPI] for a network client.
## Useful for allowing simultaneous client and server networking on the same
## game instance, allowing for easy scalability and maintainability between 
## singleplayer and multiplayer modes.
## [br][b]See:[/b] [NetworkBase]
class_name NetworkClient
extends NetworkBase

func _ready() -> void:
	multiplayer_api = MultiplayerAPI.create_default_interface()
	
	# Connecting client signals.
	multiplayer_api.peer_connected.connect(_on_network_peer_connected)
	multiplayer_api.peer_disconnected.connect(_on_network_peer_disconnected)
	multiplayer_api.connected_to_server.connect(_on_connection_ok)
	multiplayer_api.connection_failed.connect(_on_connection_fail)
	multiplayer_api.server_disconnected.connect(_on_server_disconnect)
	
	set_network_root()


## Attempts to connect the client API to a passed server and port. Will return
## [code]true[/code] if the client peer was successfully created. 
## [code]address[/code] is the target IP address to connect to and 
## [code]port[/code] is the target port to connect to. If no port is provided
## [code]port[/code] will default to [constant DEFAULT_PORT].
func connect_to_server(
		address: String = "127.0.0.1", 
		port: int = DEFAULT_PORT
	) -> bool:
	print("CLIENT: Attempting to create network client for %s:%s..." % [address, port])
	
	# Ensuring a server connection does not already exist.
	if multiplayer_api.has_multiplayer_peer():
		multiplayer_api.multiplayer_peer.close()
	
	# Creating and validating the network peer.
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("CLIENT: Could not create network client for %s:%s, aborting..." % [address, port])
		return false
	
	# Connecting network peer to client network API.
	multiplayer_api.multiplayer_peer = peer
	
	print("CLIENT: Successfully created network client for %s:%s..." % [address, port])
	return true


## Gets called when [b]any client[/b] connects to the connected server.
## [code]peer_id[/code] will be the [b]network ID[/b] of the connected peer.
## [br][b]Note:[/b] It is important to note that 
## [method _on_network_peer_connected] will be called for every client that is 
## already connected to a server when joining, [b]including the server[/b]. 
## Meaning that even when joining an empty server, 
## [method _on_network_peer_connected] will be called once with
## [code]peer_id = 1[/code], representing the server.
func _on_network_peer_connected(peer_id: int) -> void:
	print("CLIENT: Network peer %s has connected to the server..." % peer_id)


## Gets called when [b]any client[/b] disconnects from the connected server. 
## [code]peer_id[/code] will be the [b]network ID[/b] of the disconnected peer.
func _on_network_peer_disconnected(peer_id: int) -> void:
	print("CLIENT: Network peer %s has disconnected from the server..." % peer_id)


## Gets called when the client [b]successfully connects[/b] to a server.
func _on_connection_ok() -> void:
	print("CLIENT: Successfully connected to the game server.")


## Gets called when the client successfully disconnects from a server.
func _on_connection_fail() -> void:
	print("CLIENT: Failed to connect to the game server.")


## Gets called when a server disconnects from the client.
func _on_server_disconnect() -> void:
	print("CLIENT: Server has disconnected.")
