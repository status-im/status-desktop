# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    SquishDriver.py
# *
# * \date    February 2022
# * \brief   It contains generic Status view components definitions and Squish driver API.
# *****************************************************************************/
from enum import Enum
import sys
import time

# IMPORTANT: It is necessary to import manually the Squish drivers module by module. 
# More info in: https://kb.froglogic.com/display/KB/Article+-+Using+Squish+functions+in+your+own+Python+modules+or+packages
import squish
import object
import names
import test

from objectmaphelper import Wildcard

import copy

# The default maximum timeout to find ui object
_MAX_WAIT_OBJ_TIMEOUT = 5000

# The default minimum timeout to find ui object
_MIN_WAIT_OBJ_TIMEOUT = 500

_SEARCH_IMAGES_PATH = "../shared/searchImages/"

def start_application(app_name: str):
    squish.startApplication(app_name)

# Waits for the given object is loaded, visible and enabled.
# It returns a tuple: True in case it is found. Otherwise, false. And the object itself.
def is_loaded_visible_and_enabled(objName: str, timeout: int=_MAX_WAIT_OBJ_TIMEOUT):
    obj = None
    try:
        obj = squish.waitForObject(getattr(names, objName), timeout)
        return True, obj
    except LookupError:
        return False, obj


# Waits for the given object is loaded and might be not visible and/or not enabled:
# It returns a tuple: True in case it is found. Otherwise, false. And the object itself.
def is_loaded(objName: str):
    obj = None
    try:
        obj = squish.findObject(getattr(names, objName))
        return True, obj
    except LookupError:
        return False, obj

# It tries to find if the object with given objectName is currently displayed (visible and enabled):
# It returns True in case it is found. Otherwise, false.
def is_found(objName: str):
    try:
        squish.findObject(getattr(names, objName))
        return True
    except LookupError:
        return False
    
# It waits for the object with given objectName to appear in the UI (visible and enabled):
# It returns True in case it appears without exceeding a specific timeout. Otherwise, false.
def is_displayed(objName: str):
    try:
        squish.waitForObject(getattr(names, objName))
        return True
    except LookupError:
        return False

# It checks if the given object is visible and enabled.
def is_visible_and_enabled(obj):
    return obj.visible and obj.enabled

def is_null(obj):
    return squish.isNull(obj)

# Given a specific object, get a specific child.
def get_child(obj, child_index=None):
    if None == child_index:
        return object.children(obj)
    else:
        return object.children(obj)[child_index]


# It executes the click action into the given object:
def click_obj(obj):
    squish.mouseClick(obj, squish.Qt.LeftButton)

# It executes the right-click action into the given object:
def right_click_obj(obj):
    try:
        squish.mouseClick(obj, squish.Qt.RightButton)
        return True
    except LookupError:
        return False

def get_obj(objName: str):
    obj = squish.findObject(getattr(names, objName))
    return obj

def wait_and_get_obj(objName: str, timeout: int=_MAX_WAIT_OBJ_TIMEOUT):
    obj = squish.waitForObject(getattr(names, objName), timeout)
    return obj

def get_and_click_obj(obj_name: str):
    click_obj(get_obj(obj_name))

def get_objects(objName: str):
    objs = squish.findAllObjects(getattr(names, objName))
    return objs

def hover_and_click_object_by_name(objName: str):
    obj = squish.waitForObject(getattr(names, objName))
    hover_obj(obj)
    squish.mouseClick(obj, squish.Qt.LeftButton)

# It executes the left-click action into object with given object name:
def click_obj_by_name(objName: str):
    obj = squish.waitForObject(getattr(names, objName))
    squish.mouseClick(obj, squish.Qt.LeftButton)

def click_obj_by_attr(attr: str):
    obj = squish.waitForObject(attr)
    squish.mouseClick(obj, squish.Qt.LeftButton)

def click_obj_by_wildcards_name(objName: str, wildcardString: str):
    wildcardRealName = copy.deepcopy(getattr(names, objName))
    wildcardRealName["objectName"] = Wildcard(wildcardString)

    obj = squish.waitForObject(wildcardRealName)
    squish.mouseClick(obj, squish.Qt.LeftButton)

