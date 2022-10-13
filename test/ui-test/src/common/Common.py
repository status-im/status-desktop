
import drivers.SquishDriver as driver
import drivers.SquishDriverVerification as verification

def start_application(app_name: str):
    driver.start_application(app_name)
    
def click_on_an_object(objName: str):
    driver.click_obj_by_name(objName)    
    
def input_text(text: str, objName: str):
    driver.type(objName, text)    
    
def object_not_enabled(objName: str):
    verification.verify_object_enabled(objName, 500, False)

def str_to_bool(string: str):
    return string.lower() in ["yes", "true", "1", "y", "enabled"]
