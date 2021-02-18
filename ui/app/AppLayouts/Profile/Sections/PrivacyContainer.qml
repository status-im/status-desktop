import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: privacyContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    Column {
        id: containerColumn
        anchors.top: parent.top
        anchors.topMargin: topMargin
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.bottom: parent.bottom

        StatusSectionHeadline {
            id: labelSecurity
            //% "Security"
            text: qsTrId("security")
            bottomPadding: 4
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

        BackupSeedModal {
            id: backupSeedModal
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
            bottomPadding: 4
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
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
