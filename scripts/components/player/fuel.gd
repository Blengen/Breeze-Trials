extends Node

# COMPONENTS #
@onready var gameloop: Node = $"../gameloop"

@onready var vars: Node = $"../shared_variables"
@onready var fuel_label: Label = $label_fuel

func fuel_tick(delta: float) -> void:
	if vars.playing:
		vars.fuel -= delta
		fuel_label.text = str(clamp(snapped(vars.fuel, 0.1), 0.0, 99.9))
	
	if vars.fuel < -0.25: gameloop.death("Ran out of fuel")
