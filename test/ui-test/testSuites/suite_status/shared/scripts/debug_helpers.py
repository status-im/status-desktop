# encoding: UTF-8

import squish
import object
import names
import test

def debugWaitForObject(objRealName: dict, timeoutMSec: int = 1000):
    return squish.waitForObject(objRealName, timeoutMSec)

def type_text(obj, text: str):
    squish.type(obj, text)

def find_object(objRealName: dict):
    obj = squish.findObject(objRealName)