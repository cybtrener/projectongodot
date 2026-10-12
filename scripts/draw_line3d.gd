extends Node2D

class Line:
	var Start
	var End
	var LineColor
	var time

	func _init(Start, End, LineColor, time):
		self.Start = Start
		self.End = End
		self.LineColor = LineColor
		self.time = time

var Lines = []
var RemovedLine = false

func _process(delta):
	for i in range(len(Lines)):
		Lines[i].time -= delta

	if (len(Lines) > 0 || RemovedLine):
		queue_redraw()
		RemovedLine = false

func _draw():
	var Cam = get_viewport().get_camera_3d()
	if not Cam: return

	for i in range(len(Lines)):
		var ScreenPointStart = Cam.unproject_position(Lines[i].Start)
		var ScreenPointEnd = Cam.unproject_position(Lines[i].End)




		if (Cam.is_position_behind(Lines[i].Start) || 
			Cam.is_position_behind(Lines[i].End)):
			continue

		draw_line(ScreenPointStart, ScreenPointEnd, Lines[i].LineColor)


	var i = Lines.size() - 1
	while (i >= 0):
		if (Lines[i].time < 0.0):
			Lines.remove_at(i)
			RemovedLine = true
		i -= 1

func DrawLine(Start, End, LineColor, time: float = 0.0, force: bool = false):
	if not get_tree().debug_collisions_hint and !force: return
	Lines.append(Line.new(Start, End, LineColor, time))

func DrawRay(Start, Ray, LineColor, time: float = 0.0, force: bool = false):
	if not get_tree().debug_collisions_hint and !force: return
	Lines.append(Line.new(Start, Start + Ray, LineColor, time))

func DrawCube(Center: Vector3, HalfExtents, LineColor, time: float = 0.0, force: bool = false):
	if not get_tree().debug_collisions_hint and !force: return


	var LinePointStart = Center
	LinePointStart.x -= HalfExtents
	LinePointStart.y += HalfExtents
	LinePointStart.z -= HalfExtents


	var LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time, force);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time, force);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, - HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time, force);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3( - HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time, force);


	LinePointStart = LinePointEnd + Vector3(0, - HalfExtents * 2.0, 0)
	LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time, force);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time, force);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, - HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time, force);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3( - HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time, force);


	LinePointStart = LinePointEnd
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time, force)
	LinePointStart += Vector3(0, 0, HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time, force)
	LinePointStart += Vector3(HalfExtents * 2.0, 0, 0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time, force)
	LinePointStart += Vector3(0, 0, - HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time, force)
