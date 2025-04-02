import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.15

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared.popups 1.0

StatusDialog {
    id: root

    property string url: ""

    width: Math.min(d.maxWidth, videoItem.output.sourceRect.width)
    height: Math.min(d.maxHeight, videoItem.output.sourceRect.height)

    padding: 0
    background: null
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    QtObject {
        id: d

        readonly property int maxHeight: root.contentItem.Window.window.height - 80
        readonly property int maxWidth: root.contentItem.Window.window.width - 80
    }

    onOpened: {
        videoItem.source = root.url
    }

    contentItem: StatusVideo {
       id: videoItem

        StatusMouseArea {
           anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.LeftButton)
                    root.close()
                if (mouse.button === Qt.RightButton)
                    Global.openMenu(imageContextMenu, videoItem)
            }
        }

        Loader {
            anchors.centerIn: parent
            width: Math.min(root.width, 300)
            height: Math.min(root.height, 300)
            active: videoItem.isError
            sourceComponent: LoadingErrorComponent { }
        }

        Loader {
            anchors.fill: parent
            active: videoItem.isLoading
            sourceComponent: LoadingComponent { }
        }
    }

    Component {
        id: imageContextMenu

        ImageContextMenu {
            isGif: false
            isVideo: true
            url: root.url
            imageSource: root.url
            onClosed: {
                destroy()
            }
        }
    }
}
