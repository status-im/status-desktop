import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

import utils 1.0

import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1

import shared.panels 1.0
import shared.status 1.0

Rectangle {
    property string pubKey: "0x123456"
    property string name: "Jotaro Kujo"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    property bool isIdenticon: true

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

    StatusSmartIdenticon {
        id: accountImage
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Style.current.padding
        image.source: identicon
        image.isIdenticon: isIdenticon
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

    StatusQControls.StatusCheckBox  {
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
