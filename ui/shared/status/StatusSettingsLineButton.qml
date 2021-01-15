import QtQuick 2.13
import QtGraphicalEffects 1.12
import "../../imports"
import ".."

Item {
    property string text
    property bool isSwitch: false
    property bool switchChecked: false
    property string currentValue
    property bool isBadge: false
    property string badgeText: "1"
    property bool isEnabled: true
    signal clicked(bool checked)

    id: root
    height: textItem.height
    width: parent.width

    StyledText {
        id: textItem
        text: root.text
        font.pixelSize: 15
        color: !root.isEnabled ? Style.current.darkGrey : Style.current.textColor
    }

    StyledText {
        id: valueText
        visible: !!root.currentValue
        text: root.currentValue
        elide: Text.ElideRight
        font.pixelSize: 15
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
        anchors.verticalCenter: textItem.verticalCenter
    }

    Rectangle {
        id: badge
        visible: root.isBadge & !root.isSwitch
        anchors.right: root.isSwitch ? switchItem.left : caret.left
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: textItem.verticalCenter
        radius: 9
        color: Style.current.blue
        width: 18
        height: 18
        Text {
            font.pixelSize: 12
            color: Style.current.white
            anchors.centerIn: parent
            text: root.badgeText
        }
    }

    SVGImage {
        id: caret
        visible: !root.isSwitch
        anchors.right: parent.right
        anchors.verticalCenter: textItem.verticalCenter
        source: "../../app/img/caret.svg"
        width: 13
        height: 7
        rotation: -90
        ColorOverlay {
            anchors.fill: caret
            source: caret
            color: Style.current.darkGrey
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.isEnabled
        onClicked: {
            root.clicked(!root.switchChecked)
        }

        cursorShape: Qt.PointingHandCursor
    }
}
