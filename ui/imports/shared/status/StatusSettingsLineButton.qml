import QtQuick 2.13
import QtGraphicalEffects 1.12

import utils 1.0
import ".."
import "../panels"

import StatusQ.Controls 0.1 as StatusQControls

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
    property int badgeSize: Style.dp(18)
    property url iconSource

    id: root
    implicitHeight: Style.dp(52)
    color: isHovered ? Style.current.backgroundHover : Style.current.transparent
    radius: Style.current.radius
    border.width: 0
    anchors.left: parent.left
    anchors.leftMargin: -Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: -Style.current.padding

    RoundedIcon {
        id: pinImage
        visible: !!root.iconSource.toString()
        source: root.iconSource
        iconColor: Style.current.primary
        color: Style.current.secondaryBackground
        width: Style.dp(40)
        height: Style.dp(40)
        iconWidth: Style.dp(24)
        iconHeight: Style.dp(24)
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
        id: textItem
        anchors.left: pinImage.visible ? pinImage.right : parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        font.pixelSize: Style.current.primaryTextFontSize
        color: !root.isEnabled ? Style.current.secondaryText : Style.current.textColor
    }

    StyledText {
        id: valueText
        visible: !!root.currentValue
        text: root.currentValue
        elide: Text.ElideRight
        font.pixelSize: Style.current.primaryTextFontSize
        horizontalAlignment: Text.AlignRight
        color: Style.current.secondaryText
        anchors.left: textItem.right
        anchors.leftMargin: Style.current.padding
        anchors.right: root.isSwitch ? switchItem.left : caret.left
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: textItem.verticalCenter

    }

    StatusQControls.StatusSwitch {
        id: switchItem
        enabled: root.isEnabled
        visible: root.isSwitch
        checked: root.switchChecked
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: textItem.verticalCenter
    }

    Rectangle {
        id: badge
        visible: root.isBadge & !root.isSwitch
        anchors.right: root.isSwitch ? switchItem.left : caret.left
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: textItem.verticalCenter
        radius: root.badgeRadius
        color: Style.current.blue
        width: root.badgeSize
        height: root.badgeSize
        Text {
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: Style.current.white
            anchors.centerIn: parent
            text: root.badgeText
        }
    }

    SVGImage {
        id: caret
        visible: !root.isSwitch
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: textItem.verticalCenter
        source: Style.svg("caret")
        width: Style.dp(13)
        height: Style.dp(7)
        rotation: -90
        ColorOverlay {
            anchors.fill: caret
            source: caret
            color: Style.current.secondaryText
        }
    }

    MouseArea {
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
