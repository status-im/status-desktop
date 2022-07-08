import QtQuick

TextInput {
    width: 416
    height: 44

    font.pointSize: 23
    verticalAlignment: TextInput.AlignVCenter

    Rectangle {
        anchors {
            fill: parent
            margins: -1
        }
        border.width: 1
        z: parent.z - 1
    }
}
