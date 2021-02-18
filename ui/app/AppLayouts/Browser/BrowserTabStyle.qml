import QtQuick 2.13
import QtQuick.Controls.Styles 1.0
import "../../../shared"
import "../../../shared/status"
import "../../../imports"

TabViewStyle {
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
            implicitHeight: tabs.tabHeight
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
                currentTab: tabs.getTab(styleData.index) && tabs.getTab(styleData.index).item
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


            StatusIconButton {
                id: closeTabBtn
                //% "Start Page"
                visible: tabs.count > 1 || styleData.title !== qsTrId("start-page")
                enabled: visible
                icon.name: "browser/close"
                iconColor: Style.current.textColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                onClicked: tabs.removeView(styleData.index)
                width: 16
                height: 16
            }
        }

        Loader {
            id: newTabloader
            active: styleData.index === tabs.count - 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            sourceComponent: Component {
                StatusIconButton {
                    icon.name: "browser/close"
                    iconColor: Style.current.textColor
                    iconRotation: 45
                    onClicked: addNewTab()
                    width: 16
                    height: 16
                }
            }
        }
    }
}
