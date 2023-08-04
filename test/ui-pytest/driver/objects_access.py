import logging

import object

_logger = logging.getLogger(__name__)


def walk_children(parent, depth: int = 1000):
    for child in object.children(parent):
        yield child
        if depth:
            yield from walk_children(child, depth - 1)
