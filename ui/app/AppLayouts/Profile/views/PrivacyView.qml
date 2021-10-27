import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.status 1.0
import "../../Onboarding/shared" as OnboardingComponents

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1 as StatusQControls

import "../popups"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    property var store

    Column {
        id: containerColumn
        anchors.top: parent.top
        anchors.topMargin: 64
        width: profileContainer.profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        StatusSectionHeadline {
            id: labelSecurity
            //% "Security"
            text: qsTrId("security")
            bottomPadding: Style.current.halfPadding
        }

        StatusListItem {
            id: backupSeedPhrase
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            //% "Backup Seed Phrase"
            title: qsTrId("backup-seed-phrase")
            enabled: !root.store.profileModelInst.mnemonic.isBackedUp
            implicitHeight: 52
            components: [
                StatusBadge {
                    visible: !root.store.mnemonicBackedUp
                    anchors.verticalCenter: parent.verticalCenter
                },
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: backupSeedModal.open()
        }

        StatusListItem {
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            title: qsTr("Change password")
            implicitHeight: 52
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: changePasswordModal.open()
        }

        StatusListItem {
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            title: qsTr("Store pass to Keychain")
            implicitHeight: 52
            visible: Qt.platform.os == "osx" // For now, this is available only on MacOS
            label: {
                let value = accountSettings.storeToKeychain
                if(value == Constants.storeToKeychainValueStore)
                    return qsTr("Store")

                if(value == Constants.storeToKeychainValueNever)
                    return qsTr("Never")

                return qsTr("Not now")
            }
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: openPopup(storeToKeychainSelectionModal)

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

        StatusListItem {
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            //% "Display all profile pictures (not only contacts)"
            title: qsTrId("display-all-profile-pictures--not-only-contacts-")
            implicitHeight: 52
            components: [
                StatusQControls.StatusSwitch {
                    id: switch1
                    checked: !appSettings.onlyShowContactsProfilePics
                }
            ]
            sensor.onClicked: {
                switch1.checked = appSettings.onlyShowContactsProfilePics = !switch1.checked
            }
        }

        StatusListItem {
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            //% "Display images in chat automatically"
            title: qsTrId("display-images-in-chat-automatically")
            implicitHeight: 52
            components: [
                StatusQControls.StatusSwitch {
                    id: switch2               
                    checked: appSettings.displayChatImages
                }
            ]
            sensor.onClicked: {
                switch2.checked = appSettings.displayChatImages = !switch2.checked
            }
        }

        StatusBaseText {
            width: parent.width
            //% "All images (links that contain an image extension) will be downloaded and displayed, regardless of the whitelist settings below"
            text: qsTrId("all-images--links-that-contain-an-image-extension--will-be-downloaded-and-displayed--regardless-of-the-whitelist-settings-below")
            font.pixelSize: 15
            font.weight: Font.Thin
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
            bottomPadding: Style.current.smallPadding
        }

        StatusListItem {
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            //% "Chat link previews"
            title: qsTrId("chat-link-previews")
            implicitHeight: 52
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: openPopup(chatLinksPreviewModal)
        }

        Component {
            id: chatLinksPreviewModal
            ChatLinksPreviewModal {}
        }

        Component {
            id: openLinksWithModal
            OpenLinksWithModal {}
        }

        StatusListItem {
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            //% "Open links with..."
            title: qsTrId("open-links-with---")
            implicitHeight: 52
            //% "My default browser"
            label: appSettings.openLinksInStatus ? "Status" : qsTrId("my-default-browser")
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: openPopup(openLinksWithModal)
        }

        StatusListItem {
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            //% "Allow new contact requests"
            title: qsTrId("allow-new-contact-requests")
            implicitHeight: 52
            components: [
                StatusQControls.StatusSwitch {
                    id: switch3
                    checked: !root.store.messagesFromContactsOnly
                }
            ]
            sensor.onClicked: {
                switch3.checked = root.store.setMessagesFromContactsOnly(!switch3.checked)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
