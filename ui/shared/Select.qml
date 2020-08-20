import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    enum MenuAlignment {
        Left,
        Right,
        Center
    }
    property string label: ""
    readonly property bool hasLabel: label !== ""
    property color bgColor: Style.current.inputBackground
    readonly property int labelMargin: 7
    property var model
    property alias menu: selectMenu
    property color bgColorHover: bgColor
    property alias selectedItemView: selectedItemContainer.children
    property int caretRightMargin: Style.current.padding
    property int caretLeftMargin: Style.current.halfPadding
    property alias select: inputRectangle
    property int menuAlignment: Select.MenuAlignment.Right
    property Item zeroItemsView: Item {}
    property int selectedItemRightMargin: caret.width + caretRightMargin + caretLeftMargin
    property string validationError: ""
    property alias validationErrorAlignment: validationErrorText.horizontalAlignment
    property int validationErrorTopMargin: Style.current.halfPadding
    anchors.left: parent.left
    anchors.right: parent.right

    id: root
    height: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0) + (!!validationError ? (validationErrorText.height + validationErrorTopMargin) : 0)

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
        border.width: !!validationError ? 1 : 0
        border.color: Style.current.danger

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
            property int zeroItemsViewHeight
            delegate: selectMenu.delegate
            onItemAdded: {
                root.zeroItemsView.visible = false
                root.zeroItemsView.height = 0
            }
            onItemRemoved: {
                if (count === 0) {
                    root.zeroItemsView.visible = true
                    root.zeroItemsView.height = zeroItemsViewHeight
                }
            }
            Component.onCompleted: {
                zeroItemsViewHeight = root.zeroItemsView.height
                root.zeroItemsView.visible = count === 0
                root.zeroItemsView.height = count !== 0 ? 0 : root.zeroItemsView.height
                selectMenu.insertItem(0, root.zeroItemsView)
            }
        }
    }
    TextEdit {
        id: validationErrorText
        visible: !!validationError
        text: validationError
        anchors.top: inputRectangle.bottom
        anchors.topMargin: validationErrorTopMargin
        selectByMouse: true
        readOnly: true
        font.pixelSize: 12
        height: 16
        color: Style.current.danger
        width: parent.width
        horizontalAlignment: TextEdit.AlignRight
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
                const rightOffset = inputRectangle.width - selectMenu.width
                let offset = rightOffset
                switch (root.menuAlignment) {
                    case Select.MenuAlignment.Left:
                        offset = 0
                        break
                    case Select.MenuAlignment.Right:
                        offset = rightOffset
                        break
                    case Select.MenuAlignment.Center:
                        offset = rightOffset / 2
                }
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
