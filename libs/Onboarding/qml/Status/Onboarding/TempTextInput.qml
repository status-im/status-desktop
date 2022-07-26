import QtQuick

TextInput {
    width: 416
    height: 44

    font.pointSize: 23
    verticalAlignment: TextInput.AlignVCenter

    clip: true

    Rectangle {
        anchors.fill: parent
        border.width: 1
        border.color: "#55555555"
        z: parent.z - 1
    }
}
