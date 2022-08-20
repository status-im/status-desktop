import QtQuick 2.14
import QtQuick.Shapes 1.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Item {
    id: root

    property StatusMessageDetails replyDetails
    property string audioMessageInfoText: ""

    signal replyProfileClicked(var sender, var mouse)

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    RowLayout {
        id: layout
        spacing: 8
        Shape {
            id: replyCorner
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 35
            Layout.topMargin: profileImage.height/2
            Layout.preferredWidth: 20
            Layout.preferredHeight: messageLayout.height - replyCorner.Layout.topMargin
            asynchronous: true
            antialiasing: true
            ShapePath {
                strokeColor: Qt.hsla(Theme.palette.baseColor1.hslHue, Theme.palette.baseColor1.hslSaturation, Theme.palette.baseColor1.hslLightness, 0.4)
                strokeWidth: 3
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                startX: 20
                startY: 0
                PathLine { x: 10; y: 0 }
                PathArc {
                    x: 0; y: 10
                    radiusX: 13
                    radiusY: 13
                    direction: PathArc.Counterclockwise
                }
                PathLine { x: 0; y: messageLayout.height}
            }
        }
        ColumnLayout {
            id: messageLayout
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 4
            RowLayout {
                StatusSmartIdenticon {
                    id: profileImage
                    Layout.alignment: Qt.AlignTop
                    name: replyDetails.sender.userName
                    image: replyDetails.sender.profileImage.imageSettings
                    icon: replyDetails.sender.profileImage.iconSettings
                    ringSettings: replyDetails.sender.profileImage.ringSettings

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        onClicked: replyProfileClicked(this, mouse)
                    }
                }
                TextEdit {
                    Layout.alignment: Qt.AlignVCenter
                    color: Theme.palette.baseColor1
                    selectionColor: Theme.palette.primaryColor3
                    selectedTextColor: Theme.palette.directColor1
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    selectByMouse: true
                    readOnly: true
                    text: replyDetails.amISender ? qsTr("You") : replyDetails.sender.displayName
                }
            }
            StatusTextMessage {
                Layout.fillWidth: true
                textField.text: replyDetails.messageText
                textField.font.pixelSize: 13
                textField.color: Theme.palette.baseColor1
                textField.height: 18
                clip: true
                visible: !!replyDetails.messageText
                allowShowMore: false
            }
            StatusImageMessage {
                Layout.fillWidth: true
                Layout.preferredHeight: imageAlias.paintedHeight
                imageWidth: 56
                source: replyDetails.contentType === StatusMessage.ContentType.Image ? replyDetails.messageContent : ""
//                visible: replyDetails.contentType === StatusMessage.ContentType.Image
                shapeType: StatusImageMessage.ShapeType.ROUNDED
            }
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignLeft
                visible: replyDetails.contentType === StatusMessage.ContentType.Sticker
                StatusSticker {
                    image.width: 48
                    image.height: 48
                    image.source: replyDetails.messageContent
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                visible: replyDetails.contentType === StatusMessage.ContentType.Audio
                StatusAudioMessage {
                    id: audioMessage
                    anchors.left: parent.left
                    width: 125
                    height: 22
                    isPreview: true
                    audioSource: replyDetails.messageContent
                    audioMessageInfoText: root.audioMessageInfoText
                }
            }
        }
    }
}

