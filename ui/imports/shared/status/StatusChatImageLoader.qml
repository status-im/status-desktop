import QtQuick
import QtQuick.Window
import QtQuick.Effects

import StatusQ.Core
import StatusQ.Core.Theme

import shared.panels
import utils

Item {
    id: root

    property int verticalPadding: 0
    property int imageWidth: 350
    property url source
    property bool isActiveChannel: false
    property bool playing: Window.window.active

    property bool isAnimated: !!source && source.toString().endsWith('.gif')
    property alias imageAlias: imageMessage
    property bool allCornersRounded: false
    property bool isOnline: true // TODO: mark as required when migrating to 5.15 or above
    property bool imageLoaded: (imageMessage.status === Image.Ready)
    property alias asynchronous: imageMessage.asynchronous
    property bool leftTail: true

    signal clicked(var image, var mouse)

    width: loadingImageLoader.active ? loadingImageLoader.width : imageMessage.width
    height: loadingImageLoader.active ? loadingImageLoader.height : imageMessage.paintedHeight

    onIsOnlineChanged: {
        if (!isOnline)
            return

        if (imageMessage.status === Image.Error) {
            imageMessage.reloadImage()
        }
    }

    Timer {
        id: retryTimer

        readonly property int initialInterval: 10 * 1000 // 10s

        onTriggered: {
            if (imageMessage.status === Image.Error && root.isOnline) {
                imageMessage.reloadImage()
                interval *= 2
                restart()
            }
        }
    }

    AnimatedImage {
        id: imageMessage
        width: sourceSize.width > imageWidth ? imageWidth : sourceSize.width
        fillMode: Image.PreserveAspectFit
        source: root.source
        playing: root.isAnimated && root.playing
        mipmap: true
        cache: false

        onStatusChanged: {
            if (imageMessage.status === Image.Error && !retryTimer.running) {
                retryTimer.interval = retryTimer.initialInterval
                retryTimer.start()
            }
        }

        function reloadImage() {
            imageMessage.source = ""
            imageMessage.source = Qt.binding(() => root.source)
        }

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
                    visible: root.leftTail && !allCornersRounded
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 32
                    height: 32
                    radius: 4
                    visible: !root.leftTail && !allCornersRounded
                }
            }
        }

        StatusMouseArea {
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            onClicked: {
                root.clicked(imageMessage, mouse)
            }
        }

        Component.onDestruction: imageMessage.source = ""
    }

    Loader {
        id: loadingImageLoader
        active: imageMessage.status === Image.Loading
             || imageMessage.status === Image.Error
        visible: active
        width: active ? 300 : 0
        height: width

        sourceComponent: Rectangle {
            anchors.fill: parent
            border.width: 1
            border.color: Theme.palette.border
            radius: Theme.radius

            StyledText {
                anchors.centerIn: parent
                text: imageMessage.status === Image.Error?
                        qsTr("Error loading the image") :
                        qsTr("Loading image...")
                color: imageMessage.status === Image.Error?
                        Theme.palette.dangerColor1 :
                        Theme.palette.textColor
                font.pixelSize: Theme.primaryTextFontSize
            }
        }
    }
}
