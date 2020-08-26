import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Button {
    id: root
    property alias label: txtBtnLabel.text

    width: txtBtnLabel.width + 2 * 12
    height: txtBtnLabel.height + 2 * 6

    background: Rectangle {
        color: Style.current.backgroundTertiary
        radius: 6
        anchors.fill: parent
        border.color: Style.current.borderTertiary
        border.width: 1
    }

    StyledText {
        id: txtBtnLabel
        color: Style.current.textColorTertiary
        font.pixelSize: 12
        height: 16
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        //% "Paste"
        text: qsTrId("paste")
    }

    MouseArea {
        id: mouse
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
    }
}