from drivers.SquishDriver import *

# The default maximum timeout to find ui object
_MAX_WAIT_OBJ_TIMEOUT = 5000

# The default minimum timeout to find ui object
_MIN_WAIT_OBJ_TIMEOUT = 500


def verify_screen(objName, timeout=_MAX_WAIT_OBJ_TIMEOUT):
    result = is_loaded_visible_and_enabled(objName, timeout)
    test.verify(result, True)


def verify_screen_is_loaded(self, condition=True):
    test.verify(self.is_loaded, condition)


def verify_object_not_enabled(objName, timeout=_MIN_WAIT_OBJ_TIMEOUT):
    result = is_loaded_visible_and_enabled(objName, timeout)
    test.verify(result, False)
