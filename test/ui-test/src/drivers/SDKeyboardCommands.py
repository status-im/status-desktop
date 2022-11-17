from drivers.SquishDriver import *


def press_enter(objName: str):
    type(objName, "<Return>")

def press_backspace(objName: str):
    type(objName, "<Backspace>")

def press_escape(objName: str):
    type(objName, "<Escape>")
    
def press_select_all(objName: str):
    click_obj_by_name(objName)
    if sys.platform == "darwin":
        native_type("<Command+a>");
    else:
        native_type("<Ctrl+a>");