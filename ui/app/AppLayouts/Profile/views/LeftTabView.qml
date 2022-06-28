import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Components 0.1
import utils 1.0

import shared 1.0
import shared.popups 1.0
import "../panels"

Item {
    id: root

    property var store

    signal menuItemClicked(var event)

    StatusNavigationPanelHeadline {
        id: title
        text: qsTr("Settings")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ScrollView {
        contentWidth: availableWidth
        contentHeight: profileMenu.height + 24
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.top: title.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        MenuPanel {
            id: profileMenu
            privacyStore: store.privacyStore
            contactsStore: store.contactsStore
            mainMenuItems: store.mainMenuItems
            settingsMenuItems: store.settingsMenuItems
            extraMenuItems: store.extraMenuItems
            appsMenuItems: store.appsMenuItems
            browserMenuItemEnabled: store.browserMenuItemEnabled
            walletMenuItemEnabled: store.walletMenuItemEnabled

            onMenuItemClicked: {
                if (menu_item.subsection === Constants.settingsSubsection.backUpSeed) {
                    Global.openBackUpSeedPopup();
                    return;
                }

                let event = { accepted: false, item: menu_item.subsection };
                
                root.menuItemClicked(event);
                
                if (event.accepted)
                    return;

                if (menu_item.subsection === Constants.settingsSubsection.signout)
                    return confirmDialog.open()

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
