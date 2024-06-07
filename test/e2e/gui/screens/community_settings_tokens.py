import typing

import allure

import configs
import driver
from constants.community_settings import MintOwnerTokensElements
from gui.components.sign_transaction_popup import SignTransactionPopup
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_label import TextLabel
from gui.objects_map import communities_names


class TokensView(QObject):
    def __init__(self):
        super(TokensView, self).__init__(communities_names.mainWindow_mintPanel_MintTokensSettingsPanel)
        self._mint_token_button = Button(communities_names.mainWindow_Mint_token_StatusButton)
        self._welcome_image = QObject(communities_names.welcomeSettingsTokens_Image)
        self._welcome_title = TextLabel(communities_names.welcomeSettingsTokens_Title)
        self._welcome_subtitle = TextLabel(communities_names.welcomeSettingsTokensSubtitle)
        self._welcome_checklist_1 = TextLabel(communities_names.checkListText_0_Tokens)
        self._welcome_checklist_2 = TextLabel(communities_names.checkListText_1_Tokens)
        self._welcome_checklist_3 = TextLabel(communities_names.checkListText_2_Tokens)
        self._get_started_infobox = QObject(communities_names.mint_Owner_Tokens_InfoBoxPanel)
        self._mint_owner_token_button = Button(communities_names.mint_Owner_Tokens_StatusButton)

    @property
    @allure.step('Get mint token button visibility state')
    def is_mint_token_button_present(self) -> bool:
        return self._mint_token_button.exists

    @property
    @allure.step('Get mint token button enable state')
    def is_mint_token_button_enabled(self) -> bool:
        return driver.waitForObjectExists(self._mint_token_button.real_name,
                                          configs.timeouts.UI_LOAD_TIMEOUT_MSEC).enabled

    @property
    @allure.step('Get tokens welcome image path')
    def tokens_welcome_image_path(self) -> str:
        return self._welcome_image.object.source.path

    @property
    @allure.step('Get tokens welcome title')
    def tokens_welcome_title(self) -> str:
        return self._welcome_title.text

    @property
    @allure.step('Get tokens welcome subtitle')
    def tokens_welcome_subtitle(self) -> str:
        return self._welcome_subtitle.text

    @property
    @allure.step('Get tokens checklist')
    def tokens_checklist(self) -> typing.List[str]:
        tokens_checklist = [str(self._welcome_checklist_1.object.text), str(self._welcome_checklist_2.object.text),
                            str(self._welcome_checklist_3.object.text)]
        return tokens_checklist

    @property
    @allure.step('Get tokens info box title')
    def tokens_infobox_title(self) -> str:
        return str(self._get_started_infobox.object.title)

    @property
    @allure.step('Get tokens info box text')
    def tokens_infobox_text(self) -> str:
        return str(self._get_started_infobox.object.text)

    @property
    @allure.step('Get tokens mint owner token button visibility state')
    def is_tokens_owner_token_button_visible(self) -> bool:
        return self._mint_owner_token_button.is_visible

    @allure.step('Click mint owner button')
    def click_mint_owner_button(self):
        self._mint_owner_token_button.click()
        return TokensOwnerTokenSettingsView().wait_until_appears()


