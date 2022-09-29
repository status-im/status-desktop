# encoding: UTF-8

import squish
import object

def wait_for_object(objRealName: dict, timeoutMSec: int = 1000):
    return squish.waitForObject(objRealName, timeoutMSec)

def type_text(obj, text: str):
    squish.type(obj, text)

def find_object(objRealName: dict):
    return squish.findObject(objRealName)

def wait_for_object_exists(objRealName: dict, timeoutMSec: int = 1000):
    return squish.waitForObjectExists(objRealName, timeoutMSec)
