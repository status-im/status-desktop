import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"

Rectangle {
    id: root
    height: visible ? childrenRect.height : 0
    width: 375
    color: "transparent"

    SVGImage {
        id: sticker
        anchors.top: parent.top
        width: 140
        height: 140
        source: "../../img/think-sticker.png"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        anchors.top: sticker.bottom
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.right: parent.right
        anchors.rightMargin: 60
        border.color: Style.current.border
        border.width: 1
        radius: Style.current.padding
        width: 255
        height: shareYourMindText.height + Style.current.padding

        StyledText {
            id: shareYourMindText
            horizontalAlignment: Text.AlignHCenter
            anchors.left: parent.left
            anchors.leftMargin: Style.current.halfPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.halfPadding
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Share what's on your mind and stay updated with your contacts")
            font.pixelSize: 15
            color: Style.current.secondaryText
            wrapMode: Text.WordWrap
        }
    }
}
