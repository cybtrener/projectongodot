@tool
extends Node
class_name SC2Importer

@export var import_scene: bool:
	set(b):
		_import_scene()
@export var place_objects: bool:
	set(b):
		pass

@export_global_file("*.sc2")
var scene_path: String = ""
@export var objects_root: Node3D

@export var objects_name_to_scene: Dictionary[StringName, PackedScene] = {

}

enum Types{
	NONE, BOOLEAN, INT32, FLOAT, STRING, WIDE_STRING, BYTE_ARRAY, 
	UINT32, KEYED_ARCHIVE, INT64, UINT64, VECTOR2, VECTOR3, VECTOR4, 
	MATRIX2, MATRIX3, MATRIX4, COLOR, FASTNAME, AABBOX3, FILEPATH, 
	FLOAT64, INT8, UINT8, INT16, UINT16, COUNT, ARRAY
}

class FileBuffer:
	var stream: PackedByteArray
	var cursor: int
	func _init(stream: PackedByteArray):
		self.stream = stream
		self.cursor = 0

	func slice(offset: int) -> PackedByteArray:
		var cur: = self.cursor
		self.cursor += offset
		return self.stream.slice(cur, cur + offset)

	func readInt8(signed: bool = true) -> int:
		var b: = slice(1)
		return b.decode_s8(0) if signed else b.decode_u8(0)
	func readInt16(signed: bool = true) -> int:
		var b: = slice(2)
		return b.decode_s16(0) if signed else b.decode_u16(0)
	func readInt32(signed: bool = true) -> int:
		var b: = slice(4)
		return b.decode_s32(0) if signed else b.decode_u32(0)
	func readInt64(signed: bool = true) -> int:
		var b: = slice(8)
		return b.decode_s64(0) if signed else b.decode_u64(0)

	func readFloat() -> float:
		var b: = slice(4)
		return b.decode_float(0)

	func readDouble() -> float:
		var b: = slice(8)
		return b.decode_double(0)

	func readString(count: int) -> String:
		var b: = slice(count)
		return b.get_string_from_utf8()

	func readBytes(count: int) -> PackedByteArray:
		return slice(count)


static func err(...stuff: Array):
	printerr("SC2Importer ERROR: ", stuff)

func _import_scene():
	print("SC2Importer: begin importing the scene...")
	var scene_file: FileAccess = FileAccess.open(scene_path, FileAccess.READ)
	if !scene_file:
		err("scene file path is invalid!")
		return

	var stream: FileBuffer = FileBuffer.new(scene_file.get_buffer(scene_file.get_length()))

	var header: String = stream.readString(4)
	var version: int = stream.readInt32(false)
	var nodeCount: int = stream.readInt32(false)

	if header != "SFV2":
		err("scene header is wrong! (must be SFV2)")
		return
	else:
		print("header is valid, proceeding...")

	print("\tversion: [", version, "]")
	print("\tnode count: [", nodeCount, "]")

	if version >= 14:
		var versionTags = KAReadFromBuffer(stream)
		print("SC2 version tags: ", versionTags)


	var descriptorSize = 0
	var descriptorFileType = Types.NONE
	var descriptorUnknowns = ""
	if version >= 10:
		descriptorSize = stream.readInt32(false)
		descriptorFileType = stream.readInt32(false)
		descriptorUnknowns = stream.readBytes(maxi(descriptorSize - 8, 1))
	print("SC2 descriptor size: ", descriptorSize, ", type: ", descriptorFileType, ", unknowns: ", descriptorUnknowns)


	if version >= 2:
		var dataNodeCount = stream.readInt32()
		print("SC2 data node count: ", dataNodeCount)





	print()
	print("SC2Importer: finished importing the scene...")


static func KAReadFromBuffer(stream: FileBuffer) -> Dictionary:

	if stream.readString(2) != "KA":
		printerr("KAReader", "Bad magic string")


	var version: = stream.readInt16(false)
	var itemCount: = stream.readInt32(false)
	print("\t\tKAReader: stream version = ", version)

	if itemCount == 0:
		return {}
	var data: Dictionary = {}
	if version == 1:
		readV1Data(stream, itemCount, data)
	elif version == 2:
		readV2Data(stream, itemCount, data)
	elif version == 258:
		readV258Data(stream, itemCount, data)
	else:
		printerr("KAReader", "Unknown KA version: ", version)

	return data

