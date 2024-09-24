import driver
from gui.components.base_popup import BasePopup
from gui.elements.object import QObject
from gui.elements.text_edit import TextEdit
from gui.objects_map import names


class TokenSelectorPopup(BasePopup):
    def __init__(self):
        super().__init__()
        self.token_selector_panel = QObject(names.tokenSelectorPanel_TokenSelectorNew)
        self.tab_bar = QObject(names.tokensTabBar_StatusTabBar)
        self.assets_tab = QObject(names.tokenSelectorPanel_AssetsTab)
        self.collectibles_tab = QObject(names.tokenSelectorPanel_CollectiblesTab)
        self.asset_list_item = QObject(names.tokenSelectorAssetDelegate_template)
        self.amount_to_send_field = TextEdit(names.amountInput_TextEdit)

    def select_asset_from_list(self, asset_name: str):
        self.assets_tab.click()
        assets_list = driver.findAllObjects(self.asset_list_item.real_name)
        assert assets_list, f'Assets are not displayed'
        for item in assets_list:
            if getattr(item, 'symbol', '') == asset_name:
                QObject(item).click()
                break
        return self
