import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "Privileges/"

Item {
    id: privacyContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    property Component dappListPopup: DappList {
        onClosed: destroy()
    }

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
                color: !badge.visible ? Style.current.darkGrey : Style.current.textColor
            }

            Rectangle {
                id: badge
                visible: !profileModel.isMnemonicBackedUp
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 0
                radius: width/2
                color: Style.current.blue
                width: 18
                height: 18
                Text {
                    font.pixelSize: 12
                    color: Style.current.white
                    anchors.centerIn: parent
                    text: "1"
                }
            }

            MouseArea {
                enabled: !profileModel.isMnemonicBackedUp
                anchors.fill: parent
                onClicked: backupSeedModal.open()
                cursorShape: Qt.PointingHandCursor
            }
        }

        BackupSeedModal {
            id: backupSeedModal
        }


        Item {
            id: dappPermissions
            anchors.top: backupSeedPhrase.bottom
            anchors.topMargin: Style.current.padding
            height: dappPermissionsText.height
            width: parent.width

            StyledText {
                id: dappPermissionsText
                text: qsTr("Set DApp access permissions")
                font.pixelSize: 15
            }

            SVGImage {
                id: caret2
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: dappPermissionsText.verticalCenter
                source: "../../../img/caret.svg"
                width: 13
                height: 7
                rotation: -90
            }
            
            ColorOverlay {
                anchors.fill: caret2
                source: caret2
                color: Style.current.darkGrey
                rotation: -90
            }

            MouseArea {
                anchors.fill: parent
                onClicked: dappListPopup.createObject(privacyContainer).open()
                cursorShape: Qt.PointingHandCursor
            }
        }

        Separator {
            id: separator
            anchors.top: dappPermissions.bottom
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
