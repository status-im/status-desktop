import QtQuick 2.14
import QtQuick.Controls 2.14

Item {
    id: root

    // delegate properites
    property bool outgoing
    property string text
    property int index

    signal markAsUnreadClicked

    implicitHeight: text.implicitHeight + 2 * text.anchors.margins

    Rectangle {
        width: text.implicitWidth + 2 * text.anchors.margins

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: root.outgoing ? parent.right : undefined
            left: root.outgoing ? undefined : parent.left
        }

        color: root.outgoing ? "steelblue" : "grey"
        radius: 4

        Text {
            id: text

            anchors {
                fill: parent
                margins: 4
            }

            text: root.text
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: if (mouse.button === Qt.RightButton) {
                           contextMenu.popup()
                       }

            Menu {
                id: contextMenu
                Action {
                    text: "Mark as unread"
                    onTriggered: root.markAsUnreadClicked()
                }
            }
        }
    }
}
