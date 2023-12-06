import QtQuick 2.13
import QtQuick.Window 2.2
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared 1.0
import shared.views.chat 1.0

StatusDialog {
    id: root

    property var store
    property var image
    property string url: ""

    width: (root.image.sourceSize.width > d.maxWidth) ?
            d.maxWidth : root.image.sourceSize.width
    height: (root.image.sourceSize.height > d.maxHeight) ?
            d.maxHeight : root.image.sourceSize.height

    padding: 0
    background: null
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    QtObject {
        id: d

        property int maxHeight: Global.applicationWindow.height - 80
        property int maxWidth: Global.applicationWindow.width - 80
    }

    onOpened: {
        messageImage.source = root.image.source;
    }

    contentItem: AnimatedImage {
        id: messageImage
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: false

        onStatusChanged: playing = (status == AnimatedImage.Ready)
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.LeftButton)
                    root.close()
                if (mouse.button === Qt.RightButton)
                    Global.openMenu(imageContextMenu,
                                    messageImage,
                                    { imageSource: messageImage.source, url: root.url})
            }
        }
    }

    Component {
        id: imageContextMenu

        ImageContextMenu {
            onClosed: {
                destroy()
            }
        }
    }
}
