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
    property bool profileClickable: true

    signal replyProfileClicked(var sender, var mouse)
    signal linkActivated(string link)

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
                    name: replyDetails.sender.displayName
                    asset: replyDetails.sender.profileImage.assetSettings
                    ringSettings: replyDetails.sender.profileImage.ringSettings
                    MouseArea {
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        enabled: root.profileClickable
                        onClicked: replyProfileClicked(this, mouse)
                    }
                }
                TextEdit {
                    Layout.alignment: Qt.AlignVCenter
                    color: Theme.palette.baseColor1
                    selectionColor: Theme.palette.primaryColor3
                    selectedTextColor: Theme.palette.directColor1
                    font.pixelSize: Theme.secondaryTextFontSize
                    font.weight: Font.Medium
                    selectByMouse: true
                    readOnly: true
                    text: replyDetails.amISender ? qsTr("You") : replyDetails.sender.displayName
                }
            }
            StatusTextMessage {
                Layout.fillWidth: true
                textField.font.pixelSize: Theme.secondaryTextFontSize
                textField.color: Theme.palette.baseColor1
                convertToSingleLine: true
                clip: true
                visible: !!replyDetails.messageText && replyDetails.contentType !== StatusMessage.ContentType.Sticker
                allowShowMore: false
                messageDetails: root.replyDetails
                onLinkActivated: {
                    root.linkActivated(link);
                }
            }
            StatusImageMessage {
                Layout.fillWidth: true
                Layout.preferredHeight: imageAlias.paintedHeight
                imageWidth: 56
                source: replyDetails.contentType === StatusMessage.ContentType.Image ? replyDetails.messageContent : ""
                visible: source
                shapeType: StatusImageMessage.ShapeType.ROUNDED
            }
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignLeft
                visible: replyDetails.contentType === StatusMessage.ContentType.Sticker
                StatusSticker {
                    asset.width: 48
                    asset.height: 48
                    asset.name: replyDetails.messageContent
                    asset.isImage: true
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

