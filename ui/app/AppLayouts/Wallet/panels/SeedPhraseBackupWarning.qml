import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import "../stores"

Rectangle {
    id: root
    visible: !RootStore.mnemonicBackedUp
    height: visible ? 32 : 0
    color: Style.current.red

    Row {
        spacing: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        StyledText {
            text: qsTr("Back up your seed phrase")
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
                onClicked: Global.openBackUpSeedPopup()
            }
        }
    }

    SVGImage {
        id: closeImg
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 18
        source: Style.svg("close-white")
        height: 20
        width: 20
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
}
