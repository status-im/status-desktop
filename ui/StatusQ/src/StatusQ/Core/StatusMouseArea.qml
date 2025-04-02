import QtQuick 2.15

import StatusQ.Core 0.1

/*!
   \qmltype StatusMouseArea
   \inherits StatusMouseArea
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief Mouse area that emits right click event on long press.

   Example:

   \qml
    StatusMouseArea {
        anchors.fill: parent
        buttons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                console.log("Right button clicked")
                mouse.accepted = true
            }
            
            if (mouse.button === Qt.LeftButton) {
                console.log("Left button clicked")
                mouse.accepted = true
            }
        }
    }
   \endqml
*/

MouseArea {
    id: root
    onPressAndHold: (mouse) => {
        if (mouse.button === Qt.LeftButton) {
            SystemUtils.synthetizeRightClick(root, mouse.x, mouse.y, mouse.modifiers)
        }
    }

    Loader {
        id: tapLoader
        anchors.fill: parent
        active: root.acceptedButtons === Qt.RightButton
        sourceComponent: TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds // exclusive grab on press
            acceptedButtons: Qt.LeftButton
            acceptedDevices: PointerDevice.TouchScreen
            onLongPressed: () => {
                SystemUtils.synthetizeRightClick(root, point.position.x, point.position.y, point.modifiers)
            }
        }
    }
}