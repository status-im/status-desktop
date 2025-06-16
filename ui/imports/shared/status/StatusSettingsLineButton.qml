import QtQuick 2.15

import utils 1.0
import ".."
import "../panels"

import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Core 0.1 as StatusQCore
import StatusQ.Core.Theme 0.1

Rectangle {
    property string text
    property bool isSwitch: false
    property bool switchChecked: false
    property string currentValue
    property bool isBadge: false
    property string badgeText: "1"
    property int badgeRadius: 9
    property bool isEnabled: true
    signal clicked(bool checked)
    property bool isHovered: false
    property int badgeSize: 18
    property url iconSource

    id: root
    implicitHeight: 52
    color: isHovered ? Theme.palette.backgroundHover : Theme.palette.transparent
    radius: Theme.radius
    border.width: 0
    anchors.left: parent.left
    anchors.leftMargin: -Theme.padding
    anchors.right: parent.right
    anchors.rightMargin: -Theme.padding

    RoundedIcon {
        id: pinImage
        visible: !!root.iconSource.toString()
        source: root.iconSource
        iconColor: Theme.palette.primaryColor1
        color: Theme.palette.secondaryBackground
        width: 40
        height: 40
        iconWidth: 24
        iconHeight: 24
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
        id: textItem
        anchors.left: pinImage.visible ? pinImage.right : parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.textColor
    }

    StyledText {
        id: valueText
        visible: !!root.currentValue
        text: root.currentValue
        elide: Text.ElideRight
        font.pixelSize: Theme.primaryTextFontSize
        horizontalAlignment: Text.AlignRight
        color: Theme.palette.secondaryText
        anchors.left: textItem.right
        anchors.leftMargin: Theme.padding
        anchors.right: root.isSwitch ? switchItem.left : caret.left
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: textItem.verticalCenter

    }

    StatusQControls.StatusSwitch {
        id: switchItem
        enabled: root.isEnabled
        visible: root.isSwitch
        checked: root.switchChecked
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: textItem.verticalCenter
    }

    Rectangle {
        id: badge
        visible: root.isBadge & !root.isSwitch
        anchors.right: root.isSwitch ? switchItem.left : caret.left
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: textItem.verticalCenter
        radius: root.badgeRadius
        color: Theme.palette.primaryColor1
        width: root.badgeSize
        height: root.badgeSize
        Text {
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.white
            anchors.centerIn: parent
            text: root.badgeText
        }
    }

    StatusQCore.StatusIcon {
        id: caret
        visible: !root.isSwitch
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: textItem.verticalCenter
        icon: "next"
        color: Theme.palette.secondaryText
    }

    StatusQCore.StatusMouseArea {
        anchors.fill: parent
        enabled: root.isEnabled
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            root.clicked(!root.switchChecked)
        }
        cursorShape: Qt.PointingHandCursor
    }
}
