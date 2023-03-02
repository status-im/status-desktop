# encoding: UTF-8

from objectmaphelper import *

from scripts.onboarding_names import *
from scripts.login_names import *
from scripts.settings_names import *

from community_names import *
from community_portal_names import *
from search_names import *


communitySettingsView_NavigationListItem_Permissions_Permissions_StatusTextWithLoadingState = {"container": communitySettings_Permissions_NavigationListItem, "text": "Permissions", "type": "StatusTextWithLoadingState", "unnamed": 1, "visible": True}
communitySettingsView_NavigationListItem_Members_Members_StatusTextWithLoadingState = {"container": communitySettings_Members_NavigationListItem, "text": "Members", "type": "StatusTextWithLoadingState", "unnamed": 1, "visible": True}
mainWindow_content_Rectangle = {"container": statusDesktop_mainWindow, "id": "content", "type": "Rectangle", "unnamed": 1, "visible": True}
mainWindow_listView_StatusListView = {"container": statusDesktop_mainWindow, "id": "listView", "type": "StatusListView", "unnamed": 1, "visible": True}
listView_CommunitySettingsView_NavigationListItem_Overview_StatusNavigationListItem = {"container": mainWindow_listView_StatusListView, "index": 0, "objectName": "CommunitySettingsView_NavigationListItem_Overview", "type": "StatusNavigationListItem", "visible": True}
communitySettingsView_NavigationListItem_Overview_Overview_StatusTextWithLoadingState = {"container": listView_CommunitySettingsView_NavigationListItem_Overview_StatusNavigationListItem, "text": "Overview", "type": "StatusTextWithLoadingState", "unnamed": 1, "visible": True}
communitySettingsView_NavigationListItem_Overview_show_icon_StatusIcon = {"container": listView_CommunitySettingsView_NavigationListItem_Overview_StatusNavigationListItem, "objectName": "show-icon", "source": "qrc:/StatusQ/src/assets/img/icons/show.svg", "type": "StatusIcon", "visible": True}
communitySettingsView_NavigationListItem_Members_group_chat_icon_StatusIcon = {"container": communitySettings_Members_NavigationListItem, "objectName": "group-chat-icon", "source": "qrc:/StatusQ/src/assets/img/icons/group-chat.svg", "type": "StatusIcon", "visible": True}
communitySettingsView_NavigationListItem_Permissions_objects_icon_StatusIcon = {"container": communitySettings_Permissions_NavigationListItem, "objectName": "objects-icon", "source": "qrc:/StatusQ/src/assets/img/icons/objects.svg", "type": "StatusIcon", "visible": True}