static func readV1Data(file, count, data):
	for i in range(count):
		var key = V1ReadValue(file)
		var value = V1ReadValue(file)
		data[key] = value

static func readV2Data(file, count, data):

	var strings = []
	for i in range(count):
		var string = V1ReadValue(file)
		strings.append(string)


























static func readV258Data(file, count, data):
	pass









static func V1ReadValue(stream: FileBuffer):
	var valueType: = stream.readInt8()
	return V1ReadFromValueType(stream, valueType)



static func V1ReadFromValueType(stream: FileBuffer, valueType: int):
	match valueType:
		Types.BOOLEAN:
			return bool(stream.readInt8())
		Types.INT32:
			return stream.readInt32()
		Types.FLOAT:
			return stream.readFloat()
		Types.STRING:
			var length: = stream.readInt32(false)
			return stream.readString(length)
		Types.WIDE_STRING:

			var length: = stream.readInt32(false)
			return stream.readString(length)
		Types.BYTE_ARRAY:
			var length: = stream.readInt32(false)
			return stream.readBytes(length)
		Types.UINT32:
			return stream.readInt32(false)
		Types.KEYED_ARCHIVE:
			var length: = stream.readInt32(false)
			var buffer: = stream.readBytes(length)
			return KAReadFromBuffer(FileBuffer.new(buffer))
		Types.INT64:
			return stream.readInt64()
		Types.UINT64:
			return stream.readInt64(false)
		Types.VECTOR2:
			return Vector2(stream.readFloat(), stream.readFloat())
		Types.VECTOR3:
			return Vector3(stream.readFloat(), stream.readFloat(), stream.readFloat())
		Types.VECTOR4:
			return Vector4(stream.readFloat(), stream.readFloat(), stream.readFloat(), stream.readFloat())
		Types.MATRIX2:
			return [
				Vector2(stream.readFloat(), stream.readFloat()), 
				Vector2(stream.readFloat(), stream.readFloat())
			]
		Types.MATRIX3:
			return [
				Vector3(stream.readFloat(), stream.readFloat(), stream.readFloat()), 
				Vector3(stream.readFloat(), stream.readFloat(), stream.readFloat()), 
				Vector3(stream.readFloat(), stream.readFloat(), stream.readFloat())
			]
		Types.MATRIX4:
			return [
				Vector4(stream.readFloat(), stream.readFloat(), stream.readFloat(), stream.readFloat()), 
				Vector4(stream.readFloat(), stream.readFloat(), stream.readFloat(), stream.readFloat()), 
				Vector4(stream.readFloat(), stream.readFloat(), stream.readFloat(), stream.readFloat()), 
				Vector4(stream.readFloat(), stream.readFloat(), stream.readFloat(), stream.readFloat())
			]
		Types.COLOR:
			return Color(stream.readFloat(), stream.readFloat(), stream.readFloat(), stream.readFloat())
		Types.FASTNAME:
			var length: = stream.readInt32(false)
			return stream.readString(length)
		Types.AABBOX3:
			var minimum: Vector3 = Vector3(stream.readFloat(), stream.readFloat(), stream.readFloat())
			var maximum: Vector3 = Vector3(stream.readFloat(), stream.readFloat(), stream.readFloat())
			return AABB(minimum, maximum)
		Types.FILEPATH:
			var length: = stream.readInt32(false)
			return stream.readString(length)
		Types.FLOAT64:
			return stream.readDouble()
		Types.INT8:
			return stream.readInt8()
		Types.UINT8:
			return stream.readInt8(false)
		Types.INT16:
			return stream.readInt16()
		Types.UINT16:
			return stream.readInt16(false)
		Types.ARRAY:
			var length: = stream.readInt32(false)
			var array: Array = []
			for i in range(length):
				array.append(V1ReadValue(stream))
			return array
		_:
			printerr("KA.KAReader.V1DataReader", "Unknown data type of id: ", valueType)


static func V258ReadValue(stream: FileBuffer):
	var valueType: int = stream.readInt8(false)
	match valueType:
		Types.STRING:
			return stream.readInt32(false)
		Types.WIDE_STRING:
			return stream.readInt32(false)
		Types.FASTNAME:
			return stream.readInt32(false)
		Types.FILEPATH:
			return stream.readInt32(false)
		_:
			return V1ReadFromValueType(stream, valueType)

func _place_objects():
	pass
