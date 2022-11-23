import squish
import object

def getChildrenOfType(parent, typename, depth=1000):
    children = []
    for child in object.children(parent):
        if squish.className(child) == typename:
            children.append(child)
        if depth:
            children.extend(getChildrenOfType(child, typename, depth - 1))
    return children

def get_children_with_object_name(parent, objectName, depth=1000):
    children = []
    for child in object.children(parent):
        if child.objectName == objectName:
            children.append(child)
        if depth:
            children.extend(get_children_with_object_name(child, objectName, depth - 1))
    return children