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

# IMPORTANT: It is necessary to import manually the Squish drivers module by module. 
# More info in: https://kb.froglogic.com/display/KB/Article+-+Using+Squish+functions+in+your+own+Python+modules+or+packages
import squish
import object
import names
import test

# The default maximum timeout to find ui object
_MAX_WAIT_OBJ_TIMEOUT = 5000

# The default minimum timeout to find ui object
_MIN_WAIT_OBJ_TIMEOUT = 500


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

def is_Visible(objName: str):
    try:
        squish.findObject(getattr(names, objName))
        return True
    except LookupError:
        return False


# It checks if the given object is visible and enabled.
def is_visible_and_enabled(obj):
    return obj.visible and obj.enabled


# Given a specific object, get a specific child.
def get_child(obj, child_index=None):
    if None == child_index:
        return object.children(obj)
    else:
        return object.children(obj)[child_index]


# It executes the click action into the given object:
def click_obj(obj):
    try:
        squish.mouseClick(obj, squish.Qt.LeftButton)
        return True
    except LookupError:
        return False

def get_obj(objName: str):
        obj = squish.findObject(getattr(names, objName))
        return obj


# It executes the click action into object with given object name:
def click_obj_by_name(objName: str):
        obj = squish.waitForObject(getattr(names, objName))
        squish.mouseClick(obj, squish.Qt.LeftButton)


def scroll_obj_by_name(objName: str):
        obj = squish.waitForObject(getattr(names, objName))
        squish.mouseWheel(obj, 206, 35, 0, -1, squish.Qt.ControlModifier)


def check_obj_by_name(objName: str):
        obj = squish.waitForObject(getattr(names, objName))
        obj.checked = True


def is_text_matching(objName: str, text: str):
    try:
        obj = squish.waitForObject(getattr(names, objName))
        test.compare(obj.text, text, "Found the following text " + text)
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