class TokensOwnerTokenSettingsView(QObject):
    def __init__(self):
        super(TokensOwnerTokenSettingsView, self).__init__(communities_names.mainWindow_ownerTokenPage_SettingsPage)
        self._scroll = Scroll(communities_names.o_Flickable)
        self._owner_token_section = QObject(communities_names.ownerToken_InfoPanel)
        self._token_master_token_section = QObject(communities_names.tokenMasterToken_InfoPanel)
        self._next_button = Button(communities_names.next_StatusButton)
        self._owner_token_text_object = TextLabel(communities_names.owner_token_StatusBaseText)
        self._token_master_text_object = TextLabel(communities_names.token_master_StatusBaseText)

    @property
    @allure.step('Get all text from owner token panel')
    def get_text_labels_from_owner_token_panel(self) -> list:
        if not self._owner_token_section.is_visible:
            self._scroll.vertical_scroll_to(self._owner_token_section)
        owner_token_text_labels = []
        for item in driver.findAllObjects(self._owner_token_text_object.real_name):
            owner_token_text_labels.append(item)
        return sorted(owner_token_text_labels, key=lambda item: item.y)

    @allure.step('Verify text on owner token panel')
    def verify_text_on_owner_token_panel(self):
        assert str(self.get_text_labels_from_owner_token_panel[
                       1].text) == MintOwnerTokensElements.OWNER_TOKEN_CHEKLIST_ELEMENT_1.value, f'Actual text is {self.get_text_labels_from_owner_token_panel[2].text}'
        assert str(self.get_text_labels_from_owner_token_panel[
                       2].text) == MintOwnerTokensElements.OWNER_TOKEN_CHEKLIST_ELEMENT_2.value, f'Actual text is {self.get_text_labels_from_owner_token_panel[3].text}'
        assert str(self.get_text_labels_from_owner_token_panel[
                       3].text) == MintOwnerTokensElements.OWNER_TOKEN_CHEKLIST_ELEMENT_3.value, f'Actual text is {self.get_text_labels_from_owner_token_panel[4].text}'
        assert str(self.get_text_labels_from_owner_token_panel[
                       4].text) == MintOwnerTokensElements.OWNER_TOKEN_CHEKLIST_ELEMENT_4.value, f'Actual text is {self.get_text_labels_from_owner_token_panel[5].text}'

    @allure.step('Verify text on master token panel')
    def verify_text_on_master_token_panel(self):
        assert str(self.get_text_labels_from_master_token_panel[
                       1].text) == MintOwnerTokensElements.MASTER_TOKEN_CHEKLIST_ELEMENT_1.value, f'Actual text is {self.get_text_labels_from_master_token_panel[1].text}'
        assert str(self.get_text_labels_from_master_token_panel[
                       2].text) == MintOwnerTokensElements.MASTER_TOKEN_CHEKLIST_ELEMENT_2.value, f'Actual text is {self.get_text_labels_from_master_token_panel[2].text}'
        assert str(self.get_text_labels_from_master_token_panel[
                       3].text) == MintOwnerTokensElements.MASTER_TOKEN_CHEKLIST_ELEMENT_3.value, f'Actual text is {self.get_text_labels_from_master_token_panel[3].text}'
        assert str(self.get_text_labels_from_master_token_panel[
                       4].text) == MintOwnerTokensElements.MASTER_TOKEN_CHEKLIST_ELEMENT_4.value, f'Actual text is {self.get_text_labels_from_master_token_panel[4].text}'
        assert str(self.get_text_labels_from_master_token_panel[
                       5].text) == MintOwnerTokensElements.MASTER_TOKEN_CHEKLIST_ELEMENT_5.value, f'Actual text is {self.get_text_labels_from_master_token_panel[5].text}'

    @property
    @allure.step('Get all text from master token panel')
    def get_text_labels_from_master_token_panel(self) -> list:
        if not self._token_master_token_section.is_visible:
            self._scroll.vertical_scroll_to(self._token_master_token_section)
        master_token_text_labels = []
        for item in driver.findAllObjects(self._token_master_text_object.real_name):
            master_token_text_labels.append(item)
        return sorted(master_token_text_labels, key=lambda item: item.y)

    @allure.step('Click next button')
    def click_next(self):
        if not self._next_button.is_visible:
            self._scroll.vertical_down_to(self._next_button)
        self._next_button.click()
        return EditOwnerTokenView().wait_until_appears()


