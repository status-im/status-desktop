import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Controls 2.13

import utils 1.0
import shared 1.0
import shared.controls.chat 1.0
import shared.panels 1.0

Row {
    id: imageArea
    spacing: Style.current.halfPadding

    signal imageRemoved(int index)
    signal imageClicked(var chatImage)

    property bool leftTail: true

    property alias imageSource: rptImages.model

    Repeater {
        id: rptImages

        Item {
            height: chatImage.height
            width: chatImage.width

            Image {
                id: chatImage
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: 64
                height: 64
                fillMode: Image.PreserveAspectCrop
                mipmap: true
                smooth: false
                antialiasing: true
                cache: false
                source: modelData
                layer.enabled: true
                layer.effect: CalloutOpacityMask {
                    width: parent.width
                    height: parent.height
                    leftTail: imageArea.leftTail
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: imageClicked(chatImage)
            }

            RoundButton {
                id: closeBtn
                width: 24
                height: 24
                padding: 0
                anchors.right: chatImage.right
                anchors.rightMargin: -width / 3
                anchors.top: chatImage.top
                anchors.topMargin: -height / 3
                hoverEnabled: false
                opacity: mouseArea.containsMouse || buttonMouseArea.containsMouse ? 1 : 0
                contentItem: SVGImage {
                    source: Style.svg( !buttonMouseArea.containsMouse ? "close-filled" : "close-filled-hovered")
                    width: closeBtn.width
                    height: closeBtn.height
                }
                background: Rectangle {
                    color: "transparent"
                }
                onClicked: {
                    imageArea.imageRemoved(index)
                }
                MouseArea {
                    id: buttonMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: closeBtn.clicked()
                }
            }
        }
    }
}