# Replaces all occurrences of objectNamePlaceholder with newValue in the objectName from the realName
# Then use the new objectName as a wildcard search pattern, waiting for the object with the new Real Name
# and return it if found. Raise an exception if not found.
def wait_by_wildcards(realNameVarName: str, objectNamePlaceholder: str, newValue: str, timeoutMSec: int = _MAX_WAIT_OBJ_TIMEOUT):
    wildcardRealName = copy.deepcopy(getattr(names, realNameVarName))
    newObjectName = wildcardRealName["objectName"].replace(objectNamePlaceholder, newValue)
    wildcardRealName["objectName"] = Wildcard(newObjectName)

    return squish.waitForObject(wildcardRealName, timeoutMSec)

# It executes the right-click action into object with given object name:
def right_click_obj_by_name(objName: str):
    obj = squish.waitForObject(getattr(names, objName))
    squish.mouseClick(obj, squish.Qt.RightButton)


# It moves the mouse over an object
def hover_obj(obj):
    squish.mouseMove(obj)

def move_mouse_over_object(obj):
    # Start moving the cursor:
    end_x = obj.x + (obj.width / 2)
    y = round(int(obj.height) / 2)
    x = 0
    while x < end_x:
        squish.mouseMove(obj, x, y)
        x += 10

def scroll_obj_by_name(objName: str):
    obj = squish.waitForObject(getattr(names, objName))
    squish.mouseWheel(obj, 206, 35, 0, -1, squish.Qt.ControlModifier)

# execute do_fn until validation_fn returns True or timeout is reached
def do_until_validation_with_timeout(do_fn, validation_fn, message: str, timeout_ms: int=_MAX_WAIT_OBJ_TIMEOUT * 2):
    start_time = time.time()
    while(not validation_fn()):
        if ((time.time() - start_time) * 1000) > timeout_ms:
            raise Exception("Timeout reached while validating: " + message)
        do_fn()

def scroll_item_until_item_is_visible(itemToScrollObjName: str, itemToBeVisibleObjName: str, timeout_ms: int=_MAX_WAIT_OBJ_TIMEOUT * 2):
    is_item_visible_fn = lambda: is_loaded_visible_and_enabled(itemToBeVisibleObjName, 10)[0]
    scroll_item_fn = lambda: scroll_obj_by_name(itemToScrollObjName)
    do_until_validation_with_timeout(scroll_item_fn, is_item_visible_fn, f'Scrolling {itemToScrollObjName} until {itemToBeVisibleObjName} is visible', timeout_ms)

def check_obj_by_name(objName: str):
    obj = squish.waitForObject(getattr(names, objName))
    obj.checked = True


def is_text_matching(objName: str, text: str):
    try:
        obj = squish.waitForObject(getattr(names, objName))
        test.compare(obj.text, text, "Found the following text " + str(obj.text) + " Wanted: " + text)
        return True
    except LookupError:
        print(objName + " is not found, please check app for correct object and update object mapper")
        return False


def is_text_matching_insensitive(obj, text: str):
    try:
        test.compare(obj.text.toLower(), text.lower(), "Found the following text " + text.lower())
        return True
    except LookupError:
        print(objName + " is not found, please check app for correct object and update object mapper")
        return False


# It types the specified text into the given object (as if the user had used the keyboard):
def type(objName: str, text: str):
    try:
        obj = squish.findObject(getattr(names, objName))
        squish.type(obj, text)
        return True
    except LookupError:
        return False


# It types the specified text in the currently focus input (like if the keyboard was typed on)
def native_type(text: str):
    squish.nativeType(text)

# Wait for the object to appears and
# It types the specified text into the given object (as if the user had used the keyboard):
def wait_for_object_and_type(objName: str, text: str):
    try:
        obj = squish.waitForObject(getattr(names, objName))
        squish.type(obj, text)        
        return True
    except LookupError:
        return False

# It sets the specified text into the given object (first erase, then type)
def setText(objName: str, text: str):
    try:
        obj = squish.waitForObject(getattr(names, objName))
        squish.type(obj, "<Ctrl+a>")
        squish.type(obj, text)
        return True
    except LookupError:
        return False

# Clicking link in label / textedit
def click_link(objName: str, link: str):
    point = _find_link(getattr(names, objName), link)
    if point[0] != -1 and point[1] != -1:
        squish.mouseClick(getattr(names, objName), point[0], point[1], 0, squish.Qt.LeftButton)
        
# Global properties for getting link / hovered handler management:
_expected_link = None 
_link_found = False

def _handle_link_hovered(obj, link):
    global _link_found
    if link == _expected_link:
        _link_found = True

