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

## Parent class for custom networking systems.
class_name NetworkBase
extends Node

## Default port to open for network communications.
const DEFAULT_PORT: int = 8989

## Reference to the custom MultiplayerAPI used by a network client or server.
## [br][b]See:[/b] [MultiplayerAPI]
var multiplayer_api: MultiplayerAPI

func _process(_delta: float) -> void:
	# Ensures that the server multiplayer API service is being polled for
	# network events.
	multiplayer_api.poll()


## Sets the multiplayer network root NodePath for the network object. Used if
## you want a different multiplayer root from the object's node.
## [code]target_path[/code] is the [b]absolute[/b] NodePath for the network
## root. [code]target_path[/code] will default to the [b]absolute[/b] NodePath 
## of the NetworkBase node.
## [br][b]See:[/b] [method SceneTree.set_multiplayer]
func set_network_root(target_path: NodePath = self.get_path()) -> void:
	get_tree().set_multiplayer(multiplayer_api, target_path)
