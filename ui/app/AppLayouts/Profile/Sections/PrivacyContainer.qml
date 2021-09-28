import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"
import "../../../../onboarding/" as OnboardingComponents

Item {
    id: privacyContainer
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    Column {
        id: containerColumn
        anchors.top: parent.top
        anchors.topMargin: topMargin
        width: profileContainer.profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        StatusSectionHeadline {
            id: labelSecurity
            //% "Security"
            text: qsTrId("security")
            bottomPadding: Style.current.halfPadding
        }

        StatusSettingsLineButton {
            id: backupSeedPhrase
            //% "Backup Seed Phrase"
            text: qsTrId("backup-seed-phrase")
            isBadge: !profileModel.mnemonic.isBackedUp
            isEnabled: !profileModel.mnemonic.isBackedUp
            onClicked: {
                backupSeedModal.open()
            }
        }

        StatusSettingsLineButton {
            text: qsTr("Change password")
            onClicked: {
                changePasswordModal.open()
            }
        }

        StatusSettingsLineButton {
            text: qsTr("Store pass to Keychain")
            visible: Qt.platform.os == "osx" // For now, this is available only on MacOS
            currentValue: {
                let value = appSettings.storeToKeychain
                if(value == Constants.storeToKeychainValueStore)
                    return qsTr("Store")

                if(value == Constants.storeToKeychainValueNever)
                    return qsTr("Never")

                return qsTr("Not now")
            }
            onClicked: openPopup(storeToKeychainSelectionModal)

            Component {
                id: storePasswordModal
                OnboardingComponents.CreatePasswordModal {
                    storingPasswordModal: true
                    height: 350
                }
            }

            Component {
                id: storeToKeychainSelectionModal
                StoreToKeychainSelectionModal {}
            }
        }

        BackupSeedModal {
            id: backupSeedModal
        }

        ChangePasswordModal {
            id: changePasswordModal
            anchors.centerIn: parent
            successPopup: successPopup
        }

        ChangePasswordSuccessModal {
            id: successPopup
            anchors.centerIn: parent
        }

        Item {
            id: spacer1
            height: Style.current.bigPadding
            width: parent.width
        }

        Separator {
            id: separator
        }

        StatusSectionHeadline {
            id: labelPrivacy
            //% "Privacy"
            text: qsTrId("privacy")
            topPadding: Style.current.padding
            bottomPadding: Style.current.halfPadding
        }

        StatusSettingsLineButton {
            //% "Display all profile pictures (not only contacts)"
            text: qsTrId("display-all-profile-pictures--not-only-contacts-")
            isSwitch: true
            switchChecked: !appSettings.onlyShowContactsProfilePics
            onClicked: appSettings.onlyShowContactsProfilePics = !checked
        }

        StatusSettingsLineButton {
            //% "Display images in chat automatically"
            text: qsTrId("display-images-in-chat-automatically")
            isSwitch: true
            switchChecked: appSettings.displayChatImages
            onClicked: appSettings.displayChatImages = checked
        }
        StyledText {
            width: parent.width
            //% "All images (links that contain an image extension) will be downloaded and displayed, regardless of the whitelist settings below"
            text: qsTrId("all-images--links-that-contain-an-image-extension--will-be-downloaded-and-displayed--regardless-of-the-whitelist-settings-below")
            font.pixelSize: 15
            font.weight: Font.Thin
            color: Style.current.secondaryText
            wrapMode: Text.WordWrap
            bottomPadding: Style.current.smallPadding
        }

        StatusSettingsLineButton {
            //% "Chat link previews"
            text: qsTrId("chat-link-previews")
            onClicked: openPopup(chatLinksPreviewModal)
        }

        Component {
            id: chatLinksPreviewModal
            ChatLinksPreviewModal {}
        }

        Component {
            id: openLinksWithModal
            OpenLinksWithModal {}
        }

        StatusSettingsLineButton {
            //% "Open links with..."
            text: qsTrId("open-links-with---")
            //% "My default browser"
            currentValue: appSettings.openLinksInStatus ? "Status" : qsTrId("my-default-browser")
            onClicked: openPopup(openLinksWithModal)
        }

        StatusSettingsLineButton {
            //% "Allow new contact requests"
            text: qsTrId("allow-new-contact-requests")
            isSwitch: true
            switchChecked: !profileModel.profile.messagesFromContactsOnly
            onClicked: function (checked) {
                profileModel.setMessagesFromContactsOnly(!checked)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