# It registers to hovered handler and moves mouse around a specific object. 
# Return: If handler is executed, link has been found and the position of the link is returned. Otherwise, it returns position [-1, -1] 
def _find_link(objName: str, link: str):
    global _expected_link
    global _link_found
    _expected_link = link
    _link_found = False
    obj = squish.waitForObject(objName)

    # Inject desired function into main module:
    sys.modules['__main__']._handle_link_hovered = _handle_link_hovered
    squish.installSignalHandler(obj, "linkHovered(QString)", "_handle_link_hovered")  

    # Start moving the cursor:
    squish.mouseMove(obj, int(obj.x), int(obj.y))
    end_x = obj.x + obj.width
    end_y = obj.y + obj.height
    y = int(obj.y)
    while y < end_y:
        x = int(obj.x)
        while x < end_x:
            squish.mouseMove(obj, x, y)
            if _link_found:
                squish.uninstallSignalHandler(obj, "linkHovered(QString)", "_handle_link_hovered")
                return [x - obj.x, y - obj.y]
            x += 10
        y += 10
        
    squish.uninstallSignalHandler(obj, "linkHovered(QString)", "_handle_link_hovered")
    return [-1, -1]


def move_mouse_over_object(obj):
    # Start moving the cursor:
    end_x = obj.x + (obj.width / 2)
    y = round(int(obj.height) / 2)
    x = 0
    while x < end_x:
        squish.mouseMove(obj, x, y)
        x += 10

def expect_true(assertionValue: bool, message: str):
    return test.verify(assertionValue, message)

# Wait for the object to appear and, assuming it is already focused
# it types the specified text into the given object (as if the user had used the keyboard):
def wait_for_object_focused_and_type(obj_name: str, text: str):
    try:
        squish.waitForObject(getattr(names, obj_name))
        squish.nativeType(text)
        squish.snooze(1)
        return True
    except LookupError:
        return False

# NOTE: It is a specific method for ListView components.
# It positions the mouse in the middle of the list_obj and scrolls until reaching the item at specific index is visible.
# Return True if it has been possible to scroll until item index, False if timeout or index not found.     
def scroll_list_view_at_index(list_obj, index: int, timeout: int=_MAX_WAIT_OBJ_TIMEOUT):
    start_time = time.time() * 1000
    current_time = start_time
    end_scroll = False
    if not squish.isNull(list_obj):
        while not end_scroll and current_time - start_time <= timeout:
            item_obj = list_obj.itemAtIndex(index)              
            if not squish.isNull(item_obj) and item_obj.visible:
                end_scroll = True
                return True
            squish.mouseWheel(list_obj, int(list_obj.x + list_obj.width/2), int(list_obj.y + list_obj.height/2), 0, -1, squish.Qt.ControlModifier)
            squish.snooze(1) 
            current_time = time.time() * 1000
    return False

# Fail if the object is found and pass if not found
def verify_not_found(realNameVarName: str, message: str, timeoutMSec: int = 500):
    try:
        squish.waitForObject(getattr(names, realNameVarName), timeoutMSec)
        test.fail(message, f'Unexpected: the object "{realNameVarName}" was found.')
    except LookupError as err:
        test.passes(message, f'Expected: the object "{realNameVarName}" was not found. Exception: {str(err)}.')

def grabScreenshot_and_save(obj, imageName:str, delay:int = 0):
    img = object.grabScreenshot(obj, {"delay": delay})
    img.save(_SEARCH_IMAGES_PATH + imageName + ".png")

def wait_for_prop_value(object, propertyName, value, timeoutMSec: int = 2000):
    start = time.time()
    while(start + timeoutMSec / 1000 > time.time()):
        propertyNames = propertyName.split('.')
        objThenVal = object
        for name in propertyNames:
            objThenVal = getattr(objThenVal, name)
        if objThenVal == value:
            return
        squish.snooze(0.1)
    raise Exception(f'Failed to match value "{value}" for property "{propertyName}" before timeout {timeoutMSec}ms; actual value: "{objThenVal}"')

def get_child_item_with_object_name(item, objectName: str):
    for index in range(item.components.count()):
        if item.components.at(index).objectName == objectName:
            return item.components.at(index)
    raise Exception("Could not find child component with object name '{}'".format(objectName))

def sleep_test(seconds: float):
    squish.snooze(seconds)
