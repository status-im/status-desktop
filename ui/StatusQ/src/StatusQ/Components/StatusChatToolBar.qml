import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
Item {
    id: statusChatToolBar

    property alias menuButton: menuButton
    property alias notificationButton: notificationButton
    property alias membersButton: membersButton
    property alias searchButton: searchButton

    property int padding: 8
    property int notificationCount: 0
    property Component popupMenu
    property var toolbarComponent

    signal chatInfoButtonClicked()
    signal menuButtonClicked()
    signal notificationButtonClicked()
    signal membersButtonClicked()
    signal searchButtonClicked()

    implicitWidth: 518
    implicitHeight: 60

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    RowLayout {
        width: parent.width
        spacing: padding / 2

        Loader {
            id: loader
            sourceComponent: statusChatToolBar.toolbarComponent
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.topMargin: padding
            Layout.leftMargin: padding
        }

        RowLayout {
            id: actionButtons
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            Layout.topMargin: padding
            Layout.rightMargin: padding
            spacing: 8

            StatusFlatRoundButton {
                id: searchButton
                width: 32
                height: 32
                icon.name: "search"
                type: StatusFlatRoundButton.Type.Secondary
                onClicked: statusChatToolBar.searchButtonClicked()

                // initializing the tooltip
                tooltip.text: qsTr("Search")
                tooltip.orientation: StatusToolTip.Orientation.Bottom
                tooltip.y: parent.height + 12
            }

            StatusFlatRoundButton {
                id: membersButton
                width: 32
                height: 32
                icon.name: "group-chat"
                type: StatusFlatRoundButton.Type.Secondary
                onClicked: statusChatToolBar.membersButtonClicked()

                // initializing the tooltip
                tooltip.text: qsTr("Members")
                tooltip.orientation: StatusToolTip.Orientation.Bottom
                tooltip.y: parent.height + 12
            }

            StatusFlatRoundButton {
                id: menuButton
                objectName: "chatToolbarMoreOptionsButton"
                width: 32
                height: 32
                icon.name: "more"
                type: StatusFlatRoundButton.Type.Secondary
                visible: !!statusChatToolBar.popupMenu

                // initializing the tooltip
                tooltip.visible: !!tooltip.text && menuButton.hovered && !popupMenuSlot.item.opened
                tooltip.text: qsTr("More")
                tooltip.orientation: StatusToolTip.Orientation.Bottom
                tooltip.y: parent.height + 12

                property bool showMoreMenu: false
                onClicked: {
                    menuButton.highlighted = true

                    let originalOpenHandler = popupMenuSlot.item.openHandler
                    let originalCloseHandler = popupMenuSlot.item.closeHandler

                    popupMenuSlot.item.openHandler = function () {
                        if (!!originalOpenHandler) {
                            originalOpenHandler()
                        }
                    }

                    popupMenuSlot.item.closeHandler = function () {
                        menuButton.highlighted = false
                        if (!!originalCloseHandler) {
                            originalCloseHandler()
                        }
                    }

                    popupMenuSlot.item.openHandler = originalOpenHandler
                    popupMenuSlot.item.popup(-popupMenuSlot.item.width + menuButton.width, menuButton.height + 4)
                    statusChatToolBar.menuButtonClicked()
                }

                Loader {
                    id: popupMenuSlot
                    active: !!statusChatToolBar.popupMenu
                }
            }

            Rectangle {
                height: 24
                width: 1
                color: Theme.palette.directColor7
                Layout.alignment: Qt.AlignVCenter
                visible: notificationButton.visible &&
                         (menuButton.visible || membersButton.visible || searchButton.visible)
            }

            StatusActivityCenterButton {
                id: notificationButton
                width: 32
                height: width
                unreadNotificationsCount: statusChatToolBar.notificationCount
                onClicked: statusChatToolBar.notificationButtonClicked()
            }
        }
    }
}

