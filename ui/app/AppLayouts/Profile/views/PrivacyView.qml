import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.status 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1 as StatusQControls

import "../popups"
import "../stores"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    property PrivacyStore privacyStore

    property int profileContentWidth

    Column {
        id: containerColumn
        anchors.top: parent.top
        anchors.topMargin: 64
        width: profileContentWidth

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
            enabled: !root.privacyStore.mnemonicBackedUp
            implicitHeight: 52
            components: [
                StatusBadge {
                    value: !root.privacyStore.mnemonicBackedUp
                    visible: !root.privacyStore.mnemonicBackedUp
                    anchors.verticalCenter: parent.verticalCenter
                },
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: Global.openBackUpSeedPopup()
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
                let value = localAccountSettings.storeToKeychainValue
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
            sensor.onClicked: Global.openPopup(storeToKeychainSelectionModal)

            Component {
                id: storeToKeychainSelectionModal
                StoreToKeychainSelectionModal {}
            }
        }

        ChangePasswordModal {
            id: changePasswordModal
            privacyStore: root.privacyStore
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
                    checked: !localAccountSensitiveSettings.onlyShowContactsProfilePics
                    onCheckedChanged: {
                        if (localAccountSensitiveSettings.onlyShowContactsProfilePics === checked) {
                            localAccountSensitiveSettings.onlyShowContactsProfilePics = !checked
                        }
                    }
                }
            ]
            sensor.onClicked: {
                switch1.checked = !switch1.checked
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
                    checked: localAccountSensitiveSettings.displayChatImages
                    onCheckedChanged: {
                        if (localAccountSensitiveSettings.displayChatImages !== checked) {
                            localAccountSensitiveSettings.displayChatImages = checked
                        }
                    }
                }
            ]
            sensor.onClicked: {
                switch2.checked = !switch2.checked
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
            sensor.onClicked: Global.openPopup(chatLinksPreviewModal)
        }

        Component {
            id: chatLinksPreviewModal
            ChatLinksPreviewModal {
                privacyStore: root.privacyStore
            }
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
            label: localAccountSensitiveSettings.openLinksInStatus ? "Status" : qsTrId("my-default-browser")
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: Global.openPopup(openLinksWithModal)
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
                    checked: !root.privacyStore.privacyModule.messagesFromContactsOnly
                    onCheckedChanged: {
                        // messagesFromContactsOnly needs to be accessed from the module (view),
                        // because otherwise doing `messagesFromContactsOnly = value` only changes the bool property on QML
                        if (root.privacyStore.privacyModule.messagesFromContactsOnly === checked) {
                            root.privacyStore.privacyModule.messagesFromContactsOnly = !checked
                        }
                    }
                }
            ]
            sensor.onClicked: {
                switch3.checked = !switch3.checked
            }
        }
    }
}
