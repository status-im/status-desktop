import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Components 0.1
import utils 1.0

import shared 1.0
import shared.popups 1.0
import "../panels"

Item {

    property var store

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
            privacyStore: store.privacyStore
            mainMenuItems: store.mainMenuItems
            settingsMenuItems: store.settingsMenuItems
            extraMenuItems: store.extraMenuItems
            appsMenuItems: store.appsMenuItems
            browserMenuItemEnabled: store.browserMenuItemEnabled
            appsMenuItemsEnabled: store.appsMenuItemsEnabled
            
            onMenuItemClicked: {
                if (menu_item.subsection === Constants.settingsSubsection.signout) {
                    return confirmDialog.open()
                }
                Global.settingsSubsection = menu_item.subsection
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
