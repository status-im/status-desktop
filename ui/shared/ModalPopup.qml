import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Popup {
    property string title
    default property alias content: popupContent.children
    property alias contentWrapper: popupContent
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
        color: Style.current.background
        radius: 8
    }
    padding: 0
    contentItem: Item {

        Item {
            id: headerContent
            width: parent.width
            height: {
                var idx = !!title ? 0 : 1
                return children[idx] && children[idx].height + Style.current.padding
            }
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: Style.current.padding
            anchors.rightMargin: Style.current.padding
            anchors.leftMargin: Style.current.padding

            StyledText {
                text: title
                anchors.top: parent.top
                anchors.left: parent.left
                font.bold: true
                font.pixelSize: 17
                anchors.topMargin: Style.current.padding
                anchors.bottomMargin: Style.current.padding
                visible: !!title
            }
        }

        Rectangle {
            id: closeButton
            height: 32
            width: 32
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.rightMargin: Style.current.padding
            anchors.right: parent.right
            radius: 8
            color: Style.current.transparent

            SVGImage {
                id: closeModalImg
                source: "./img/close.svg"
                width: 25
                height: 25
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
            ColorOverlay {
                anchors.fill: closeModalImg
                source: closeModalImg
                color: Style.current.textColor
            }

            MouseArea {
                id: closeModalMouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    closeButton.color = Style.current.transparent
                }
                onEntered: {
                    closeButton.color = Style.current.border
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
            anchors.topMargin: Style.current.padding
            anchors.bottom: separator2.top
            anchors.bottomMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
        }

        Separator {
            id: separator2
            visible: !!footerContent.children[0]
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 75
        }

        Item {
            id: footerContent
            visible: !!children[0]
            height: children[0] && children[0].height
            width: parent.width
            anchors.top: separator2.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: Style.current.padding
            anchors.bottomMargin: Style.current.padding
            anchors.rightMargin: Style.current.padding
            anchors.leftMargin: Style.current.padding
        }
  }
}
