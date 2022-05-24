#******************************************************************************
# Status.im
#*****************************************************************************/
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


_MAX_WAIT_OBJ_TIMEOUT = 5000


def is_loaded_visible_and_enabled(objName, timeout=_MAX_WAIT_OBJ_TIMEOUT):
	obj = None
	try:
		obj = squish.waitForObject(getattr(names, objName), timeout)
		return True, obj
	except LookupError:
		return False, obj

	
def verify_screen_is_loaded(objName, timeout=_MAX_WAIT_OBJ_TIMEOUT):
	result = is_loaded_visible_and_enabled(objName, timeout)
	test.verify(result, True)


def is_loaded(objName):
	obj = None
	try:
		obj = squish.findObject(getattr(names, objName))
		return True, obj
	except LookupError:
		return False, obj

		
def is_visible_and_enabled(obj):
	return obj.visible and obj.enabled


def get_child(obj, child_index=None):
	if None == child_index:
		return object.children(obj)
	else:
		return object.children(obj)[child_index]


def click_obj(obj):
	try:
		squish.mouseClick(obj, squish.Qt.LeftButton)
		return True
	except LookupError:
		return False


def click_obj_by_name(objName):
	try:
		obj = squish.waitForObject(getattr(names, objName))
		squish.mouseClick(obj, squish.Qt.LeftButton)
		return True
	except LookupError:
		return False
	

def check_obj_by_name(objName):
	try:
		obj = squish.waitForObject(getattr(names, objName))
		obj.checked = True
		return True
	except LookupError:
		return False


def verify_text(objName, text):
	try:
		obj = squish.waitForObject(getattr(names, objName))
		test.compare(obj.text, text, "Found the following text " + text)
		return True
	except LookupError:
		return False


def type(objName, text):
	try:
		obj = squish.findObject(getattr(names, objName))
		squish.type(obj, text)
		return True
	except LookupError:
		return False
