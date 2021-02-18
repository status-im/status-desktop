import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../Profile/Sections"
import "."

Rectangle {
    visible: !profileModel.mnemonic.isBackedUp
    height: visible ? 32 : 0
    Layout.fillWidth: true
    color: Style.current.red
    Row {
        spacing: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        StyledText {
            //% "Back up your seed phrase"
            text: qsTrId("back-up-your-seed-phrase")
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
            color: Style.current.white
        }

        Button {
            width: 58
            height: 24
            contentItem: Item {
                anchors.fill: parent
                Text {
                    text: "Back up"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.family: Style.current.fontRegular.name
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Style.current.white
                }
            }
            background: Rectangle {
                radius: 4
                anchors.fill: parent
                border.color: Style.current.white
                color: "#19FFFFFF"
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: backupSeedModal.open()
            }
        }
    }


    BackupSeedModal {
        id: backupSeedModal
    }

}