extends Node
# doesnt work...it adds the nodes but they dont work
func clone(node: Node) -> Node:
	var copy = node.duplicate()
	# see https://docs.godotengine.org/en/3.1/classes/class_object.html#id2
	var properties: Array = node.get_property_list()

	var script_properties: Array = []

	for prop in properties:
		# see https://docs.godotengine.org/en/3.1/classes/class_@globalscope.html#enum-globalscope-propertyusageflags
		# basically here we are getting any of the user-defined script variables that exist, since those apparently don't
		# get copied via `duplicate()`
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE == PROPERTY_USAGE_SCRIPT_VARIABLE:
			script_properties.append(prop)

	for prop in script_properties:
		copy.set(prop.name, node[prop.name])

	return copy

func copyForClip(parent, copyExecuted):
	if (!copyExecuted):
		copyExecuted = true
		var newParent = Node2D.new()

		for child in parent.get_children():
			var childClass = child.get_class()
			if (childClass == 'Sprite2D'):
				child.modulate = Color(1, 1, 1, 0.3882)
				child.z_index = 2
			if (
				childClass == 'AnimationPlayer'
				|| childClass == 'AnimationTree'
				|| childClass == 'Sprite2D'
			):
				var newChild = clone(child)
				newParent.add_child(newChild)

		parent.add_child(newParent)
		print(newParent.get_children())

func printNodeProps(node):
	for prop in node:
		print('prop name: ', node.name)
		print('prop type: ', node.type)
		print('prop value: ', node[prop])


func findNodes(node, className, array):
	if node.is_class(className):
		array.push_back(node)
	for child in node.get_children():
		findNodes(child, className, array)

func findByClass(node: Node, className : String) -> Array:
	var result = []

	findNodes(node, className, result)
	return result




