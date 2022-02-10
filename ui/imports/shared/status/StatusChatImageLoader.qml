import QtQuick 2.3
import QtGraphicalEffects 1.13
import shared 1.0
import shared.panels 1.0

import utils 1.0

Item {
    property int verticalPadding: 0
    property int imageWidth: 350
    property bool isCurrentUser: false
    property url source
    property bool playing: Global.applicationWindow.active
    property bool isAnimated: !!source && source.toString().endsWith('.gif')
    signal clicked(var image, var mouse)
    property var container
    property alias imageAlias: imageMessage
    property bool allCornersRounded: false

    id: imageContainer
    width: loadingImageLoader.active ? loadingImageLoader.width : imageMessage.width
    height: loadingImageLoader.active ? loadingImageLoader.height : imageMessage.paintedHeight

    Connections {
        target: Global.applicationWindow
        onActiveChanged: {
            if (Global.applicationWindow.active === false) {
                imageMessage.playing = false
            } else {
                imageMessage.playing = Qt.binding(function () {return imageContainer.playing})
            }
        }
    }

    AnimatedImage {
        id: imageMessage
        width: sourceSize.width > imageWidth ? imageWidth : sourceSize.width
        fillMode: Image.PreserveAspectFit
        source: imageContainer.source
        playing: isAnimated

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
                    visible: !imageContainer.isCurrentUser && !allCornersRounded
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 32
                    height: 32
                    radius: 4
                    visible: imageContainer.isCurrentUser && !allCornersRounded
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
                    imageContainer.playing = !imageContainer.playing
                    return
                }
                imageContainer.clicked(imageMessage, mouse)
            }
        }
    }

    Loader {
        id: loadingImageLoader
        active: imageMessage.status === Image.Loading
                    || imageMessage.status === Image.Error
        width: 300
        height: width
        sourceComponent: Rectangle {
            anchors.fill: parent
            border.width: 1
            border.color: Style.current.border
            radius: Style.current.radius

            StyledText {
                anchors.centerIn: parent
                text: imageMessage.status === Image.Error?
                        //% "Error loading the image"
                        qsTrId("error-loading-the-image") :
                        //% "Loading image..."
                        qsTrId("loading-image---")
                color: imageMessage.status === Image.Error?
                        Style.current.red :
                        Style.current.textColor
                font.pixelSize: 15
            }
        }
    }
}
