class_name RunTerrain
extends RefCounted
## Disconnected cover islands; no enclosed rooms or narrow mandatory chokepoints.
static func build(run) -> void:
	if FactoryMaps.enabled(run): FactoryMaps.build(run); return
	if ReviewRules.enabled(run): ReviewRules.terrain(run); return
	run.kit.extra.walls.clear()
	var uid := -1
	for row in range(6):
		for col in range(9):
			var center := Vector2(-1900+col*590+(150 if row%2 else 0),-1140+row*550)
			if center.distance_to(run.player)<250: continue
			var axis := Vector2.from_angle([0.0,PI/2,PI/6,-PI/6][(row*3+col)%4])
			var length := 190.0 if (row+col)%3 else 260.0
			run.kit.extra.walls.append({"uid":uid,"a":center-axis*length/2,"b":center+axis*length/2,"life":99999.0,"terrain":true})
			uid -= 1
