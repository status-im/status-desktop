import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

TextInput {
    id: root

    /*!
        \qmlproperty var StatusBaseDateInput::placeholderText
        This property sets the placeholderText for input
    */
    property alias placeholderText: placeholder.text
    /*!
        \qmlproperty var StatusBaseDateInput::placeholder
        This property exposes the placeholder for customisation
    */
    property alias placeholder: placeholder
    /*!
        \qmlproperty var StatusBaseDateInput::tabNavItem
        This property sets the tab key navigation item.
    */
    property var tabNavItem: null

    /*!
        \qmlsignal
        This signal when the input is tapped 3 times
    */
    signal trippleTap()
    /*!
        \qmlsignal
        This signal is emitted when backspace is hit
    */
    signal clearEvent()

    verticalAlignment: TextInput.AlignVCenter
    horizontalAlignment: TextInput.AlignHCenter

    selectByMouse: false
    activeFocusOnPress: false
    persistentSelection: true

    font.pixelSize: 15
    font.family: Theme.palette.baseFont.name
    color: Theme.palette.directColor1
    selectedTextColor: color
    selectionColor: Theme.palette.primaryColor2

    KeyNavigation.priority: !!root.tabNavItem ? KeyNavigation.BeforeItem : KeyNavigation.AfterItem
    KeyNavigation.tab: root.tabNavItem
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Backspace:
            return root.clearEvent()

        case Qt.Key_Space:
            return root.tabNavItem.forceActiveFocus()
        }
    }

    cursorDelegate: StatusCursorDelegate {
        cursorVisible: root.cursorVisible
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.leftMargin: -5
        anchors.rightMargin: -5
        drag.target: dragItem
        drag.axis: Drag.XAxis
        onClicked: {
            root.forceActiveFocus()
            root.cursorPosition =  root.positionAt(mouse.x,mouse.y)
        }
        onDoubleClicked: root.selectAll()
        TapHandler {
            acceptedButtons: Qt.AllButtons
            onTapped: if (tapCount == 3) { root.trippleTap() }
        }
    }

    StatusBaseText {
        id: placeholder
        anchors.centerIn: parent
        verticalAlignment: parent.verticalAlignment
        horizontalAlignment: parent.horizontalAlignment
        font.pixelSize: 15
        text: root.placeholderText
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        color: Theme.palette.baseColor1
        visible: (root.length === 0)
    }

    DropArea {
        anchors.fill: parent
        onEntered: {
            root.forceActiveFocus()
            root.cursorPosition =  root.positionAt(drag.x,drag.y)
        }
        drag.onXChanged: {
            root.moveCursorSelection(root.positionAt(drag.x,drag.y), root.mouseSelectionMode)
        }
    }

    Item {
        id: dragItem
        width: 1
        height: 5
        Drag.active: mouseArea.drag.active
        Drag.hotSpot.x: dragItem.width / 2
        Drag.hotSpot.y: dragItem.height / 2
    }
}


