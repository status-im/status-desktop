import QtQuick 2.13
import QtGraphicalEffects 1.12
import "../../imports"
import ".."

Rectangle {
    property string text
    property bool isSwitch: false
    property bool switchChecked: false
    property string currentValue
    property bool isBadge: false
    property string badgeText: "1"
    property int badgeRadius: 9 * scaleAction.factor
    property bool isEnabled: true
    signal clicked(bool checked)
    property bool isHovered: false
    property int badgeSize: 18 * scaleAction.factor

    id: root
    height: 52 * scaleAction.factor
    color: isHovered ? Style.current.backgroundHover : Style.current.transparent
    radius: Style.current.radius
    border.width: 0
    anchors.left: parent.left
    anchors.leftMargin: -Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: -Style.current.padding

    StyledText {
        id: textItem
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        font.pixelSize: 15 * scaleAction.factor
        color: !root.isEnabled ? Style.current.secondaryText : Style.current.textColor
    }

    StyledText {
        id: valueText
        visible: !!root.currentValue
        text: root.currentValue
        elide: Text.ElideRight
        font.pixelSize: 15 * scaleAction.factor
        horizontalAlignment: Text.AlignRight
        color: Style.current.secondaryText
        anchors.left: textItem.right
        anchors.leftMargin: Style.current.padding
        anchors.right: root.isSwitch ? switchItem.left : caret.left
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: textItem.verticalCenter

    }

    StatusSwitch {
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
            font.pixelSize: 12 * scaleAction.factor
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
        source: "../../app/img/caret.svg"
        width: 13 * scaleAction.factor
        height: 7 * scaleAction.factor
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
