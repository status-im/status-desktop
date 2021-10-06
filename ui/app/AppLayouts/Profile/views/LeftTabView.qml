import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Components 0.1
import utils 1.0

import "../../../../shared"
import "../panels"

Item {

    property var store

    property var changeProfileSection: function (sectionId) {
        Config.currentMenuTab = sectionId
    }

    StatusNavigationPanelHeadline {
        id: title
        text: qsTr("Settings")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ScrollView {
        ScrollBar.horizontal.policy: Qt.ScrollBarAlwaysOff
        contentHeight: profileMenu.height + 24
        clip: true
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.top: title.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom

        MenuPanel {
            id: profileMenu
            mainMenuItems: store.mainMenuItems
            settingsMenuItems: store.settingsMenuItems
            extraMenuItems: store.extraMenuItems
            selectedMenuItem: store.selectedMenuItem
            browserMenuItemEnabled: store.browserMenuItemEnabled


            onMenuItemClicked: {
                if (!!menu_item.function_name && menu_item.function_name === "exit") {
                    return confirmDialog.open()
                }
                store.selectedMenuItem = menu_item.menu_id
            }
        }
    }

    ConfirmationDialog {
        id: confirmDialog
        header.title: qsTr("Sign out")
        confirmationText: qsTr("Make sure you have your account password and seed phrase stored. Without them you can lock yourself out of your account and lose funds.")
        confirmButtonLabel: qsTr("Sign out & Quit")
        onConfirmButtonClicked: {
            Qt.quit()
        }
    }
}
