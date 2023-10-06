import allure

from gui.elements.object import QObject


class ContextMenu(QObject):

    def __init__(self):
        super(ContextMenu, self).__init__('contextMenu_PopupItem')
        self._menu_item = QObject('contextMenuItem')

    @allure.step('Select in context menu')
    def select(self, value: str):
        self._menu_item.real_name['text'] = value
        self._menu_item.click()