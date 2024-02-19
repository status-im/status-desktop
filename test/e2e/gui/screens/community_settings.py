import time
import typing

import allure

import driver
from driver.objects_access import walk_children
from gui.components.community.color_select_popup import ColorSelectPopup
from gui.components.community.tags_select_popup import TagsSelectPopup
from gui.components.os.open_file_dialogs import OpenFileDialog
from gui.components.picture_edit_popup import PictureEditPopup
from gui.elements.button import Button
from gui.elements.check_box import CheckBox
from gui.elements.object import QObject
from gui.elements.scroll import Scroll
from gui.elements.text_edit import TextEdit
from gui.elements.text_label import TextLabel
from gui.objects_map import names
from scripts.tools.image import Image


class CommunitySettingsScreen(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_communityLoader_Loader)
        self.left_panel = LeftPanel()


class LeftPanel(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_communityColumnView_CommunityColumnView)
        self._back_to_community_button = Button(names.mainWindow_communitySettingsBackToCommunityButton_StatusBaseText)
        self._overview_button = Button(names.overview_StatusNavigationListItem)
        self._members_button = Button(names.members_StatusNavigationListItem)
        self._permissions_button = Button(names.permissions_StatusNavigationListItem)
        self._tokens_button = Button(names.tokens_StatusNavigationListItem)
        self._airdrops_button = Button(names.airdrops_StatusNavigationListItem)

    @allure.step('Open community main view')
    def back_to_community(self):
        self._back_to_community_button.click()

    @allure.step('Open community overview')
    def open_overview(self) -> 'OverviewView':
        if not self._overview_button.is_selected:
            self._overview_button.click()
        return OverviewView()

    @allure.step('Open community members')
    def open_members(self) -> 'MembersView':
        if not self._members_button.is_selected:
            self._members_button.click()
        return MembersView()

    @allure.step('Open permissions')
    def open_permissions(self) -> 'PermissionsIntroView':
        self._permissions_button.click()
        return PermissionsIntroView()

    @allure.step('Open tokens')
    def open_tokens(self) -> 'TokensView':
        self._tokens_button.click()
        return TokensView()

    @allure.step('Open airdrops')
    def open_airdrops(self) -> 'AirdropsView':
        self._airdrops_button.click()
        return AirdropsView()


class OverviewView(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_OverviewSettingsPanel)
        self._name_text_label = TextLabel(names.communityOverviewSettingsCommunityName_StatusBaseText)
        self._description_text_label = TextLabel(names.communityOverviewSettingsCommunityDescription_StatusBaseText)
        self._edit_button = Button(names.mainWindow_Edit_Community_StatusButton)

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
        super().__init__(names.mainWindow_communityEditPanelScrollView_EditSettingsPanel)
        self._scroll = Scroll(names.communityEditPanelScrollView_Flickable)
        self._name_text_edit = TextEdit(names.communityEditPanelScrollView_communityNameInput_TextEdit)
        self._description_text_edit = TextEdit(names.communityEditPanelScrollView_communityDescriptionInput_TextEdit)
        self._logo = QObject(names.communityEditPanelScrollView_image_StatusImage)
        self._add_logo_button = Button(names.communityEditPanelScrollView_editButton_StatusRoundButton)
        self._banner = QObject(names.communityEditPanelScrollView_image_StatusImage_2)
        self._add_banner_button = Button(names.communityEditPanelScrollView_editButton_StatusRoundButton_2)
        self._select_color_button = Button(names.communityEditPanelScrollView_StatusPickerButton)
        self._choose_tag_button = Button(names.communityEditPanelScrollView_Choose_StatusPickerButton)
        self._tag_item = QObject(names.communityEditPanelScrollView_StatusCommunityTag)
        self._archive_support_checkbox = CheckBox(
            names.communityEditPanelScrollView_archiveSupportToggle_StatusCheckBox)
        self._request_to_join_checkbox = CheckBox(names.communityEditPanelScrollView_requestToJoinToggle_StatusCheckBox)
        self._pin_messages_checkbox = CheckBox(names.communityEditPanelScrollView_pinMessagesToggle_StatusCheckBox)
        self._intro_text_edit = TextEdit(names.communityEditPanelScrollView_editCommunityIntroInput_TextEdit)
        self._outro_text_edit = TextEdit(names.communityEditPanelScrollView_editCommunityOutroInput_TextEdit)
        self._save_changes_button = Button(names.mainWindow_Save_changes_StatusButton)
        self._cropped_image_edit_logo_item = QObject(names.croppedImageEditLogo)
        self._cropped_image_edit_banner_item = QObject(names.croppedImageEditBanner)

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

    @allure.step('Set community logo')
    def logo(self, kwargs: dict):
        self._add_logo_button.click()
        OpenFileDialog().wait_until_appears().open_file(kwargs['fp'])
        PictureEditPopup().wait_until_appears().set_zoom_shift_for_picture(kwargs.get('zoom', None), kwargs.get('shift', None))

    @property
    @allure.step('Get community banner')
    def banner(self) -> Image:
        return self._banner.image

    @allure.step('Set community banner')
    def banner(self, kwargs: dict):
        self._add_banner_button.click()
        OpenFileDialog().wait_until_appears().open_file(kwargs['fp'])
        PictureEditPopup().wait_until_appears().set_zoom_shift_for_picture(kwargs.get('zoom', None), kwargs.get('shift', None))

    @allure.step('Set community logo without file upload dialog')
    def set_logo_without_file_upload_dialog(self, path):
        self._cropped_image_edit_logo_item.object.cropImage('file://' + str(path))
        return PictureEditPopup()

    @allure.step('Set community banner without file upload dialog')
    def set_banner_without_file_upload_dialog(self, path):
        self._cropped_image_edit_banner_item.object.cropImage('file://' + str(path))
        return PictureEditPopup()

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

    @property
    @allure.step('Get pin message checkbox state')
    def pin_message_checkbox_state(self) -> bool:
        self._scroll.vertical_scroll_to(self._pin_messages_checkbox)
        return self._pin_messages_checkbox.object.checked

    @allure.step('Edit community')
    def edit(self, name, description, intro, outro, logo, banner):
        self._scroll.vertical_scroll_to(self._name_text_edit)
        self.name = name
        self.description = description
        self.set_logo_without_file_upload_dialog(logo)
        PictureEditPopup().set_zoom_shift_for_picture(None, None)
        self.set_banner_without_file_upload_dialog(banner)
        PictureEditPopup().set_zoom_shift_for_picture(None, None)
        self.intro = intro
        self.outro = outro
        self._save_changes_button.click()
        self.wait_until_hidden()


