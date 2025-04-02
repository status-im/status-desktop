import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.popups 1.0

StatusDialog {
    id: root

    property var store
    property var image
    property string url: ""
    property bool plain: false

    width: Math.min(root.image.sourceSize.width, d.maxWidth)
    height: Math.min(root.image.sourceSize.height, d.maxHeight)

    padding: 0
    background: null
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    QtObject {
        id: d

        property int maxHeight: root.contentItem.Window.window.height - 80
        property int maxWidth: root.contentItem.Window.window.width - 80
        readonly property int radius: Theme.radius
    }

    onOpened: imageLoader.source = root.image.source;
    onClosed: imageLoader.source = ""

    contentItem: Loader {
        id: imageLoader

        readonly property bool isError: status === Loader.Error || (imageLoader.item && imageLoader.item.status === Image.Error)
        readonly property bool isLoading: status === Loader.Loading || (imageLoader.item && imageLoader.item.status === Image.Loading)
        property string source

        anchors.fill: parent
        active: true
        sourceComponent: root.plain ? plainImage : animatedImage

        StatusMouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.LeftButton)
                    root.close()
                if (imageLoader.isError || imageLoader.isLoading || mouse.button !== Qt.RightButton)
                    return
                const isGif = (!root.plain && imageLoader.item && imageLoader.item.playing)
                Global.openMenu(imageContextMenu,
                                imageLoader.item,
                                { imageSource: imageLoader.source, url: root.url, isGif: isGif})
            }
        }

        Loader {
            anchors.centerIn: parent
            width: Math.min(root.width, 300)
            height: Math.min(root.height, 300)
            active: imageLoader.isError
            sourceComponent: LoadingErrorComponent { radius: d.radius }
        }

        Loader {
            anchors.fill: parent
            active: imageLoader.isLoading
            sourceComponent: LoadingComponent {radius: d.radius}
        }
    }

    Component {
        id: animatedImage
        AnimatedImage {
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            mipmap: true
            smooth: false
            onStatusChanged: playing = (status == AnimatedImage.Ready)
            source: imageLoader.source
        }
    }

    Component {
        id: plainImage
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            mipmap: true
            smooth: false
            source: imageLoader.source
        }
    }

    Component {
        id: imageContextMenu

        ImageContextMenu {
            isVideo: false
            onClosed: {
                destroy()
            }
        }
    }
}
