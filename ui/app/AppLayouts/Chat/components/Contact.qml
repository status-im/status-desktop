import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Rectangle {
    property string pubKey: "0x123456"
    property string name: "Jotaro Kujo"
    property string address: "0x04d8c07dd137bd1b73a6f51df148b4f77ddaa11209d36e43d8344c0a7d6db1cad6085f27cfb75dd3ae21d86ceffebe4cf8a35b9ce8d26baa19dc264efe6d8f221b"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="

    property bool isContact: true
    property bool isUser: false
    property bool isVisible: true

    property bool showCheckbox: true
    property bool clickable: true
    property bool isChecked: false
    property bool isHovered: false
    property var onItemChecked: (function(pubKey, itemChecked) { console.log(pubKey, itemChecked)  })

    property var onContactClicked

    id: root
    visible: isVisible && (isContact || isUser)
    height: visible ? 64 : 0
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    radius: Style.current.radius
    color: isHovered ? Style.current.backgroundHover : Style.current.transparent

    StatusImageIdenticon {
        id: accountImage
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        source: identicon
        anchors.leftMargin: Style.current.padding
    }
    
    StyledText {
        id: usernameText
        text: name
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: 17
        anchors.top: accountImage.top
        anchors.topMargin: 10
        anchors.left: accountImage.right
        anchors.leftMargin: Style.current.padding
    }

    StatusCheckBox  {
        id: assetCheck
        visible: showCheckbox && !isUser
        anchors.top: accountImage.top
        anchors.topMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        checked: isChecked
        onClicked: {
            isChecked = !isChecked
            onItemChecked(pubKey, isChecked)
        }
    }

    StyledText {
        visible: isUser
        //% "Admin"
        text: qsTrId("group-chat-admin")
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: 15
        color: Style.current.darkGrey
        anchors.top: accountImage.top
        anchors.topMargin: 10
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        enabled: root.clickable || root.showCheckbox
        hoverEnabled: root.clickable || root.showCheckbox
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            if (typeof root.onContactClicked !== "function") {
                return assetCheck.clicked()
            }
            root.onContactClicked()
        }
    }
}
