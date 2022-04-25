extends Node

const PLANE_HEIGHT = 3
const PLANE_WIDTH = 15
const NODE_COUNT = PLANE_HEIGHT * PLANE_WIDTH
const PATH_COUNT = 10

func generate():
	randomize()
	
	#step 1: generate points on grid within ellipse
	var points = []
	points.append(Vector2(0, PLANE_HEIGHT/2))
	points.append(Vector2(PLANE_WIDTH, PLANE_HEIGHT/2))
	
	#var center = Vector2(PLANE_WIDTH/2, PLANE_HEIGHT/2)
	for i in range(NODE_COUNT):
		#while true:
		var point = Vector2(i%PLANE_WIDTH, i/PLANE_WIDTH)
		var in_rect = (point.x != 0) and (point.x != PLANE_WIDTH)
		
		#var dist_from_center = pow((point.x - center.x)/4, 2) + pow(point.y - center.y, 2)
		# only accept points inside circle
		#var in_circle = dist_from_center <= PLANE_LENGTH * PLANE_LENGTH / 64
		if not points.has(point) and in_rect:
			points.append(point)
			#break
				
	for i in points.size():
		points[i] *= 40
		#points[i] += Vector2(randi()%10 -5, randi()%10 -5)
				
	#step2: connect all points into a graph without intersecting edges
	var pool = PoolVector2Array(points)
	var triangles = Geometry.triangulate_delaunay_2d(pool)
	#step 3: finding paths from start to finish using A*
	var astar = AStar2D.new()
	for i in range(points.size()):
		astar.add_point(i, points[i])
		
	for i in range(triangles.size() / 3):
		var p1 = triangles[i * 3]
		var p2 = triangles[i*3 +1]
		var p3 = triangles[i*3 +2]
		if not astar.are_points_connected(p1,p2):
			if astar.get_point_position(p1).x != astar.get_point_position(p2).x:
				astar.connect_points(p1, p2)
		if not astar.are_points_connected(p1,p3):
			if astar.get_point_position(p1).x != astar.get_point_position(p3).x:
				astar.connect_points(p1, p3)
		if not astar.are_points_connected(p2,p3):
			if astar.get_point_position(p2).x != astar.get_point_position(p3).x:
				astar.connect_points(p2, p3)
			
	var paths = []

	
	for _i in range(PATH_COUNT):
		var id_path = astar.get_id_path(0, 1)
		if id_path.size() == 0:
			break
			

		paths.append(astar.get_point_path(0,1))
		
		# step 4: nodes dropout for multiple paths
		#for _j in range(randi() % 2 + 1):
		var index = randi() % (id_path.size() - 2) + 1
			
		var id = id_path[index]
		astar.set_point_disabled(id)
			
	return paths

