import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls.chat 1.0

import "../popups"
import "../stores"
import "../controls"
import "./profile"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

SettingsContentBase {
    id: root

    property WalletStore walletStore
    property ProfileStore profileStore
    property PrivacyStore privacyStore
    property ContactsStore contactsStore

    titleRowComponentLoader.sourceComponent: StatusButton {
        objectName: "profileSettingsChangePasswordButton"
        text: qsTr("Change Password")
        onClicked: changePasswordModal.open()
        enabled: !userProfile.isKeycardUser
    }

    dirty: settingsView.dirty
    saveChangesButtonEnabled: settingsView.valid

    onResetChangesClicked: {
        settingsView.reset()
        profilePreview.reload()
    }
    onSaveChangesClicked: {
        settingsView.save()
        profilePreview.reload()
    }

    bottomHeaderComponents: StatusTabBar {
        id: editPreviwTabBar
        StatusTabButton {
            width: implicitWidth
            text: qsTr("Edit")
        }
        StatusTabButton {
            width: implicitWidth
            text: qsTr("Preview")
        }
    }

    ColumnLayout {
        id: layout
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        StackLayout {
            Layout.fillWidth: true
            currentIndex: editPreviwTabBar.currentIndex

            MyProfileSettingsView {
                id: settingsView
                Layout.fillWidth: true
                profileStore: root.profileStore
                privacyStore: root.privacyStore
                walletStore: root.walletStore
            }

            MyProfilePreview {
                id: profilePreview
                Layout.fillWidth: true
                profileStore: root.profileStore
                contactsStore: root.contactsStore
                dirtyValues: settingsView.dirtyValues
                dirty: settingsView.dirty
            }
        }

        ChangePasswordModal {
            id: changePasswordModal
            privacyStore: root.privacyStore
            anchors.centerIn: parent
            onPasswordChanged: successPopup.open()
        }

        ChangePasswordSuccessModal {
            id: successPopup
            anchors.centerIn: parent
        }
    }
}
