from drivers.elements.base_window import BaseWindow
from drivers.elements.base_element import BaseElement
from drivers.elements.text_edit import TextEdit
from drivers.elements.button import Button
from utils.system_path import SystemPath
from drivers.SquishDriver import type_text


class SelectDialog(BaseWindow):
    
    def __init__(self):
        super(SelectDialog, self).__init__('please_choose_an_image_QQuickWindow')
        self._path_text_edit = TextEdit('titleBar_textInput_TextInputWithHandles')
        self._open_button = Button('please_choose_an_image_Open_Button')
        self._row_item_template = BaseElement('rowitem_Text')
    
    def select(self, path_list):
        for f in path_list:
            fp = SystemPath(f)
            self._path_text_edit.text = str(fp.parent)
            type_text(self._path_text_edit.symbolic_name, '<Return>')
            self._row_item_template.object_name['text'] = fp.name
            self._row_item_template.click()
        self._open_button.click()
        self.wait_until_hidden()
