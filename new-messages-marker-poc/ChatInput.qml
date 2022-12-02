import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: root

    property alias text: textArea.text

    implicitHeight: 40

    color: "grey"
    radius: 4

    signal enterClicked()

    TextArea {
        id: textArea

        anchors {
            fill: parent
            margins: 4
        }

        placeholderText: qsTr("Message")
        color: "white"

        Keys.onPressed: {
            if (event.key === Qt.Key_Return) {
                root.enterClicked()
                event.accepted = true
            }
        }
    }
}
