import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0

import "../panels"
import AppLayouts.Profile.stores 1.0

Item {
    id: root

    property ProfileSectionStore store

    signal menuItemClicked(var event)

    StatusNavigationPanelHeadline {
        id: title
        text: qsTr("Settings")
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.left: parent.left
        anchors.leftMargin: Theme.bigPadding
    }

    StatusScrollView {
        id: scrollView
        contentWidth: availableWidth
        contentHeight: profileMenu.height + Theme.bigPadding
        anchors.right: parent.right
        anchors.left: parent.left
        leftPadding: Theme.halfPadding
        anchors.top: title.bottom
        anchors.topMargin: Theme.halfPadding
        anchors.bottom: parent.bottom

        MenuPanel {
            id: profileMenu
            width: scrollView.availableWidth
            privacyStore: store.privacyStore
            contactsStore: store.contactsStore
            devicesStore: store.devicesStore
            mainMenuItems: store.mainMenuItems
            settingsMenuItems: store.settingsMenuItems
            extraMenuItems: store.extraMenuItems
            appsMenuItems: store.appsMenuItems
            walletMenuItemEnabled: store.walletMenuItemEnabled

            objectName: "leftTabViewProfileMenu"

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
        confirmButtonObjectName: "signOutConfirmation"
        headerSettings.title: qsTr("Sign out")
        confirmationText: qsTr("Make sure you have your account password and seed phrase stored. Without them you can lock yourself out of your account and lose funds.")
        confirmButtonLabel: qsTr("Sign out & Quit")
        onConfirmButtonClicked: {
            Qt.quit()
        }
    }
}
