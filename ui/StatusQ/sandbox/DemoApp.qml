import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Layout
import StatusQ.Popups
import StatusQ.Platform

import "demoapp"
import "demoapp/data"

import SortFilterProxyModel

Rectangle {
    id: demoApp
    height: 602
    width: 1002
    border.width: 1
    border.color: Theme.palette.baseColor2

    property string titleStyle: "osx"

    QtObject {
        id: appSectionType
        readonly property int chat: 0
        readonly property int community: 1
        readonly property int communitiesPortal: 2
        readonly property int wallet: 3
        readonly property int browser: 3
        readonly property int nodeManagement: 5
        readonly property int profileSettings: 6
        readonly property int apiDocumentation: 100
        readonly property int demoApp: 101
    }

    function setActiveItem(sectionId) {
        for (var i = 0; i < Models.demoAppSectionsModel.count; i++) {
            let item = Models.demoAppSectionsModel.get(i)
            if (item.sectionId !== sectionId)
            {
                Models.demoAppSectionsModel.setProperty(i, "active", false)
                continue
            }

            Models.demoAppSectionsModel.setProperty(i, "active", true);
        }
    }

    StatusWindowsTitleBar {
        id: windowsTitle
        anchors.top: parent.top
        width: parent.width
        z: statusAppLayout.z + 1
        visible: titleStyle === "windows"
    }

    StatusMainLayout {
        id: statusAppLayout
        anchors.top: windowsTitle.visible ? windowsTitle.bottom : demoApp.top
        anchors.left: demoApp.left
        anchors.topMargin: demoApp.border.width
        anchors.leftMargin: demoApp.border.width

        height: demoApp.height - demoApp.border.width * 2
        width: demoApp.width - demoApp.border.width * 2

        leftPanel: StatusAppNavBar {
            id: navBar

            topSectionModel: SortFilterProxyModel {
                sourceModel: Models.demoAppSectionsModel
                filters: ValueFilter {
                    roleName: "sectionType"
                    value: appSectionType.chat
                }
            }

            topSectionDelegate: navButtonComponent

            communityItemsModel: SortFilterProxyModel {
                sourceModel: Models.demoAppSectionsModel
                filters: ValueFilter {
                    roleName: "sectionType"
                    value: appSectionType.community
                }
            }

            communityItemDelegate: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                onClicked: {
                    if(model.sectionType === appSectionType.community)
                    {
                        appView.sourceComponent = statusAppCommunityView
                        demoApp.setActiveItem(model.sectionId)
                    }
                }

                popupMenu: StatusMenu {

                    StatusAction {
                        text: qsTr("Invite People")
                        icon.name: "share-ios"
                        objectName: "invitePeople"
                    }

                    StatusAction {
                        text: qsTr("View Community")
                        icon.name: "group"
                    }

                    StatusAction {
                        text: qsTr("Edit Community")
                        icon.name: "edit"
                        enabled: false
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: qsTr("Leave Community")
                        icon.name: "arrow-left"
                        type: StatusAction.Type.Danger
                    }
                }
            }

            regularItemsModel: SortFilterProxyModel {
                sourceModel: Models.demoAppSectionsModel
                filters: RangeFilter {
                    roleName: "sectionType"
                    minimumValue: appSectionType.communitiesPortal
                    maximumValue: appSectionType.demoApp
                }
            }
            regularItemDelegate: navButtonComponent

            delegateHeight: 40

            Component {
                id: navButtonComponent
                StatusNavBarTabButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: model.icon.length > 0? "" : model.name
                    icon.name: model.icon
                    icon.source: model.image
                    tooltip.text: model.name
                    autoExclusive: true
                    checked: model.active
                    badge.value: model.notificationsCount
                    badge.visible: model.hasNotification
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                    badge.border.width: 2
                    onClicked: {
                        if(model.sectionType === appSectionType.chat)
                        {
                            appView.sourceComponent = statusAppChatView
                            demoApp.setActiveItem(model.sectionId)
                        }
                        else if(model.sectionType === appSectionType.communitiesPortal)
                        {
                            appView.sourceComponent = statusCommunityPortalView
                            demoApp.setActiveItem(model.sectionId)
                        }
                        else if(model.sectionType === appSectionType.profileSettings)
                        {
                            appView.sourceComponent = statusAppProfileSettingsView
                            demoApp.setActiveItem(model.sectionId)
                        }
                    }
                }
            }
        }

        rightPanel: Loader {
            id: appView
            anchors.fill: parent
            sourceComponent: statusAppChatView
        }
    }

    Component {
        id: statusAppChatView
        StatusAppChatView { }
    }

    Component {
        id: statusAppCommunityView
        StatusAppCommunityView {
            communityDetailModalTitle: demoCommunityDetailModal.headerSettings.title
            communityDetailModalImage: demoCommunityDetailModal.headerSettings.asset.name
            onChatInfoButtonClicked: {
                demoCommunityDetailModal.open();
            }
        }
    }

    Component {
        id: statusAppProfileSettingsView
        StatusAppProfileSettingsView { }
    }

    Component {
        id: statusCommunityPortalView
        StatusAppCommunitiesPortalView { }
    }

    DemoContactRequestsModal {
        id: demoContactRequestsModal
        anchors.centerIn: parent
    }

    DemoCommunityDetailModal {
        id: demoCommunityDetailModal
    }
}
