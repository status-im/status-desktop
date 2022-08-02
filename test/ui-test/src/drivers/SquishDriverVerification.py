from drivers.SquishDriver import *

# The default maximum timeout to find ui object
_MAX_WAIT_OBJ_TIMEOUT = 5000

# The default minimum timeout to find ui object
_MIN_WAIT_OBJ_TIMEOUT = 500


def verify_screen(objName: str, timeout: int=_MAX_WAIT_OBJ_TIMEOUT):
    result = is_loaded_visible_and_enabled(objName, timeout)
    test.verify(result, True)

def verify_object_enabled(objName: str, timeout: int=_MIN_WAIT_OBJ_TIMEOUT, condition: bool=True):
    result = is_loaded_visible_and_enabled(objName, timeout)
    test.verify(result[0] == condition, "verify_object_enabled")

def verify_text_matching(objName: str, text: str):
    test.verify(is_text_matching(objName, text), True)
    
def verify_equal(result: object, expected: object):
    test.verify(result == expected, "verify equal")

def verify(result: bool, msg: str):
    test.verify(result, msg)
    
def verify_text_contains(text: str, substring: str):
    found = False
    if substring in text:
        found = True
    verify(found, "Given substring: " + substring + " and complete text: " + text)
    
def verify_text_does_not_contain(text: str, substring: str):
    found = False
    if substring in text:
        found = True
    verify(not found, "Given substring: " + substring + " and complete text: " + text)
    
def verify_text(text1: str, text2: str):
    test.compare(text1, text2, "Text 1: " + text1 + "\nText 2: " + text2)
