import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Controls 2.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

Row {
    id: imageArea
    spacing: 0

    signal imageRemoved(int index)
    signal imageClicked(var chatImage)
    property alias imageSource: rptImages.model

    Repeater {
        id: rptImages

        Item {
            height: Style.current.halfPadding * 2 + chatImage.height + closeBtn.height / 3
            width: chatImage.width + closeBtn.width / 3

            Image {
                id: chatImage
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Style.dp(64)
                height: Style.dp(64)
                fillMode: Image.PreserveAspectCrop
                mipmap: true
                smooth: false
                antialiasing: true
                source: modelData
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: chatImage.width
                        height: chatImage.height

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: chatImage.width
                            height: chatImage.height
                            radius: Style.dp(16)
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            width: Style.dp(32)
                            height: Style.dp(32)
                            radius: Style.dp(4)
                        }
                    }
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
                width: Style.dp(24)
                height: Style.dp(24)
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
                    const tmp = imageArea.imageSource.filter((url, idx) => idx !== index)
                    rptImages.model = tmp
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
