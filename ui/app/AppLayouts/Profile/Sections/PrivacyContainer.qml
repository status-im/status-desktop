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
        spacing: 30
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

        Separator {
            id: separator
        }

        StatusSectionHeadline {
            id: labelPrivacy
            //% "Privacy"
            text: qsTrId("privacy")
        }

        RowLayout {
            spacing: Style.current.padding
            width: parent.width

            StyledText {
                text: qsTr("Display all profile pictures (not only contacts)")
                font.pixelSize: 15
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

            StatusSwitch {
                id: showOnlyContactsPicsSwitch
                Layout.rightMargin: 0
                checked: !appSettings.onlyShowContactsProfilePics
                onCheckedChanged: function (value) {
                    appSettings.onlyShowContactsProfilePics = !this.checked
                }
            }
        }

        RowLayout {
            spacing: Style.current.padding
            width: parent.width
            Column {
                Layout.fillWidth: true
                StyledText {
                    //% "Display images in chat automatically"
                    text: qsTrId("display-images-in-chat-automatically")
                    font.pixelSize: 15
                    font.weight: Font.Medium
                }
                StyledText {
                    width: parent.width
                    text: qsTr("All images (links that contain an image extension) will be downloaded and displayed, regardless of the whitelist settings below")
                    font.pixelSize: 15
                    font.weight: Font.Thin
                    color: Style.current.secondaryText
                    wrapMode: Text.WordWrap
                }
            }
            StatusSwitch {
                id: displayChatImagesSwitch
                Layout.rightMargin: 0
                checked: appSettings.displayChatImages
                onCheckedChanged: function (value) {
                    appSettings.displayChatImages = this.checked
                }
            }
        }

        StatusSettingsLineButton {
            text: qsTr("Chat link previews")
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
            text: qsTr("Open links with...")
            currentValue: appSettings.openLinksInStatus ? "Status" : qsTr("My default browser")
            onClicked: openPopup(openLinksWithModal)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
