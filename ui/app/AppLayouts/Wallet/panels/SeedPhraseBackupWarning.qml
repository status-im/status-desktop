import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import StatusQ.Core
import StatusQ.Core.Theme

import utils
import shared
import shared.panels
import "../stores"

Rectangle {
    id: root
    height: visible ? 32 : 0
    visible: !RootStore.mnemonicBackedUp
    color: Theme.palette.dangerColor1

    Row {
        spacing: Theme.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        StyledText {
            text: qsTr("Back up your recovery phrase")
            font.pixelSize: Theme.additionalTextSize
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.palette.white
        }

        Button {
            width: 58
            height: 24
            contentItem: Item {
                anchors.fill: parent
                Text {
                    text: qsTr("Back up")
                    font.pixelSize: Theme.additionalTextSize
                    font.weight: Font.Medium
                    font.family: Theme.baseFont.name
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.palette.white
                }
            }
            background: Rectangle {
                radius: 4
                anchors.fill: parent
                border.color: Theme.palette.white
                color: "#19FFFFFF"
            }
            StatusMouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: Global.openBackUpSeedPopup()
            }
        }
    }

    SVGImage {
        id: closeImg
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 18
        source: Theme.svg("close-white")
        height: 20
        width: 20
    }
    ColorOverlay {
        anchors.fill: closeImg
        source: closeImg
        color: Theme.palette.white
        opacity: 0.7
    }
    StatusMouseArea {
        anchors.fill: closeImg
        cursorShape: Qt.PointingHandCursor
        onClicked: ParallelAnimation {
            PropertyAnimation { target: root; property: "visible"; to: false; }
            PropertyAnimation { target: root; property: "y"; to: -1 * root.height }
        }
    }
}
