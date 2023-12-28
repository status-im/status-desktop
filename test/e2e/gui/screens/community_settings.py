import time
import typing

import allure

import driver
from driver.objects_access import walk_children
from gui.components.color_select_popup import ColorSelectPopup
from gui.components.community.tags_select_popup import TagsSelectPopup
from gui.components.os.open_file_dialogs import OpenFileDialog
from gui.components.picture_edit_popup import PictureEditPopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from scripts.tools.image import Image


class CommunitySettingsScreen(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityLoader_Loader')
        self.left_panel = LeftPanel()


class LeftPanel(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityColumnView_CommunityColumnView')
        self._back_to_community_button = Button('mainWindow_communitySettingsBackToCommunityButton_StatusBaseText')
        self._overview_button = Button('overview_StatusNavigationListItem')
        self._members_button = Button('members_StatusNavigationListItem')
        self._permissions_button = Button('permissions_StatusNavigationListItem')
        self._tokens_button = Button('tokens_StatusNavigationListItem')
        self._airdrops_button = Button('airdrops_StatusNavigationListItem')

    @allure.step('Open community main view')
    def back_to_community(self):
        self._back_to_community_button.click()

    @allure.step('Open community overview')
    def open_overview(self) -> 'OverviewView':
        if not self._overview_button.is_selected:
            self._overview_button.click()
        return OverviewView().wait_until_appears()

    @allure.step('Open community members')
    def open_members(self) -> 'MembersView':
        if not self._members_button.is_selected:
            self._members_button.click()
        return MembersView().wait_until_appears()

    @allure.step('Open permissions')
    def open_permissions(self) -> 'PermissionsIntroView':
        self._permissions_button.click()
        return PermissionsIntroView().wait_until_appears()

    @allure.step('Open tokens')
    def open_tokens(self) -> 'TokensView':
        self._tokens_button.click()
        return TokensView().wait_until_appears()

    @allure.step('Open airdrops')
    def open_airdrops(self) -> 'AirdropsView':
        self._airdrops_button.click()
        return AirdropsView().wait_until_appears()


class OverviewView(QObject):

    def __init__(self):
        super().__init__('mainWindow_OverviewSettingsPanel')
        self._name_text_label = TextLabel('communityOverviewSettingsCommunityName_StatusBaseText')
        self._description_text_label = TextLabel('communityOverviewSettingsCommunityDescription_StatusBaseText')
        self._edit_button = Button('mainWindow_Edit_Community_StatusButton')

    @property
    @allure.step('Get community name')
    def name(self) -> str:
        return self._name_text_label.text

    @property
    @allure.step('Get community description')
    def description(self) -> str:
        return self._description_text_label.text

    @allure.step('Open edit community view')
    def open_edit_community_view(self, attempts: int = 2) -> 'EditCommunityView':
        time.sleep(0.5)
        self._edit_button.click()
        try:
            return EditCommunityView()
        except Exception as ex:
            if attempts:
                self.open_edit_community_view(attempts - 1)
            else:
                raise ex


class EditCommunityView(QObject):

    def __init__(self):
        super().__init__('mainWindow_communityEditPanelScrollView_EditSettingsPanel')
        self._scroll = Scroll('communityEditPanelScrollView_Flickable')
        self._name_text_edit = TextEdit('communityEditPanelScrollView_communityNameInput_TextEdit')
        self._description_text_edit = TextEdit('communityEditPanelScrollView_communityDescriptionInput_TextEdit')
        self._logo = QObject('communityEditPanelScrollView_image_StatusImage')
        self._add_logo_button = Button('communityEditPanelScrollView_editButton_StatusRoundButton')
        self._banner = QObject('communityEditPanelScrollView_image_StatusImage_2')
        self._add_banner_button = Button('communityEditPanelScrollView_editButton_StatusRoundButton_2')
        self._select_color_button = Button('communityEditPanelScrollView_StatusPickerButton')
        self._choose_tag_button = Button('communityEditPanelScrollView_Choose_StatusPickerButton')
        self._tag_item = QObject('communityEditPanelScrollView_StatusCommunityTag')
        self._archive_support_checkbox = CheckBox('communityEditPanelScrollView_archiveSupportToggle_StatusCheckBox')
        self._request_to_join_checkbox = CheckBox('communityEditPanelScrollView_requestToJoinToggle_StatusCheckBox')
        self._pin_messages_checkbox = CheckBox('communityEditPanelScrollView_pinMessagesToggle_StatusCheckBox')
        self._intro_text_edit = TextEdit('communityEditPanelScrollView_editCommunityIntroInput_TextEdit')
        self._outro_text_edit = TextEdit('communityEditPanelScrollView_editCommunityOutroInput_TextEdit')
        self._save_changes_button = Button('mainWindow_Save_changes_StatusButton')

    @property
    @allure.step('Get community name')
    def name(self) -> str:
        return self._name_text_edit.text

    @name.setter
    @allure.step('Set community name')
    def name(self, value: str):
        self._name_text_edit.text = value

    @property
    @allure.step('Get community description')
    def description(self) -> str:
        return self._description_text_edit.text

    @description.setter
    @allure.step('Set community description')
    def description(self, value: str):
        self._description_text_edit.text = value

    @property
    @allure.step('Get community logo')
    def logo(self) -> Image:
        return self._logo.image

    @logo.setter
    @allure.step('Set community description')
    def logo(self, kwargs: dict):
        self._add_logo_button.click()
        OpenFileDialog().wait_until_appears().open_file(kwargs['fp'])
        PictureEditPopup().wait_until_appears().make_picture(kwargs.get('zoom', None), kwargs.get('shift', None))

    @property
    @allure.step('Get community banner')
    def banner(self) -> Image:
        return self._banner.image

    @banner.setter
    @allure.step('Set community description')
    def banner(self, kwargs: dict):
        self._add_banner_button.click()
        OpenFileDialog().wait_until_appears().open_file(kwargs['fp'])
        PictureEditPopup().wait_until_appears().make_picture(kwargs.get('zoom', None), kwargs.get('shift', None))

    @property
    @allure.step('Get community color')
    def color(self) -> str:
        return str(self._select_color_button.object.text)

    @color.setter
    @allure.step('Set community color')
    def color(self, value: str):
        self._scroll.vertical_scroll_to(self._select_color_button)
        self._select_color_button.click()
        ColorSelectPopup().wait_until_appears().select_color(value)

    @property
    @allure.step('Get community tags')
    def tags(self):
        self._scroll.vertical_scroll_to(self._choose_tag_button)
        return [str(tag.title) for tag in driver.fiandAllObjects(self._tag_item.real_name)]

    @tags.setter
    @allure.step('Set community tags')
    def tags(self, values: typing.List[str]):
        self._scroll.vertical_scroll_to(self._choose_tag_button)
        self._choose_tag_button.click()
        TagsSelectPopup().wait_until_appears().select_tags(values)

    @property
    @allure.step('Get community intro')
    def intro(self) -> str:
        self._scroll.vertical_scroll_to(self._intro_text_edit)
        return self._intro_text_edit.text

    @intro.setter
    @allure.step('Set community intro')
    def intro(self, value: str):
        self._scroll.vertical_scroll_to(self._intro_text_edit)
        self._intro_text_edit.text = value

    @property
    @allure.step('Get community outro')
    def outro(self) -> str:
        self._scroll.vertical_scroll_to(self._outro_text_edit)
        return self._outro_text_edit.text

    @outro.setter
    @allure.step('Set community outro')
    def outro(self, value: str):
        self._scroll.vertical_scroll_to(self._outro_text_edit)
        self._outro_text_edit.text = value

    @allure.step('Edit community')
    def edit(self, kwargs):
        for key in list(kwargs):
            setattr(self, key, kwargs.get(key))
        self._save_changes_button.click()
        self.wait_until_hidden()


class MembersView(QObject):

    def __init__(self):
        super().__init__('mainWindow_MembersSettingsPanel')
        self._member_list_item = QObject('memberItem_StatusMemberListItem')

    @property
    @allure.step('Get community members')
    def members(self) -> typing.List[str]:
        return [str(member.title) for member in driver.findAllObjects(self._member_list_item.real_name)]


class TokensView(QObject):
    def __init__(self):
        super(TokensView, self).__init__('mainWindow_mintPanel_MintTokensSettingsPanel')
        self._mint_token_button = Button('mainWindow_Mint_token_StatusButton')
        self._welcome_image = QObject('welcomeSettingsTokens_Image')
        self._welcome_title = TextLabel('welcomeSettingsTokens_Title')
        self._welcome_subtitle = TextLabel('welcomeSettingsTokensSubtitle')
        self._welcome_checklist_1 = TextLabel('checkListText_0_Tokens')
        self._welcome_checklist_2 = TextLabel('checkListText_1_Tokens')
        self._welcome_checklist_3 = TextLabel('checkListText_2_Tokens')
        self._get_started_infobox = QObject('mint_Owner_Tokens_InfoBoxPanel')
        self._mint_owner_token_button = Button('mint_Owner_Tokens_StatusButton')

    @property
    @allure.step('Get mint token button visibility state')
    def is_mint_token_button_visible(self) -> bool:
        return self._mint_token_button.is_visible

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


class AirdropsView(QObject):
    def __init__(self):
        super(AirdropsView, self).__init__('mainWindow_airdropPanel_AirdropsSettingsPanel')
        self._new_airdrop_button = Button('mainWindow_New_Airdrop_StatusButton')
        self._welcome_image = QObject('welcomeSettingsAirdrops_Image')
        self._welcome_title = TextLabel('welcomeSettingsAirdrops_Title')
        self._welcome_subtitle = TextLabel('welcomeSettingsAirdrops_Subtitle')
        self._welcome_checklist_1 = TextLabel('checkListText_0_Airdrops')
        self._welcome_checklist_2 = TextLabel('checkListText_1_Airdrops')
        self._welcome_checklist_3 = TextLabel('checkListText_2_Airdrops')
        self._get_started_infobox = QObject('infoBox_StatusInfoBoxPanel')
        self._mint_owner_token_button = Button('mint_Owner_token_Airdrops_StatusButton')

    @property
    @allure.step('Get new airdrop button visibility state')
    def is_new_airdrop_button_visible(self) -> bool:
        return self._new_airdrop_button.is_visible

    @property
    @allure.step('Get airdrops welcome image path')
    def airdrops_welcome_image_path(self) -> str:
        return self._welcome_image.object.source.path

    @property
    @allure.step('Get airdrops welcome title')
    def airdrops_welcome_title(self) -> str:
        return self._welcome_title.text

    @property
    @allure.step('Get airdrops welcome subtitle')
    def airdrops_welcome_subtitle(self) -> str:
        return self._welcome_subtitle.text

    @property
    @allure.step('Get airdrops checklist')
    def airdrops_checklist(self) -> typing.List[str]:
        airdrops_checklist = [str(self._welcome_checklist_1.object.text), str(self._welcome_checklist_2.object.text),
                              str(self._welcome_checklist_3.object.text)]
        return airdrops_checklist

    @property
    @allure.step('Get airdrops info box title')
    def airdrops_infobox_title(self) -> str:
        return self._get_started_infobox.object.title

    @property
    @allure.step('Get airdrops info box text')
    def airdrops_infobox_text(self) -> str:
        return self._get_started_infobox.object.text

    @property
    @allure.step('Get airdrops mint owner token button visibility state')
    def is_airdrops_owner_token_button_visible(self) -> bool:
        return self._mint_owner_token_button.is_visible


class PermissionsIntroView(QObject):
    def __init__(self):
        super(PermissionsIntroView, self).__init__('o_IntroPanel')
        self._add_new_permission_button = Button('add_new_permission_button')
        self._welcome_image = QObject('community_welcome_screen_image')
        self._welcome_title = TextLabel('community_welcome_screen_title')
        self._welcome_subtitle = TextLabel('community_welcome_screen_subtitle')
        self._welcome_checklist_1 = TextLabel('community_welcome_screen_checkList_element1')
        self._welcome_checklist_2 = TextLabel('community_welcome_screen_checkList_element2')
        self._welcome_checklist_3 = TextLabel('community_welcome_screen_checkList_element3')

    @property
    @allure.step('Get permission welcome image path')
    def permission_welcome_image_source(self) -> str:
        return self._welcome_image.object.source.path

    @property
    @allure.step('Get permission welcome title')
    def permission_welcome_title(self) -> str:
        return self._welcome_title.text

    @property
    @allure.step('Get permission welcome subtitle')
    def permission_welcome_subtitle(self) -> str:
        return self._welcome_subtitle.text

    @property
    @allure.step('Get permission checklist')
    def permission_checklist(self) -> typing.List[str]:
        permission_checklist = [str(self._welcome_checklist_1.object.text), str(self._welcome_checklist_2.object.text),
                                str(self._welcome_checklist_3.object.text)]
        return permission_checklist

    @allure.step('Click add new permission button')
    def add_new_permission(self) -> 'PermissionsSettingsView':
        self._add_new_permission_button.click()
        return PermissionsSettingsView().wait_until_appears()


class PermissionsSettingsView(QObject):
    def __init__(self):
        super(PermissionsSettingsView, self).__init__('mainWindow_PermissionsSettingsPanel')
        self._who_holds_checkbox = CheckBox('editPermissionView_whoHoldsSwitch_StatusSwitch')
        self._who_holds_asset_field = TextEdit('edit_TextEdit')
        self._who_holds_amount_field = TextEdit('inputValue_StyledTextField')
        self._asset_item = QObject('o_TokenItem')
        self._is_allowed_to_option_button = Button('customPermissionListItem')
        self._in_general_button = Button('communityItem_CommunityListItem')
        self._hide_permission_checkbox = CheckBox('editPermissionView_switchItem_StatusSwitch')
        self._create_permission_button = Button('editPermissionView_Create_permission_StatusButton')
        self._add_button = Button('add_StatusButton')
        self._who_holds_list_item = QObject('editPermissionView_Who_holds_StatusItemSelector')
        self._is_allowed_to_list_item = QObject('editPermissionView_Is_allowed_to_StatusFlowSelector')
        self._in_list_item = QObject('editPermissionView_In_StatusItemSelector')
        self._tag_item = QObject('o_StatusListItemTag')
        self._who_holds_tag = QObject('whoHoldsTagListItem')
        self._is_allowed_tag = QObject('isAllowedTagListItem')
        self._in_community_in_channel_tag = QObject('inCommunityTagListItem')

    @allure.step('Get titles of Who holds tags')
    def get_who_holds_tags_titles(self) -> typing.List[str]:
        who_holds_tags = [str(tag.title) for tag in driver.findAllObjects(self._who_holds_tag.real_name)]
        return who_holds_tags

    @allure.step('Get titles of Is Allowed tags')
    def get_is_allowed_tags_titles(self) -> typing.List[str]:
        is_allowed_tags = [str(tag.title) for tag in driver.findAllObjects(self._is_allowed_tag.real_name)]
        return is_allowed_tags

    @allure.step('Get title of inCommunity tag')
    def get_in_community_in_channel_tags_titles(self) -> typing.List[str]:
        in_community_in_channel_tags = [str(tag.title) for tag in driver.findAllObjects(self._in_community_in_channel_tag.real_name)]
        return in_community_in_channel_tags

    @allure.step('Set state of who holds checkbox')
    def set_who_holds_checkbox_state(self, state):
        if state is False:
            self._who_holds_checkbox.set(state)

    @allure.step('Set asset and amount')
    def set_who_holds_asset_and_amount(self, asset: str, amount: str):
        if asset is not False:
            self.open_who_holds_context_menu()
            self._who_holds_asset_field.clear().text = asset
            self._asset_item.click()
            self._who_holds_asset_field.wait_until_hidden()
            self._who_holds_amount_field.text = amount
            self._add_button.click()

    @allure.step('Choose option from Is allowed to context menu')
    def set_is_allowed_to(self, name):
        self.open_is_allowed_to_context_menu()
        self._is_allowed_to_option_button.real_name['objectName'] = name
        self._is_allowed_to_option_button.wait_until_appears().click()
        self._add_button.click()

    @allure.step('Choose channel from In context menu')
    def set_in(self, in_general):
        if in_general == '#general':
            self.open_in_context_menu()
            self._in_general_button.wait_until_appears().click()
            self._add_button.click()

    @allure.step('Click create permission')
    def create_permission(self):
        self._create_permission_button.click()
        self._create_permission_button.wait_until_hidden()

    @allure.step('Open Who holds context menu')
    def open_who_holds_context_menu(self):
        for child in walk_children(self._who_holds_list_item.object):
            if getattr(child, 'id', '') == 'addItemButton':
                driver.mouseClick(child)
                return
        raise LookupError('Add button for who holds not found')

    @allure.step('Open Is allowed to context menu')
    def open_is_allowed_to_context_menu(self):
        for child in walk_children(self._is_allowed_to_list_item.object):
            if getattr(child, 'id', '') == 'addItemButton':
                driver.mouseClick(child)
                return
        raise LookupError('Add button for allowed to not found')

    @allure.step('Open In context menu')
    def open_in_context_menu(self):
        for child in walk_children(self._in_list_item.object):
            if getattr(child, 'id', '') == 'addItemButton':
                driver.mouseClick(child)
                return
        raise LookupError('Add button for in not found')
