from drivers.SquishDriver import *
from remotesystem import RemoteSystem
import time
import platform

# The default maximum timeout to find ui object
_MAX_WAIT_OBJ_TIMEOUT = 5000

# The default minimum timeout to find ui object
_MIN_WAIT_OBJ_TIMEOUT = 500

# The default maximum timeout to wait for close the app in seconds
_MAX_WAIT_CLOSE_APP_TIMEOUT = 20


def verify_screen(objName: str, timeout: int=_MAX_WAIT_OBJ_TIMEOUT):
    result = is_loaded_visible_and_enabled(objName, timeout)
    test.verify(result, True)

def verify_object_enabled(objName: str, timeout: int=_MIN_WAIT_OBJ_TIMEOUT, condition: bool=True):
    result = is_loaded_visible_and_enabled(objName, timeout)
    test.verify(result[0] == condition, "object not enabled")

def verify_text_matching(objName: str, text: str):
    test.verify(is_text_matching(objName, text), "text does not match")

def verify_text_matching_insensitive(obj, text: str):
    test.verify(is_text_matching_insensitive(obj, text), "text does not match")

def verify_equal(result: object, expected: object, msg: str = "objects are not equal"):
    test.verify(result == expected, msg)

def verify(result: bool, msg: str):
    test.verify(result, msg)

def verify_false(result: bool, msg: str):
    test.verify(not result, msg)

def verify_values_equal(found: str, wanted: str, msg : str):
    test.verify(found == wanted, msg + " Found: " + found + " - Wanted: " + wanted)

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

def process_terminated(pid):
    try:
        remotesys = RemoteSystem()
    except:
        return False
    try:
        if platform.system() == "Windows":
            if "ProcessId" in remotesys.execute(["wmic", "PROCESS", "where", "ProcessId=%s" % pid, "GET", "ProcessId"])[1]:
                return False
        if platform.system() == "Darwin" or platform.system() == "Linux":
            res = remotesys.execute(["ps", "-p", "%s" % pid])
            return res[0] != "0"
    except:
        return True
    return False
    
def verify_failure(errorMsg: str):
    test.fail(errorMsg)
    
def verify_values_equal(found: str, wanted: str, msg : str):
    test.verify(found == wanted, msg + " Found: " + found + " - Wanted: " + wanted)

def verify_the_app_is_closed(pid: int):
    closed = False
    timeout = False
    closingStarted = time.time()
    try:
        while not process_terminated(pid):
            now = time.time()
            if now - closingStarted > _MAX_WAIT_CLOSE_APP_TIMEOUT:
                timeout = True
                break
            test.log("Process still exists: PID: %s" % pid)
            time.sleep(1)
        if not timeout:
            closed = True
    except:
        closed = False

    verify(closed, "app closed")

def verify_equals(val1, val2):
    test.compare(val1, val2, "1st value [" + str(val1) + ("] equal to " if val1 == val2 else "] NOT equal to ") + "2nd value [" + str(val2) + "]")

def verify_failure(errorMsg: str):
    test.fail(errorMsg)

def log(text: str):
    test.log(text)
    
def verify_screenshot(vp: str):
    test.vp(vp)

def imagePresent(imageName: str, tolerant: bool = True, threshold: int = 99.5, minScale: int = 50, maxScale: int =  200, multiscale: bool = True):
    test.imagePresent(imageName, {"tolerant": tolerant, "threshold": threshold, "minScale": minScale, "maxScale": maxScale, "multiscale": multiscale})

def passes(text: str):
    test.passes(text)