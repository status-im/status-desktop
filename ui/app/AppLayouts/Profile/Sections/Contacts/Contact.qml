import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../../imports"
import "../../../../../shared"

Rectangle {
    property string name: "Jotaro Kujo"
    property string address: "0x04d8c07dd137bd1b73a6f51df148b4f77ddaa11209d36e43d8344c0a7d6db1cad6085f27cfb75dd3ae21d86ceffebe4cf8a35b9ce8d26baa19dc264efe6d8f221b"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    property bool selectable: false
    property var profileClick: function() {}
    property bool isContact: true

    visible: isContact
    height: visible ? 64 : 0
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    radius: Style.current.radius

    Identicon {
        id: accountImage
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        source: identicon
    }
    StyledText {
        id: usernameText
        text: name
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: 17
        anchors.top: accountImage.top
        anchors.left: accountImage.right
        anchors.leftMargin: Style.current.padding
    }
    StyledText {
        id: addressText
        width: 108
        font.family: Style.current.fontHexRegular.name
        text: address
        elide: Text.ElideMiddle
        anchors.bottom: accountImage.bottom
        anchors.bottomMargin: 0
        anchors.left: usernameText.left
        anchors.leftMargin: 0
        font.pixelSize: 15
        color: Style.current.darkGrey
    }
    RadioButton {
        visible: selectable
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.right: parent.right
        ButtonGroup.group: contactGroup
    }
    MouseArea {
        enabled: !selectable
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            profileClick(name, address, identicon)
        }
    }
}
