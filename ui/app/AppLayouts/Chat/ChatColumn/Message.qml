import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"

Rectangle {
    id: chatBox
    height: 60 + chatText.height
    color: "#00000000"
    border.color: "#00000000"
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    Layout.fillWidth: true
    width: chatLogView.width

    Image {
        id: chatImage
        width: 30
        height: 30
        anchors.left: !isCurrentUser ? parent.left : undefined
        anchors.leftMargin: !isCurrentUser ? Theme.padding : 0
        anchors.right: !isCurrentUser ? undefined : parent.right
        anchors.rightMargin: !isCurrentUser ? 0 : Theme.padding
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        fillMode: Image.PreserveAspectFit
        source: identicon
    }

    TextEdit {
        id: chatName
        text: userName
        anchors.top: parent.top
        anchors.topMargin: 22
        anchors.left: !isCurrentUser ? chatImage.right : undefined
        anchors.leftMargin: Theme.padding
        anchors.right: !isCurrentUser ? undefined : chatImage.left
        anchors.rightMargin: !isCurrentUser ? 0 : Theme.padding
        font.bold: true
        font.pixelSize: 14
        readOnly: true
        wrapMode: Text.WordWrap
        selectByMouse: true
    }

    TextEdit {
        id: chatText
        text: message
        horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
        font.family: "Inter"
        wrapMode: Text.WordWrap
        anchors.right: !isCurrentUser ? parent.right : chatName.right
        anchors.rightMargin: !isCurrentUser ? 60 : 0
        anchors.left: !isCurrentUser ? chatName.left : parent.left
        anchors.leftMargin: !isCurrentUser ? 0 : 60
        anchors.top: chatName.bottom
        anchors.topMargin: Theme.padding
        font.pixelSize: 14
        readOnly: true
        selectByMouse: true
        Layout.fillWidth: true
    }

    TextEdit {
        id: chatTime
        color: Theme.darkGrey
        font.family: "Inter"
        text: timestamp
        anchors.top: chatText.bottom
        anchors.bottomMargin: Theme.padding
        anchors.right: !isCurrentUser ? parent.right : undefined
        anchors.rightMargin: !isCurrentUser ? Theme.padding : 0
        anchors.left: !isCurrentUser ? undefined : parent.left
        anchors.leftMargin: !isCurrentUser ? 0 : Theme.padding
        font.pixelSize: 10
        readOnly: true
        selectByMouse: true
    }
}
