from drivers.SquishDriver import *


class ContextMenu(BaseElement):

    def __init__(self):
        super(ContextMenu, self).__init__('contextMenu_PopupItem')
        self._menu_item = BaseElement('contextMenuItem')

    def select(self, value: str):
        self._menu_item.object_name['text'] = value
        self._menu_item.click()
