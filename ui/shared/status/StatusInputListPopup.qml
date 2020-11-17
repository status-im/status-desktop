import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.12
import QtQuick.Dialogs 1.3
import "../../imports"
import "../../shared"

Popup {
    property var modelList
    property alias listView: listView
    property var getImageSource: function () {}
    property var getText: function () {}
    property var onClicked: function () {}
    property int imageWidth: 22
    property int imageHeight: 22

    function openPopup(listParam) {
        modelList = listParam
        popup.open()
    }

    id: popup
    width: messageInput.width
    height: Math.min(400, listView.contentHeight + Style.current.smallPadding)
    x : messageInput.x
    y: -height
    background: Rectangle {
        id: bgRectangle
        visible: !!popup.modelList && popup.modelList.length > 0
        color: Style.current.background
        border.width: 0
        radius: Style.current.radius
        layer.enabled: true
        layer.effect: DropShadow{
            width: bgRectangle.width
            height: bgRectangle.height
            x: bgRectangle.x
            y: bgRectangle.y + 10
            visible: bgRectangle.visible
            source: bgRectangle
            horizontalOffset: 0
            verticalOffset: 2
            radius: 10
            samples: 15
            color: "#22000000"
        }
    }

    ListView {
        id: listView
        model: popup.modelList || []
        keyNavigationEnabled: true
        anchors.fill: parent
        clip: true

        delegate: Rectangle {
            id: rectangle
            color: listView.currentIndex === index ? Style.current.backgroundHover : Style.current.transparent
            border.width: 0
            width: parent.width
            height: 42
            radius: Style.current.radius

            SVGImage {
                id: image
                source: popup.getImageSource(modelData)
                width: popup.imageWidth
                height: popup.imageHeight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
            }

            StyledText {
                text: popup.getText(modelData)
                color: Style.current.textColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: image.right
                anchors.leftMargin: Style.current.smallPadding
                font.pixelSize: 15
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    listView.currentIndex = index
                }
                onClicked: {
                    popup.onClicked(index)
                }
            }
        }
    }
}
