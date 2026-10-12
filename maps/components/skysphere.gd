@tool
extends MeshInstance3D


@export var texture: Texture2D:
	set(t):
		if !Engine.is_editor_hint():
			return

		texture = t
		if self.mesh.surface_get_material(0) is not ShaderMaterial: return
		var smat: ShaderMaterial = self.mesh.surface_get_material(0)
		smat.set_shader_parameter("sky_texture", texture)
