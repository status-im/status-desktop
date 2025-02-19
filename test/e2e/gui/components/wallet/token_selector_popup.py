import random
from gui.components.wallet.send_popup import *
from gui.elements.button import Button
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

    def open_collectibles_search_view(self):
        self.collectibles_tab.click()
        return SearchableCollectiblesPanelView().wait_until_appears()


class SearchableCollectiblesPanelView(TokenSelectorPopup):
    def __init__(self):
        super(SearchableCollectiblesPanelView, self).__init__()
        self.searchableCollectiblesPanel = QObject(names.searchableCollectiblesPanel)
        self.search_bar = QObject(names.tokenSelectorSearchBar)
        self.collectibles_list_view = QObject(names.collectiblesListView)
        self.collectibles_inner_list_view = QObject(names.collectiblesInnerListView)

        self.collectiblesListViewInnerItem = QObject(names.collectiblesListViewInnerItem)

        self.collectible_list_item = QObject(names.tokenSelectorCollectibleDelegate_template)
        self.back_button = Button(names.tokenSelectorBackButton)
        self.search_bar_edit = TextEdit(names.tokenSelectorSearchBarTextEdit)

    def wait_until_appears(self, timeout_msec: int = configs.timeouts.UI_LOAD_TIMEOUT_MSEC):
        self.search_bar.wait_until_appears(timeout_msec)
        return self

    def get_list(self, list_view, list_item):
        assert driver.waitForObject(list_view.real_name,
                                    60000).count > 0, f'ListView of nested collectibles is empty'
        return driver.findAllObjects(list_item.real_name)

    def select_random_collectible(self):
        collectibles = self.get_list(self.collectibles_list_view, self.collectible_list_item)
        collectibles_names = [str(getattr(collectible, 'name', '')) for collectible in collectibles]
        random_name = random.choice(collectibles_names).removeprefix('Owner-')
        time.sleep(3)
        self.search_bar_edit.set_text_property(random_name)
        time.sleep(3)
        search_results = self.get_list(self.collectibles_list_view, self.collectible_list_item)

        for index, item in enumerate(search_results):
            if str(getattr(item, 'name', '')).removeprefix('Owner-') == random_name:
                QObject(search_results[index]).click()
                if self.back_button.is_visible:
                    inner_collectibles = self.get_list(self.collectibles_inner_list_view, self.collectible_list_item)
                    item_to_select = random.choice(inner_collectibles)
                    QObject(item_to_select).click()
                    break
                break
        return self
