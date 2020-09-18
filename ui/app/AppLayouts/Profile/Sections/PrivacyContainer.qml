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

    Item {
        id: profileImgNameContainer
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.bottom: parent.bottom

        StatusSectionHeadline {
            id: labelSecurity
            //% "Security"
            text: qsTrId("security")
            anchors.top: parent.top
        }

        Item {
            id: backupSeedPhrase
            anchors.top: labelSecurity.bottom
            anchors.topMargin: Style.current.padding
            height: backupText.height
            width: parent.width

            StyledText {
                id: backupText
                //% "Backup Seed Phrase"
                text: qsTrId("backup-seed-phrase")
                font.pixelSize: 15
            }

            SVGImage {
                id: caret
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: backupText.verticalCenter
                source: "../../../img/caret.svg"
                width: 13
                height: 7
                rotation: -90
            }
            ColorOverlay {
                anchors.fill: caret
                source: caret
                color: Style.current.darkGrey
                rotation: -90
            }

            MouseArea {
                anchors.fill: parent
                onClicked: backupSeedModal.open()
                cursorShape: Qt.PointingHandCursor
            }
        }

        BackupSeedModal {
            id: backupSeedModal
        }

        Separator {
            id: separator
            anchors.top: backupSeedPhrase.bottom
            anchors.topMargin: Style.current.bigPadding
        }
        StatusSectionHeadline {
            id: labelPrivacy
            //% "Privacy"
            text: qsTrId("privacy")
            anchors.top: separator.bottom
        }

        RowLayout {
            id: displayImageSettings
            anchors.top: labelPrivacy.bottom
            anchors.topMargin: Style.current.padding
            StyledText {
                //% "Display images in chat automatically"
                text: qsTrId("display-images-in-chat-automatically")
            }
            StatusSwitch {
                checked: appSettings.displayChatImages
                onCheckedChanged: function (value) {
                    appSettings.displayChatImages = this.checked
                }
            }
            StyledText {
                //% "under development"
                text: qsTrId("under-development")
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