class MembersView(QObject):

    def __init__(self):
        super().__init__(names.mainWindow_MembersSettingsPanel)
        self._member_list_item = QObject(names.memberItem_StatusMemberListItem)

    @property
    @allure.step('Get community members')
    def members(self) -> typing.List[str]:
        return [str(member.title) for member in driver.findAllObjects(self._member_list_item.real_name)]


class TokensView(QObject):
    def __init__(self):
        super(TokensView, self).__init__(names.mainWindow_mintPanel_MintTokensSettingsPanel)
        self._mint_token_button = Button(names.mainWindow_Mint_token_StatusButton)
        self._welcome_image = QObject(names.welcomeSettingsTokens_Image)
        self._welcome_title = TextLabel(names.welcomeSettingsTokens_Title)
        self._welcome_subtitle = TextLabel(names.welcomeSettingsTokensSubtitle)
        self._welcome_checklist_1 = TextLabel(names.checkListText_0_Tokens)
        self._welcome_checklist_2 = TextLabel(names.checkListText_1_Tokens)
        self._welcome_checklist_3 = TextLabel(names.checkListText_2_Tokens)
        self._get_started_infobox = QObject(names.mint_Owner_Tokens_InfoBoxPanel)
        self._mint_owner_token_button = Button(names.mint_Owner_Tokens_StatusButton)

    @property
    @allure.step('Get mint token button enable state')
    def is_mint_token_button_present(self) -> bool:
        return self._mint_token_button.exists

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
        super(AirdropsView, self).__init__(names.mainWindow_airdropPanel_AirdropsSettingsPanel)
        self._new_airdrop_button = Button(names.mainWindow_New_Airdrop_StatusButton)
        self._welcome_image = QObject(names.welcomeSettingsAirdrops_Image)
        self._welcome_title = TextLabel(names.welcomeSettingsAirdrops_Title)
        self._welcome_subtitle = TextLabel(names.welcomeSettingsAirdrops_Subtitle)
        self._welcome_checklist_1 = TextLabel(names.checkListText_0_Airdrops)
        self._welcome_checklist_2 = TextLabel(names.checkListText_1_Airdrops)
        self._welcome_checklist_3 = TextLabel(names.checkListText_2_Airdrops)
        self._get_started_infobox = QObject(names.infoBox_StatusInfoBoxPanel)
        self._mint_owner_token_button = Button(names.mint_Owner_token_Airdrops_StatusButton)

    @property
    @allure.step('Get new airdrop button enable state')
    def is_new_airdrop_button_present(self) -> bool:
        return self._new_airdrop_button.exists

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
        super(PermissionsIntroView, self).__init__(names.o_IntroPanel)
        self._add_new_permission_button = Button(names.add_new_permission_button)
        self._welcome_image = QObject(names.community_welcome_screen_image)
        self._welcome_title = TextLabel(names.community_welcome_screen_title)
        self._welcome_subtitle = TextLabel(names.community_welcome_screen_subtitle)
        self._welcome_checklist_1 = TextLabel(names.community_welcome_screen_checkList_element1)
        self._welcome_checklist_2 = TextLabel(names.community_welcome_screen_checkList_element2)
        self._welcome_checklist_3 = TextLabel(names.community_welcome_screen_checkList_element3)
        self._edit_permission_button = QObject(names.edit_pencil_icon_StatusIcon)
        self._delete_permission_button = QObject(names.delete_icon_StatusIcon)
        self._hide_icon = QObject(names.hide_icon_StatusIcon)

    @property
    @allure.step('Get hide icon visibility')
    def is_hide_icon_visible(self) -> bool:
        return self._hide_icon.is_visible

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
        return PermissionsSettingsView()

    @property
    @allure.step('Is add new permission button visible')
    def is_add_new_permission_button_present(self) -> bool:
        return self._add_new_permission_button.exists

    @allure.step('Open edit permission view')
    def open_edit_permission_view(self):
        self._edit_permission_button.click()
        return PermissionsSettingsView().wait_until_appears()

    @allure.step('Click delete permission button')
    def click_delete_permission(self):
        self._delete_permission_button.click()


