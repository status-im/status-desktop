import QtQuick 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1
import StatusQ.Platform 0.1

import "demoapp"

Rectangle {
    id: demoApp
    height: 602
    width: 1002
    border.width: 1
    border.color: Theme.palette.baseColor2

    property string titleStyle: "osx"

    StatusMacTrafficLights {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 13
        z: statusAppLayout.z + 1
        visible: titleStyle === "osx"
    }

    StatusWindowsTitleBar {
        id: windowsTitle
        anchors.top: parent.top
        width: parent.width
        z: statusAppLayout.z + 1
        visible: titleStyle === "windows"
    }

    StatusAppLayout {
        id: statusAppLayout
        anchors.top: windowsTitle.visible ? windowsTitle.bottom : demoApp.top
        anchors.left: demoApp.left
        anchors.topMargin: demoApp.border.width
        anchors.leftMargin: demoApp.border.width

        height: demoApp.height - demoApp.border.width * 2
        width: demoApp.width - demoApp.border.width * 2

        appNavBar: StatusAppNavBar {

            id: navBar

            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                tooltip.text: "Chat"
                checked: appView.sourceComponent == statusAppChatView
                onClicked: {
                    appView.sourceComponent = statusAppChatView
                }
            }

            navBarCommunityTabButtons.model: ListModel {
                ListElement {
                    name: "Status Community"
                    tooltipText: "Status Community"
                }
            }

            navBarCommunityTabButtons.delegate: StatusNavBarTabButton {
                id: communityBtn
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.name
                tooltip.text: model.tooltipText
                icon.color: Theme.palette.miscColor6
                icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                checked: appView.sourceComponent == statusAppCommunityView
                onClicked: {
                    appView.sourceComponent = statusAppCommunityView
                }

                popupMenu: StatusPopupMenu {

                    StatusMenuItem {
                        text: qsTr("Invite People")
                        icon.name: "share-ios"
                    }

                    StatusMenuItem {
                        text: qsTr("View Community")
                        icon.name: "group"
                    }

                    StatusMenuItem {
                        text: qsTr("Edit Community")
                        icon.name: "edit"
                        enabled: false
                    }

                    StatusMenuSeparator {}

                    StatusMenuItem {
                        text: qsTr("Leave Community")
                        icon.name: "arrow-right"
                        icon.width: 14
                        iconRotation: 180
                        type: StatusMenuItem.Type.Danger
                    }
                }

            }

            navBarTabButtons: [
                StatusNavBarTabButton {
                    icon.name: "wallet"
                    tooltip.text: "Wallet"
                },
                StatusNavBarTabButton {
                    icon.name: "bigger/browser"
                    tooltip.text: "Browser"
                },
                StatusNavBarTabButton {
                    icon.name: "bigger/status-update"
                    tooltip.text: "Timeline"
                },
                StatusNavBarTabButton {
                    id: profileNavButton
                    icon.name: "bigger/settings"
                    badge.visible: true
                    badge.anchors.rightMargin: 4
                    badge.anchors.topMargin: 5
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusAppNavBar.backgroundColor
                    badge.border.width: 2

                    tooltip.text: "Profile"

                    checked: appView.sourceComponent == statusAppProfileSettingsView
                    onClicked: {
                        appView.sourceComponent = statusAppProfileSettingsView
                    }
                }
            ]
        }

        appView: Loader {
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
            communityDetailModalTitle: demoCommunityDetailModal.header.title
            communityDetailModalImage: demoCommunityDetailModal.header.image.source
            onChatInfoButtonClicked: {
                demoCommunityDetailModal.open();
            }
        }
    }

    Component {
        id: statusAppProfileSettingsView
        StatusAppProfileSettingsView { }
    }

    DemoContactRequestsModal {
        id: demoContactRequestsModal
        anchors.centerIn: parent
    }

    DemoCommunityDetailModal {
        id: demoCommunityDetailModal
    }
}
