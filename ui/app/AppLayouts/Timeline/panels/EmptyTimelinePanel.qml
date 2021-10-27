import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0

Rectangle {
    id: root
    height: visible ? childrenRect.height : 0
    width: 375
    color: "transparent"

    SVGImage {
        id: sticker
        anchors.top: parent.top
        width: 140
        height: 140
        source: Style.png("think-sticker")
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        anchors.top: sticker.bottom
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.right: parent.right
        anchors.rightMargin: 60
        border.color: Style.current.border
        border.width: 1
        radius: Style.current.padding
        width: 255
        height: shareYourMindText.height + Style.current.padding

        StatusBaseText {
            id: shareYourMindText
            horizontalAlignment: Text.AlignHCenter
            anchors.left: parent.left
            anchors.leftMargin: Style.current.halfPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.halfPadding
            anchors.verticalCenter: parent.verticalCenter
            //% "Share what's on your mind and stay updated with your contacts"
            text: qsTrId("share-what-s-on-your-mind-and-stay-updated-with-your-contacts")
            font.pixelSize: 15
            color: Theme.palette.directColor7
            wrapMode: Text.WordWrap
        }
    }
}

