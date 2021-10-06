import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../../../../shared"
import "../../Profile/popups"
import "."

Rectangle {
    id: root
    height: visible ? 32 : 0
    color: Style.current.red

    Row {
        spacing: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            color: Style.current.white
            font.pixelSize: 13
            text: qsTrId("back-up-your-seed-phrase")
        }

        Control {
            width: 58
            height: 24
            background: Rectangle {
                radius: 4
                anchors.fill: parent
                border.color: Style.current.white
                color: "#19FFFFFF"
            }
            contentItem: Item {
                anchors.fill: parent
                Text {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.family: Style.current.fontRegular.name
                    color: Style.current.white
                    text: "Back up"
                }
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: { backupSeedModal.open(); }
            }
        }
    }

    SVGImage {
        id: closeImg
        height: 20
        width: 20
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 18
        source: Style.svg("close-white")
    }
    ColorOverlay {
        anchors.fill: closeImg
        source: closeImg
        color: Style.current.white
        opacity: 0.7
    }
    MouseArea {
        anchors.fill: closeImg
        cursorShape: Qt.PointingHandCursor
        onClicked: ParallelAnimation {
            PropertyAnimation { target: root; property: "visible"; to: false; }
            PropertyAnimation { target: root; property: "y"; to: -1 * root.height }
        }
    }


    BackupSeedModal {
        id: backupSeedModal
    }
}
