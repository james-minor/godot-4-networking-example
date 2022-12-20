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
class_name NetworkClient

## Default port the client attempts to connect on.
const DEFAULT_PORT: int = 8989

## Reference to the custom Client MultiplayerAPI. See [MultiplayerAPI] for
## more information on how custom multiplayer is implemented.
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
	if client_multiplayer_api.has_multiplayer_peer():
		client_multiplayer_api.multiplayer_peer.close()
	
	# Creating and validating the network peer.
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("CLIENT: Could not create network client for %s:%s, aborting..." % [address, port])
		return false
	
	# Connecting network peer to client network API.
	client_multiplayer_api.multiplayer_peer = peer
	
	print("CLIENT: Successfully created network client for %s:%s..." % [address, port])
	return true


## Gets called when [b]any client[/b] connects to the connected server.
## [code]peer_id[/code] will be the [b]network ID[/b] of the connected peer.
## [br][b]Note:[/b] It is important to note that 
## [method _on_network_peer_connected] will be called for every client that is 
## already connected to a server when
## joining, [b]including the server[/b]. Meaning that even when joining an
## empty server, [method _on_network_peer_connected] will be called once with
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
