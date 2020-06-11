import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../imports"
import "./"

Popup {
    property string title
    default property alias content: popupContent.children
    property alias header: headerContent.children

    id: popup
    modal: true
    property alias footer: footerContent.children

    Overlay.modal: Rectangle {
        color: "#60000000"
    }
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: 480
    height: 510 // TODO find a way to make this dynamic
    background: Rectangle {
        color: Theme.white
        radius: 8
    }
    padding: 0
    contentItem: Item {

        Item {
            id: headerContent
            width: parent.width
            height: {
                var idx = !!title ? 0 : 1
                return children[idx] && children[idx].height + Theme.padding
            }
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: Theme.padding
            anchors.rightMargin: Theme.padding
            anchors.leftMargin: Theme.padding

            Text {
                text: title
                anchors.top: parent.top
                anchors.left: parent.left
                font.bold: true
                font.pixelSize: 17
                anchors.leftMargin: 16
                anchors.topMargin: Theme.padding
                anchors.bottomMargin: Theme.padding
                visible: !!title
            }
        }

        Rectangle {
            id: closeButton
            height: 32
            width: 32
            anchors.top: parent.top
            anchors.topMargin: Theme.padding
            anchors.rightMargin: Theme.padding
            anchors.right: parent.right
            radius: 8

            Image {
                id: closeModalImg
                source: "./img/close.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: closeModalMouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    closeButton.color = Theme.white
                }
                onEntered: {
                    closeButton.color = Theme.grey
                }
                onClicked: {
                    popup.close()
                }
            }
        }

        Separator {
            id: separator
            anchors.top: headerContent.bottom
        }

        Item {
            id: popupContent
            anchors.top: separator.bottom
            anchors.topMargin: Theme.padding
            anchors.bottom: separator2.top
            anchors.bottomMargin: Theme.padding
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
        }

        Separator {
            id: separator2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 75
        }

        Item {
            id: footerContent
            height: children[0] && children[0].height
            width: parent.width
            anchors.top: separator2.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.padding
            anchors.rightMargin: Theme.padding
            anchors.leftMargin: Theme.padding
        }
    }
}
