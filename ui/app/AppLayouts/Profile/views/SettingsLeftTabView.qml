import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.popups 1.0

import AppLayouts.Profile.controls 1.0

Item {
    id: root

    property alias model: settingsList.model

    signal menuItemClicked(var event)

    property alias settingsSubsection: settingsList.currenctSubsection

    StatusNavigationPanelHeadline {
        id: title
        text: qsTr("Settings")
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.left: parent.left
        anchors.leftMargin: Theme.bigPadding
    }

    SettingsList {
        id: settingsList

        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: title.bottom
        anchors.bottom: parent.bottom

        anchors.topMargin: Theme.bigPadding
        anchors.bottomMargin: Theme.padding

        leftMargin: Theme.halfPadding
        rightMargin: Theme.padding
        bottomMargin: Theme.bigPadding

        onClicked: {
            if (subsection === Constants.settingsSubsection.backUpSeed) {
                Global.openBackUpSeedPopup()
                return
            }

            const event = { accepted: false, item: subsection };

            root.menuItemClicked(event)

            if (event.accepted)
                return

            if (subsection === Constants.settingsSubsection.signout)
                return confirmDialog.open()

            root.settingsSubsection = subsection
        }
    }

    ConfirmationDialog {
        id: confirmDialog
        confirmButtonObjectName: "signOutConfirmation"
        headerSettings.title: qsTr("Sign out")
        confirmationText: qsTr("Make sure you have your account password and seed phrase stored. Without them you can lock yourself out of your account and lose funds.")
        confirmButtonLabel: qsTr("Sign out & Quit")
        onConfirmButtonClicked: Qt.quit()
    }
}
