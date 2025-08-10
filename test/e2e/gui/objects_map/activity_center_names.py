from gui.objects_map.names import statusDesktop_mainWindow
from objectmaphelper import *

# Map for activity center

activityCenterLeftPanel = {"container": statusDesktop_mainWindow, "objectName": "activityCenterLeftPanel", "type": "ColumnLayout", "visible": True}
activityCenterListView = {"container": statusDesktop_mainWindow, "id": "listView", "type": "StatusListView", "unnamed": 1, "visible": True}
activityCenterListLoader = {"container": activityCenterListView, "index": 0, "type": "Loader", "unnamed": 1, "visible": True}
activityCenterContactRequest = {"container": activityCenterListLoader, "type": "ActivityNotificationContactRequest", "unnamed": 1, "visible": True}
activityCenterContactRequestAcceptButton = {"container": activityCenterListLoader, "objectName": "acceptBtn", "type": "StatusFlatRoundButton", "visible": True}
activityCenterContactRequestDeclineButton = {"container": activityCenterListLoader, "objectName": "declineBtn", "type": "StatusFlatRoundButton", "visible": True}
activityCenterContactRequestMoreButton = {"container": activityCenterListLoader, "objectName": "moreBtn", "type": "StatusFlatRoundButton", "visible": True}
activityCenterContactRequestHeader = {"container": activityCenterContactRequest, "type": "NotificationBaseHeaderRow", "unnamed": 1, "visible": True}
activityCenterScrollView = {"container": statusDesktop_mainWindow, "type": "StatusScrollView", "unnamed": 1, "visible": True}
activityCenterGroupButton = {"container": activityCenterScrollView, "objectName": "activityCenterGroupButton", "type": "StatusFlatButton", "visible": True}
activityCenterNavigationButton = {"container": activityCenterLeftPanel, "type": "StatusNavigationButton", "visible": True}