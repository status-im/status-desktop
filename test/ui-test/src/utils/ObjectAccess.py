import object
import squish


def get_children_of_type(parent, typename, depth=1000):
    children = []
    for child in object.children(parent):
        if squish.className(child) == typename:
            children.append(child)
        if depth:
            children.extend(get_children_of_type(child, typename, depth - 1))
    return children


def get_children_with_object_name(parent, objectName, depth=1000):
    children = []
    for child in object.children(parent):
        if child.objectName == objectName:
            children.append(child)
        if depth:
            children.extend(get_children_with_object_name(child, objectName, depth - 1))
    return children


def walk_children(parent, depth: int = 1000):
    for child in object.children(parent):
        yield child
        if depth:
            yield from walk_children(child, depth - 1)
