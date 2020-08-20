import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"

Item {
    id: itmFrom
    property alias label: txtLabel.text
    property alias value: itmValue.children
    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
    Layout.preferredWidth: parent.width
    width: parent.width
    height: 52

    StyledText {
        id: txtLabel
        font.pixelSize: 15
        height: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        width: 105
    }
    Item {
        id: itmValue
        anchors.left: txtLabel.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
    }
}