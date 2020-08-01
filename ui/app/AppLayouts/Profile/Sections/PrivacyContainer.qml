import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: privacyContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    Item {
        id: profileImgNameContainer
        anchors.top: parent.top
        anchors.topMargin: 46
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.bottom: parent.bottom

        StyledText {
            id: labelSecurity
            //% "Security"
            text: qsTrId("security")
            font.pixelSize: 15
            color: Style.current.grey
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
                color: Style.current.grey
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
        StyledText {
            id: labelPrivacy
            text: qsTr("Privacy")
            font.pixelSize: 15
            color: Style.current.grey
            anchors.top: separator.bottom
            anchors.topMargin: Style.current.smallPadding
        }

        RowLayout {
            id: displayImageSettings
            anchors.top: labelPrivacy.bottom
            anchors.topMargin: Style.current.padding
            StyledText {
                //% "Display images in chat automatically"
                text: qsTrId("display-images-in-chat-automatically")
            }
            Switch {
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
