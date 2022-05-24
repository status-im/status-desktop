

class Common:
    
    def __init__(self):
        pass
    
    def click_on_an_object(self, obj):
        click_obj_by_name(obj)
    
    def input_text(self, obj, text):
        type(obj, text)