class PermissionsSettingsView(QObject):
    def __init__(self):
        super(PermissionsSettingsView, self).__init__(names.mainWindow_PermissionsSettingsPanel)
        self._who_holds_checkbox = CheckBox(names.editPermissionView_whoHoldsSwitch_StatusSwitch)
        self._who_holds_asset_field = TextEdit(names.edit_TextEdit)
        self._who_holds_amount_field = TextEdit(names.inputValue_StyledTextField)
        self._asset_item = QObject(names.o_TokenItem)
        self._is_allowed_to_option_button = Button(names.customPermissionListItem)
        self._in_general_button = Button(names.communityItem_CommunityListItem)
        self._hide_permission_checkbox = CheckBox(names.editPermissionView_switchItem_StatusSwitch)
        self._create_permission_button = Button(names.editPermissionView_Create_permission_StatusButton)
        self._add_button = Button(names.add_StatusButton)
        self._who_holds_list_item = QObject(names.editPermissionView_Who_holds_StatusItemSelector)
        self._is_allowed_to_list_item = QObject(names.editPermissionView_Is_allowed_to_StatusFlowSelector)
        self._in_list_item = QObject(names.editPermissionView_In_StatusItemSelector)
        self._tag_item = QObject(names.o_StatusListItemTag)
        self._who_holds_tag = QObject(names.whoHoldsTagListItem)
        self._is_allowed_tag = QObject(names.isAllowedTagListItem)
        self._in_community_in_channel_tag = QObject(names.inCommunityTagListItem)
        self._is_allowed_to_edit_tag = QObject(names.isAllowedToEditPermissionView_StatusListItemTag)

    @allure.step('Get titles of Who holds tags')
    def get_who_holds_tags_titles(self, attempt: int = 2) -> typing.List[str]:
        try:
            return [str(tag.title) for tag in driver.findAllObjects(self._who_holds_tag.real_name)]
        except AttributeError as er:
            if attempt:
                time.sleep(1)
                return self.get_who_holds_tags_titles(attempt - 1)
            else:
                raise er

    @allure.step('Get titles of Is Allowed tags')
    def get_is_allowed_tags_titles(self, attempt: int = 2) -> typing.List[str]:
        try:
            return [str(tag.title) for tag in driver.findAllObjects(self._is_allowed_tag.real_name)]
        except AttributeError as er:
            if attempt:
                time.sleep(1)
                return self.get_is_allowed_tags_titles(attempt - 1)
            else:
                raise er

    @allure.step('Get title of inCommunity tag')
    def get_in_community_in_channel_tags_titles(self, attempt: int = 2) -> typing.List[str]:
        try:
            return [str(tag.title) for tag in driver.findAllObjects(self._in_community_in_channel_tag.real_name)]
        except AttributeError as er:
            if attempt:
                time.sleep(1)
                return self.get_in_community_in_channel_tags_titles(attempt - 1)
            else:
                raise er

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
            self.click_add_button()

    @allure.step('Choose option from Is allowed to context menu')
    def set_is_allowed_to(self, name):
        self.open_is_allowed_to_context_menu()
        self._is_allowed_to_option_button.real_name['objectName'] = name
        self._is_allowed_to_option_button.wait_until_appears().click()
        self.click_add_button()

    @allure.step('Choose channel from In context menu')
    def set_in(self, in_general):
        if in_general == '#general':
            self.open_in_context_menu()
            self._in_general_button.wait_until_appears().click()
            self.click_add_button()

    @allure.step('Click add button')
    def click_add_button(self, attempt: int = 2):
        self._add_button.click()
        try:
            self._add_button.wait_until_hidden()
        except AssertionError as err:
            if attempt:
                self.click_add_button(attempt - 1)
            else:
                raise err

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

    @allure.step('Switch hide permission checkbox')
    def switch_hide_permission_checkbox(self, state):
        self._hide_permission_checkbox.set(state)

    @allure.step('Change allowed to option from permission')
    def set_allowed_to_from_permission(self, name):
        self._is_allowed_to_edit_tag.click()
        self._is_allowed_to_option_button.real_name['objectName'] = name
        self._is_allowed_to_option_button.wait_until_appears().click()
        self.click_add_button()
