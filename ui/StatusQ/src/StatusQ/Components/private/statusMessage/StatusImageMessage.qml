import QtQuick 2.3
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: imageContainer

    enum ShapeType {
        ROUNDED = 0,
        LEFT_ROUNDED = 1,
        RIGHT_ROUNDED = 2
    }

    property alias imageAlias: imageMessage

    property bool isAppWindowActive: false
    property url source: ""
    property bool allCornersRounded: false
    property bool isLeftCorner: true
    property int imageWidth: 350
    property int shapeType: -1

    property string loadingImageText: ""
    property string errorLoadingImageText: ""

    signal clicked(var image, var mouse, var imageSource)

    implicitWidth: loadingImage.visible ? loadingImage.width : imageMessage.width
    implicitHeight: loadingImage.visible ? loadingImage.height : imageMessage.paintedHeight

    QtObject {
        id: _internal
        property bool isAnimated: !!source && source.toString().endsWith('.gif')
        property bool pausePlaying: false
    }

    AnimatedImage {
        id: imageMessage

        width: sourceSize.width > imageWidth ? imageWidth : sourceSize.width
        fillMode: Image.PreserveAspectFit
        source: imageContainer.source
        playing: _internal.isAnimated && isAppWindowActive && !_internal.pausePlaying

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: imageMessage.width
                height: imageMessage.height

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: imageMessage.width
                    height: imageMessage.height
                    radius: 16
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    width: 32
                    height: 32
                    radius: 4
                    visible: shapeType === StatusImageMessage.ShapeType.LEFT_ROUNDED //!isLeftCorner && !allCornersRounded
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 32
                    height: 32
                    radius: 4
                    visible: shapeType === StatusImageMessage.ShapeType.RIGHT_ROUNDED  //isLeftCorner && !allCornersRounded
                }
            }
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            onClicked: {
                if (imageContainer.isAnimated) {
                    // FIXME the ListView completely removes Items that scroll out of view
                    // so when we scroll backto the image, it gets reloaded and playing is reset
                    _internal.pausePlaying = ! _internal.pausePlaying
                    return
                }
                imageContainer.clicked(imageMessage, mouse, imageMessage.source)
            }
        }
    }

    Rectangle {
        id: loadingImage
        visible: imageMessage.status === Image.Loading
                 || imageMessage.status === Image.Error
        width: parent.width
        height: width
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: 8

        StatusBaseText {
            anchors.centerIn: parent
            text: imageMessage.status === Image.Error ? errorLoadingImageText: loadingImageText
            color: imageMessage.status === Image.Error?
                       Theme.palette.dangerColor1 :
                       Theme.palette.directColor1
            font.pixelSize: 15
        }
    }
}
