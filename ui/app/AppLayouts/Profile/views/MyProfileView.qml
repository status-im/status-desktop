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
    property var communitiesModel

    titleRowComponentLoader.sourceComponent: StatusButton {
        objectName: "profileSettingsChangePasswordButton"
        text: qsTr("Change Password")
        onClicked: Global.openPopup(changePasswordModal)
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
            leftPadding: 0
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
            id: stackLayout
            currentIndex: editPreviwTabBar.currentIndex

            MyProfileSettingsView {
                id: settingsView
                objectName: "myProfileSettingsView"
                profileStore: root.profileStore
                privacyStore: root.privacyStore
                walletStore: root.walletStore
                communitiesModel: root.communitiesModel

                onVisibleChanged: if (visible) stackLayout.Layout.preferredHeight = settingsView.implicitHeight
                Component.onCompleted: stackLayout.Layout.preferredHeight = Qt.binding(() => settingsView.implicitHeight)
            }

            MyProfilePreview {
                id: profilePreview

                profileStore: root.profileStore
                contactsStore: root.contactsStore
                communitiesModel: root.communitiesModel
                dirtyValues: settingsView.dirtyValues
                dirty: settingsView.dirty

                onVisibleChanged: if (visible) stackLayout.Layout.preferredHeight = Qt.binding(() => profilePreview.implicitHeight)
            }
        }

        Component {
            id: changePasswordModal
            ChangePasswordModal {
                privacyStore: root.privacyStore
                onPasswordChanged: Global.openPopup(successPopup);
            }
        }

        Component {
            id: successPopup
            ChangePasswordSuccessModal { }
        }
    }
}
