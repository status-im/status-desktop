import QtQuick 2.13
import QtQuick.Controls.Styles 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import "../"

import utils 1.0

import StatusQ.Controls 0.1

TabViewStyle {
    id: tabViewStyle

    property color fillColor: Style.current.background
    property color nonSelectedColor: Qt.darker(Style.current.background, 1.2)

    frameOverlap: 1
    tabsMovable: true

    frame: Rectangle {
        color: Style.current.transparent
        border.width: 0
    }

    tab: Item {
        implicitWidth: tabRectangle.implicitWidth + 5 + (newTabloader.active ? newTabloader.width + Style.current.halfPadding : 0)
        implicitHeight: tabRectangle.implicitHeight
        Rectangle {
            id: tabRectangle
            color: styleData.selected ? fillColor : nonSelectedColor
            border.width: 0
            implicitWidth: 240
            implicitHeight: control.tabHeight
            radius: Style.current.radius

            // This rectangle is to hide the bottom radius
            Rectangle {
                width: parent.implicitWidth
                height: 5
                color: parent.color
                border.width: 0
                anchors.bottom: parent.bottom
            }

            FaviconImage {
                id: faviconImage
                currentTab: control.getTab(styleData.index) && control.getTab(styleData.index).item
                anchors.verticalCenter: parent.verticalCenter;
                anchors.left: parent.left
                anchors.leftMargin: Style.current.halfPadding
            }

            StyledText {
                id: text
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: faviconImage.right
                anchors.leftMargin: Style.current.halfPadding
                anchors.right: closeTabBtn.left
                anchors.rightMargin: Style.current.halfPadding
                text: styleData.title
                // TODO the elide probably doesn't work. Set a Max width
                elide: Text.ElideRight
                color: Style.current.textColor
            }


            StatusFlatRoundButton {
                id: closeTabBtn
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                icon.name: "close"
                type: StatusFlatRoundButton.Type.Quaternary
                visible: control.count > 1 || styleData.title !== qsTr("Start Page")
                enabled: visible
                onClicked: control.closeButtonClicked(styleData.index)
            }
        }

        Loader {
            id: newTabloader
            active: styleData.index === control.count - 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            sourceComponent: Component {
                StatusFlatRoundButton {
                    id: addButton
                    width: 16
                    height: 16
                    icon.name: "close"
                    icon.rotation: 45
                    color: "transparent"
                    type: StatusFlatRoundButton.Type.Quaternary
                    onClicked: control.openNewTabClicked()
                }
            }
        }
    }
}
