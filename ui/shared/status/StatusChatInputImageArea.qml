import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

Row {
    id: imageArea
    spacing: Style.current.halfPadding

    signal imageRemoved(int index)
    property alias imageSource: rptImages.model

    Repeater {
        id: rptImages
        Item {
            height: chatImage.paintedHeight + closeBtn.height - 5
            width: chatImage.width
            Image {
                id: chatImage
                property bool hovered: false
                width: 64
                height: 64
                fillMode: Image.PreserveAspectCrop
                mipmap: true
                smooth: false
                antialiasing: true
                source: modelData
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        chatImage.hovered = true
                    }
                    onExited: {
                        chatImage.hovered = false
                    }
                }

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
                            radius: 16
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            width: 32
                            height: 32
                            radius: 4
                        }
                    }
                }
            }
            RoundButton {
                id: closeBtn
                implicitWidth: 24
                implicitHeight: 24
                padding: 0
                anchors.top: chatImage.top
                anchors.topMargin: -5
                anchors.right: chatImage.right
                anchors.rightMargin: -Style.current.halfPadding
                visible: chatImage.hovered || hovered
                contentItem: SVGImage {
                    source: !closeBtn.hovered ?
                    "../../app/img/close-filled.svg" : "../../app/img/close-filled-hovered.svg"
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
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onPressed: mouse.accepted = false
                }
            }
        }
    }
}