class EditOwnerTokenView(QObject):
    def __init__(self):
        super(EditOwnerTokenView, self).__init__(communities_names.mainWindow_editOwnerTokenView_EditOwnerTokenView)
        self._scroll = Scroll(communities_names.editOwnerTokenView_Flickable)
        self._select_account_combobox = QObject(communities_names.editOwnerTokenView_CustomComboItem)
        self._select_network_combobox = QObject(communities_names.editOwnerTokenView_comboBox_ComboBox)
        self._mainnet_network_item = QObject(communities_names.mainnet_NetworkSelectItemDelegate)
        self._mint_button = Button(communities_names.editOwnerTokenView_Mint_StatusButton)
        self._fees_text_object = TextLabel(communities_names.editOwnerTokenView_fees_StatusBaseText)
        self._crown_icon = QObject(communities_names.editOwnerTokenView_crown_icon_StatusIcon)
        self._coin_icon = QObject(communities_names.editOwnerTokenView_token_sale_icon_StatusIcon)
        self._symbol_box = QObject(communities_names.editOwnerTokenView_symbolBox)
        self._total_box = QObject(communities_names.editOwnerTokenView_totalBox)
        self._remaining_box = QObject(communities_names.editOwnerTokenView_remainingBox)
        self._transferable_box = QObject(communities_names.editOwnerTokenView_transferableBox)
        self._destructible_box = QObject(communities_names.editOwnerTokenView_destructibleBox)
        self._edit_owner_token_text_object = TextLabel(communities_names.editOwnerTokenView_Owner_StatusBaseText)

    @property
    @allure.step('Get fee title')
    def get_fee_title(self) -> str:
        return str(self.object.feeLabel)

    @property
    @allure.step('Get fee total value')
    def get_fee_total_value(self) -> str:
        return str(self.object.feeText)

    @property
    @allure.step('Get crown symbol')
    def get_crown_symbol(self) -> bool:
        return self._crown_icon.exists

    @property
    @allure.step('Get coin symbol')
    def get_coin_symbol(self) -> bool:
        return self._coin_icon.exists

    @allure.step('Get text labels')
    def get_all_text_labels(self) -> list:
        text_labels = []
        for item in driver.findAllObjects(self._edit_owner_token_text_object.real_name):
            text_labels.append(str(item.text))
        return text_labels

    @allure.step('Get all symbol boxes')
    def get_symbol_boxes(self):
        symbol_boxes = []
        for item in driver.findAllObjects(self._symbol_box.real_name):
            symbol_boxes.append(item)
        sorted(symbol_boxes, key=lambda item: item.y)
        return symbol_boxes

    @allure.step('Get all total boxes')
    def get_total_boxes(self):
        total_boxes = []
        for item in driver.findAllObjects(self._total_box.real_name):
            total_boxes.append(item)
        sorted(total_boxes, key=lambda item: item.y)
        return total_boxes

    @allure.step('Get all remaining boxes')
    def get_remaining_boxes(self):
        remaining_boxes = []
        for item in driver.findAllObjects(self._remaining_box.real_name):
            remaining_boxes.append(item)
        sorted(remaining_boxes, key=lambda item: item.y)
        return remaining_boxes

    @allure.step('Get all destructible boxes')
    def get_destructible_boxes(self):
        destructible_boxes = []
        for item in driver.findAllObjects(self._destructible_box.real_name):
            destructible_boxes.append(item)
        sorted(destructible_boxes, key=lambda item: item.y)
        return destructible_boxes

    @allure.step('Get all transferable boxes')
    def get_transferable_boxes(self):
        transferable_boxes = []
        for item in driver.findAllObjects(self._transferable_box.real_name):
            transferable_boxes.append(item)
        sorted(transferable_boxes, key=lambda item: item.y)
        return transferable_boxes

    @allure.step('Get owner symbol box content')
    def get_symbol_box_content(self, index: int) -> str:
        symbol_box = self.get_symbol_boxes()[index]
        return str(symbol_box.value)

    @allure.step('Get total box content')
    def get_total_box_content(self, index: int) -> str:
        total_box = self.get_total_boxes()[index]
        return str(total_box.value)

    @allure.step('Get remaining box content')
    def get_remaining_box_content(self, index: int) -> str:
        remaining_box = self.get_remaining_boxes()[index]
        return str(remaining_box.value)

    @allure.step('Get transferable box content')
    def get_transferable_box_content(self, index: int) -> str:
        transferable_box = self.get_transferable_boxes()[index]
        return str(transferable_box.value)

    @allure.step('Get destructible box content')
    def get_destructible_box_content(self, index: int) -> str:
        destructible_box = self.get_destructible_boxes()[index]
        return str(destructible_box.value)

    @allure.step('Select Mainnet network')
    def select_mainnet_network(self, attempts: int = 2):
        if not self._select_network_combobox.is_visible:
            self._scroll.vertical_down_to(self._select_network_combobox)
        self._select_network_combobox.click()
        try:
            self._mainnet_network_item.wait_until_appears()
            self._mainnet_network_item.click()
            return self
        except AssertionError as err:
            if attempts:
                self.select_mainnet_network(attempts - 1)
            else:
                raise err

    @allure.step('Click mint button')
    def click_mint(self):
        if not self._mint_button.is_visible:
            self._scroll.vertical_down_to(self._mint_button)
        self._mint_button.click()
        return SignTransactionPopup().wait_until_appears()


class MintedTokensView(QObject):
    def __init__(self):
        super(MintedTokensView, self).__init__(communities_names.mainWindow_MintedTokensView)
        self._coin_symbol = QObject(communities_names.token_sale_icon_StatusIcon)
        self._crown_symbol = QObject(communities_names.crown_icon_StatusIcon)
        self._master_token = QObject(communities_names.o_CollectibleView)
        self._owner_token = QObject(communities_names.o_CollectibleView_2)

    @property
    @allure.step('Check crown symbol is visible on owner token')
    def does_crown_exist(self) -> bool:
        return self._crown_symbol.exists

    @property
    @allure.step('Check coin symbol is visible on master token')
    def does_coin_exist(self) -> bool:
        return self._coin_symbol.exists

    @property
    @allure.step('Get title of owner token')
    def get_owner_token_title(self) -> str:
        return str(self._owner_token.object.title)

    @property
    @allure.step('Get title of master token')
    def get_master_token_title(self) -> str:
        return str(self._master_token.object.title)

    @property
    @allure.step('Get status of owner token')
    def get_owner_token_status(self) -> str:
        return str(self._owner_token.object.subTitle)

    @property
    @allure.step('Get status of master token')
    def get_master_token_status(self) -> str:
        return str(self._master_token.object.subTitle)
