import logging
import time
import typing

import allure

import configs.timeouts
import driver
from constants import CommunityData
from driver import objects_access
from gui.elements.button import Button
from gui.elements.object import QObject
from gui.elements.text_label import TextLabel
from gui.objects_map import settings_names
from gui.screens.community_settings import CommunitySettingsScreen

LOG = logging.getLogger(__name__)


class CommunitiesSettingsView(QObject):

    def __init__(self):
        super().__init__(settings_names.mainWindow_CommunitiesView)
        self._community_item = QObject(settings_names.settingsContentBaseScrollView_listItem_StatusListItem)
        self._community_template_image = QObject(settings_names.settings_iconOrImage_StatusSmartIdenticon)
        self._community_template_name_members = QObject(settings_names.settings_StatusTextWithLoadingState)
        self._community_template_description = TextLabel(settings_names.settings_statusListItemSubTitle)
        self._community_template_button = Button(settings_names.settings_StatusFlatButton)

    @property
    @allure.step('Get list of communities from settings')
    def communities(self) -> typing.List[CommunityData]:
        time.sleep(0.5)
        _communities = []
        for obj in driver.findAllObjects(self._community_item.real_name):
            container = driver.objectMap.realName(obj)
            self._community_template_image.real_name['container'] = container
            self._community_template_name_members.real_name['container'] = container
            self._community_template_description.real_name['container'] = container

            description = self._community_template_description.text
            name_members_labels = []
            for item in driver.findAllObjects(self._community_template_name_members.real_name):
                name_members_labels.append(item)
            sorted(name_members_labels, key=lambda item: item.y)
            name = str(name_members_labels[0].text)
            members = str(name_members_labels[1].text)
            image = self._community_template_image.image

            _communities.append(CommunityData(name, description, members, image))
        return _communities



