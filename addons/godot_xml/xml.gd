


class_name XML extends RefCounted





static func parse_file(path: String) -> XMLDocument:
	var file = FileAccess.open(path, FileAccess.READ)
	var xml: PackedByteArray = file.get_as_text().to_utf8_buffer()
	file = null

	return XML._parse(xml)




static func parse_str(xml: String) -> XMLDocument:
	return XML._parse(xml.to_utf8_buffer())




static func parse_buffer(xml: PackedByteArray) -> XMLDocument:
	return XML._parse(xml)






static func dump_file(
	path: String, 
	document: XMLDocument, 
	pretty: bool = false, 
	indent_level: int = 0, 
	indent_length: int = 2, 
) -> void :
	return document.root.dump_file(path, pretty, indent_level, indent_length)






static func dump_buffer(
	document: XMLDocument, 
	pretty: bool = false, 
	indent_level: int = 0, 
	indent_length: int = 2, 
) -> PackedByteArray:
	return document.root.dump_buffer(pretty, indent_level, indent_length)






static func dump_str(
	document: XMLDocument, 
	pretty: bool = false, 
	indent_level: int = 0, 
	indent_length: int = 2, 
) -> String:
	return document.root.dump_str(pretty, indent_level, indent_length)


static func _parse(xml: PackedByteArray) -> XMLDocument:
	xml = _cleanup_double_blankets(xml)

	var doc: = XMLDocument.new()
	var queue: Array[XMLNode] = []

	var parser: = XMLParser.new()
	parser.open_buffer(xml)

	while parser.read() != ERR_FILE_EOF:
		var node: XMLNode = _make_node(queue, parser)


		if node == null:
			continue


		if len(queue) == 0:
			doc.root = node
			queue.append(node)
		else:
			var node_type: = parser.get_node_type()







			if node.standalone:
				queue.back().children.append(node)


			elif node_type == XMLParser.NODE_ELEMENT_END:
				var last: = queue.pop_back()


				if node.name != last.name:
					push_error(
						"Invalid closing tag: started with %s but ended with %s. Ignoring (output may be incorrect)." % [last.name, node.name]
					)

					continue







				if queue.is_empty():
					break


			else:
				queue.back().children.append(node)
				queue.append(node)


	if not queue.is_empty():
		queue.reverse()
		var names: Array[String] = []

		for node in queue:
			names.append(node.name)

		push_error("The following nodes were not closed: %s" % ", ".join(names))

	return doc



static func _make_node(queue: Array[XMLNode], parser: XMLParser) -> Variant:
	var node_type: = parser.get_node_type()

	match node_type:
		XMLParser.NODE_ELEMENT:
			return XML._make_node_element(parser)
		XMLParser.NODE_ELEMENT_END:
			return XML._make_node_element_end(parser)
		XMLParser.NODE_TEXT:

			if queue.is_empty():
				return
			XML._attach_node_data(queue.back(), parser)
			return
		XMLParser.NODE_CDATA:
			if queue.is_empty():
				return
			_attach_node_cdata(queue.back(), parser)
			return

	return


static func _make_node_element(parser: XMLParser) -> XMLNode:
	var node: = XMLNode.new()

	node.name = parser.get_node_name()
	node.attributes = XML._get_attributes(parser)
	node.content = ""
	node.standalone = parser.is_empty()
	node.children = []

	return node


static func _make_node_element_end(parser: XMLParser) -> XMLNode:
	var node: = XMLNode.new()

	node.name = parser.get_node_name()
	node.attributes = {}
	node.content = ""
	node.standalone = false
	node.children = []

	return node


static func _attach_node_data(node: XMLNode, parser: XMLParser) -> void :


	node.content += parser.get_node_data().strip_edges()

static func _attach_node_cdata(node: XMLNode, parser: XMLParser) -> void :
	node.cdata.append(parser.get_node_name().strip_edges())

static func _get_attributes(parser: XMLParser) -> Dictionary:
	var attrs: Dictionary = {}
	var attr_count: int = parser.get_attribute_count()

	for attr_idx in range(attr_count):
		attrs[parser.get_attribute_name(attr_idx)] = parser.get_attribute_value(attr_idx)

	return attrs


static func _cleanup_double_blankets(xml: PackedByteArray) -> PackedByteArray:



	var rm_count: = 0
	var idx: = xml.size() - 1




	while idx >= 0:
		if xml[idx] in [9, 10, 13]:
			rm_count += 1
			idx -= 1
		else:
			break


	while rm_count > 0:
		xml.remove_at(xml.size() - 1)
		rm_count -= 1

	return xml
