from drivers.SquishDriver import *


def press_enter(objName: str):
    type(objName, "<Return>")

def press_backspace(objName: str):
    type(objName, "<Backspace>")

def press_escape(objName: str):
    type(objName, "<Escape>")