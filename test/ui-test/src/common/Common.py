
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


    
def click_on_an_object(obj):
    click_obj_by_name(obj)
    
    
def input_text(text, obj):
    type(obj, text)
    
    
def object_not_enabled(obj):
    verify_object_enabled(obj, 500, False)
