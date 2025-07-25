import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import StatusQ.Core
import StatusQ.Core.Theme

import utils
import "../"
import "../panels"

Popup {
    property string title
    property bool noTopMargin: false
    property bool displayCloseButton: true
    default property alias content: popupContent.children
    property alias contentWrapper: popupContent
    property alias header: headerContent.children
    property bool destroyOnClose: false

    id: popup
    modal: true
    property alias footer: footerContent.children

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.4)
    }
    closePolicy: displayCloseButton? Popup.CloseOnEscape | Popup.CloseOnPressOutside
                                   : Popup.NoAutoClose
    parent: Overlay.overlay
    x: Math.round(((parent ? parent.width : 0) - width) / 2)
    y: Math.round(((parent ? parent.height : 0) - height) / 2)
    width: 480
    height: 510 // TODO find a way to make this dynamic
    background: Rectangle {
        color: Theme.palette.background
        radius: 8
    }
    onClosed: {
        if (popup.destroyOnClose)
            popup.destroy();
    }
    padding: 0
    contentItem: Item {

        Item {
            id: headerContent
            objectName: "headerContent"
            height: {
                const count = children.length
                let h = 0
                for (let i = 0; i < count; i++) {
                    h += children[i] ? children[i].height : 0
                }
                return h
            }
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.topMargin: popup.noTopMargin ? 0 : Theme.padding
            anchors.bottomMargin: Theme.padding
            anchors.rightMargin: Theme.padding
            anchors.leftMargin: Theme.padding

            StyledText {
                text: title
                objectName: "titleText"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 44
                font.bold: true
                font.pixelSize: Theme.secondaryAdditionalTextSize
                height: visible ? 24 : 0
                elide: Text.ElideRight
                visible: !!title
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: closeButton
            objectName: "modalCloseButtonRectangle"
            property bool hovered: false
            visible: displayCloseButton
            height: 32
            width: 32
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            radius: 8
            color: hovered ? Theme.palette.backgroundHover : Theme.palette.transparent

            SVGImage {
                id: closeModalImg
                objectName: "closeImage"
                source: "../img/close.svg"
                width: 11
                height: 11
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
            ColorOverlay {
                anchors.fill: closeModalImg
                source: closeModalImg
                color: Theme.palette.textColor
            }

            StatusMouseArea {
                id: closeModalMouseArea
                objectName: "closeSensor"
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    closeButton.hovered = false
                }
                onEntered: {
                    closeButton.hovered = true
                }
                onClicked: {
                    popup.close()
                }
            }
        }

        Separator {
            id: separator
            anchors.top: headerContent.bottom
            anchors.topMargin: visible ? Theme.padding : 0
            visible: title.length > 0
        }

        Item {
            id: popupContent
            objectName: "contentParent"
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
            visible: footerContent.visible && footerContent.height > 0
            anchors.bottom: footerContent.top
            anchors.bottomMargin: visible ? Theme.padding : 0
        }

        Item {
            id: footerContent
            objectName: "footerParent"
            visible: children.length > 0
            height: visible ? children[0] && children[0].height : 0
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: visible ? Theme.padding : 0
            anchors.rightMargin: visible ? Theme.padding : 0
            anchors.leftMargin: visible ? Theme.padding : 0
        }
    }
}
