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
    property int customHeight: 56
    property string selectedText: ""
    property url icon: ""
    property int iconHeight: 12
    property int iconWidth: 12
    property color iconColor: Style.current.transparent
    property alias menu: selectMenu

    readonly property bool hasIcon: icon.toString() !== ""

    id: root
    height: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0)
    anchors.right: parent.right
    anchors.left: parent.left

    StyledText {
        id: inputLabel
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
        id: inputRectangle
        height: customHeight
        color: bgColor
        radius: Style.current.radius
        anchors.top: root.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: root.hasLabel ? root.labelMargin : 0
        anchors.right: parent.right
        anchors.left: parent.left

        SVGImage {
            id: iconImg
            visible: root.hasIcon
            sourceSize.height: iconHeight
            sourceSize.width: iconWidth
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: root.icon
        }
        ColorOverlay {
            anchors.fill: iconImg
            source: iconImg
            color: iconColor
        }

        StyledText {
            id: selectedTextField
            visible: root.selectedText !== ""
            text: root.selectedText
            anchors.left: iconImg.right
            anchors.leftMargin: hasIcon ? 8 : 0
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 15
            height: 22
        }

        SVGImage {
            id: caret
            width: 11
            height: 6
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: "../app/img/caret.svg"
        }
        ColorOverlay {
            anchors.fill: caret
            source: caret
            color: Style.current.grey
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
        color: Style.current.white
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
            color: Style.current.white
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
        onClicked: {
            if (selectMenu.opened) {
                selectMenu.close()
            } else {
                selectMenu.popup(inputRectangle.x, inputRectangle.y + inputRectangle.height + 8)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
