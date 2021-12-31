import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusListItem {
    id: container
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.leftMargin: -Style.current.padding
    anchors.rightMargin: -Style.current.padding
    visible: container.isContact && (searchStr == "" || container.name.includes(searchStr))
    height: visible ? implicitHeight : 0
    title: container.name
    image.source: container.icon

    property string name: "Jotaro Kujo"
    property string publicKey: "0x04d8c07dd137bd1b73a6f51df148b4f77ddaa11209d36e43d8344c0a7d6db1cad6085f27cfb75dd3ae21d86ceffebe4cf8a35b9ce8d26baa19dc264efe6d8f221b"
    property string icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    property bool isIdenticon

    property bool isContact: true
    property bool isBlocked: false
    property string searchStr: ""

    signal openProfilePopup(string publicKey)
    signal sendMessageActionTriggered(string publicKey)
    signal unblockContactActionTriggered(string publicKey)
    signal blockContactActionTriggered(string publicKey)
    signal removeContactActionTriggered(string publicKey)

    components: [
        StatusFlatRoundButton {
            id: menuButton
            width: 32
            height: 32
            icon.name: "more"
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: {
                highlighted = true
                contactContextMenu.popup(-contactContextMenu.width+menuButton.width, menuButton.height + 4)
            }

            StatusPopupMenu {
                id: contactContextMenu

                onClosed: {
                    menuButton.highlighted = false
                }

                StatusMenuItem {
                    text: qsTr("View Profile")
                    icon.name: "profile"
                    onTriggered: {
                        container.openProfilePopup(container.publicKey)
                        menuButton.highlighted = false
                    }
                }

                StatusMenuItem {
                    text: qsTr("Send message")
                    icon.name: "chat"
                    onTriggered: {
                        container.sendMessageActionTriggered(container.publicKey)
                        menuButton.highlighted = false
                    }
                    enabled: !container.isBlocked
                }

                StatusMenuItem {
                    text: qsTr("Block User")
                    icon.name: "cancel"
                    enabled: !container.isBlocked
                    type: StatusMenuItem.Type.Danger
                    onTriggered: {
                        container.blockContactActionTriggered(container.publicKey)
                        menuButton.highlighted = false
                    }
                }

                StatusMenuItem {
                    text: qsTr("Remove contact")
                    icon.name: "remove-contact"
                    enabled: container.isContact
                    type: StatusMenuItem.Type.Danger
                    onTriggered: {
                        container.removeContactActionTriggered(container.publicKey)
                        menuButton.highlighted = false
                    }
                }

                StatusMenuItem {
                    text: qsTr("Unblock user")
                    icon.name: "cancel"
                    enabled: container.isBlocked
                    type: StatusMenuItem.Type.Danger
                    onTriggered: {
                        container.unblockContactActionTriggered(container.publicKey)
                        menuButton.highlighted = false
                        contactContextMenu.close()
                    }
                }
            }
        }
    ]
}

