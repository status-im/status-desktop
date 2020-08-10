import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    property string label: ""
    readonly property bool hasLabel: label !== ""
    property color bgColor: Style.current.inputBackground
    readonly property int labelMargin: 7
    property var model
    property alias menu: selectMenu
    property color bgColorHover: bgColor
    property alias selectedItemView: selectedItemContainer.children
    property int caretRightMargin: Style.current.padding
    property alias select: inputRectangle
    anchors.left: parent.left
    anchors.right: parent.right

    id: root
    height: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0)

    StyledText {
        id: inputLabel
        visible: hasLabel
        text: root.label
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        font.pixelSize: 13
        height: 18
    }

    Rectangle {
        property bool hovered: false
        id: inputRectangle
        height: 56
        color: hovered ? bgColorHover : bgColor
        radius: Style.current.radius
        anchors.top: root.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: root.hasLabel ? root.labelMargin : 0
        anchors.right: parent.right
        anchors.left: parent.left

        Item {
            id: selectedItemContainer
            anchors.fill: parent
        }

        SVGImage {
            id: caret
            width: 11
            height: 6
            anchors.right: parent.right
            anchors.rightMargin: caretRightMargin
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: "../app/img/caret.svg"
        }
        ColorOverlay {
            anchors.fill: caret
            source: caret
            color: Style.current.secondaryText
        }
    }

    // create a drop shadow externally so that it is not clipped by the 
    // rounded corners of the menu background
    Rectangle {
        width: selectMenu.width
        height: selectMenu.height
        x: selectMenu.x
        y: selectMenu.y
        visible: selectMenu.opened
        color: Style.current.background
        radius: Style.current.radius
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: Style.current.radius
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    Menu {
        id: selectMenu
        property var items: []
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        width: parent.width
        background: Rectangle {
            // do not add a drop shadow effect here or it will be clipped
            radius: Style.current.radius
            color: Style.current.background
        }
        clip: true
        delegate: menuItem

        Repeater {
            id: menuItems
            model: root.model
            delegate: selectMenu.delegate
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: inputRectangle
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
            inputRectangle.hovered = true
        }
        onExited: {
            inputRectangle.hovered = false
        }
        onClicked: {
            if (selectMenu.opened) {
                selectMenu.close()
            } else {
                const offset = inputRectangle.width - selectMenu.width
                selectMenu.popup(inputRectangle.x + offset, inputRectangle.y + inputRectangle.height + 8)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
