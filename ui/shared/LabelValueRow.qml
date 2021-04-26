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
    height: 52 * scaleAction.factor

    StyledText {
        id: txtLabel
        font.pixelSize: 15 * scaleAction.factor
        height: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        width: 105 * scaleAction.factor
    }
    Item {
        id: itmValue
        anchors.left: txtLabel.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
    }
}
