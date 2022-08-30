import QtQuick 2.13
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1


StatusListView {
    id: root

    property var headerModel
    property bool isHeaderVisible: true
    property int maxHeight: 381 // default by design

    signal headerItemClicked(string key)
    signal itemClicked(var key, string name, var shortName,  url iconSource, var subItems)

    implicitWidth: 273
    implicitHeight: Math.min(contentHeight, root.maxHeight)
    currentIndex: -1
    clip: true
    header: Rectangle {
        visible: root.isHeaderVisible
        z: 3 // Above delegate (z=1) and above section.delegate (z = 2)
        color: Theme.palette.statusPopupMenu.backgroundColor
        width: root.width
        height: root.isHeaderVisible ? columnHeader.implicitHeight + 2 * columnHeader.anchors.topMargin : 0
        ColumnLayout {
            id: columnHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.rightMargin: anchors.leftMargin
            anchors.topMargin: 8
            anchors.bottomMargin: 2 * anchors.topMargin
            spacing: 20
            Repeater {
                model: root.headerModel
                delegate: StatusIconTextButton {
                    z: 3 // Above delegate (z=1) and above section.delegate (z = 2)
                    spacing: model.spacing
                    statusIcon: model.icon
                    icon.width: model.iconSize
                    icon.height: model.iconSize
                    iconRotation: model.rotation
                    text: model.description
                    onClicked: root.headerItemClicked(model.index)
                }
            }
        }
    }// End of Header
    delegate: Rectangle {
        width: ListView.view.width
        height: 45 // by design
        color: mouseArea.containsMouse ? Theme.palette.baseColor4 : "transparent"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            spacing: 8
            StatusRoundedImage {
                Layout.alignment: Qt.AlignVCenter
                image.source: model.iconSource
                visible: model.iconSource.toString() !== ""
                Layout.preferredWidth: 32
                Layout.preferredHeight: Layout.preferredWidth
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0
                StatusBaseText {
                    Layout.fillWidth: true
                    text: model.name
                    color: Theme.palette.directColor1
                    font.pixelSize: 13
                    clip: true
                    elide: Text.ElideRight
                }
                StatusBaseText {
                    visible: !!model.shortName
                    Layout.fillWidth: true
                    text: !!model.shortName ? model.shortName : ""
                    color: Theme.palette.baseColor1
                    font.pixelSize: 12
                    clip: true
                    elide: Text.ElideRight
                }
            }
            StatusIcon {
                icon: "tiny/chevron-right"
                visible: !!model.subItems && model.subItems.count > 0
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 16
                color: Theme.palette.baseColor1
                width: 16
                height: 16
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: { root.itemClicked(model.key, model.name, model.shortName, model.iconSource, model.subItems) }
        }
    }// End of Item
    section.property: "category"
    section.criteria: ViewSection.FullString
    section.delegate: Item {
        width: ListView.view.width
        height: 34 // by design
        StatusBaseText {
            anchors.leftMargin: 8
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: section
            color: Theme.palette.baseColor1
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }// End of Category item
}// End of Root
