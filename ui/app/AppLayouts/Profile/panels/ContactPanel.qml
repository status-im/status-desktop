import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.views 1.0
import shared.controls.chat 1.0

StatusListItem {
    id: container
    width: parent.width
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

    property bool showSendMessageButton: false

    signal openProfilePopup(string publicKey)
    signal openChangeNicknamePopup(string publicKey)
    signal sendMessageActionTriggered(string publicKey)

    components: [
        StatusFlatRoundButton {
            visible: showSendMessageButton
            id: sendMessageBtn
            width: visible ? 32 : 0
            height: visible ? 32 : 0
            icon.name: "chat"
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: container.sendMessageActionTriggered(container.publicKey)
        },
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

                ProfileHeader {
                    width: parent.width

                    displayName: container.name
                    pubkey: container.publicKey
                    icon: container.icon
                    isIdenticon: container.isIdenticon
                }

                Item {
                    height: 8
                }

                Separator {}

                StatusMenuItem {
                    text: qsTr("View Profile")
                    icon.name: "profile"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        container.openProfilePopup(container.publicKey)
                        menuButton.highlighted = false
                    }
                }

                StatusMenuItem {
                    text: qsTr("Send message")
                    icon.name: "chat"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        container.sendMessageActionTriggered(container.publicKey)
                        menuButton.highlighted = false
                    }
                    enabled: !container.isBlocked
                }

                StatusMenuItem {
                    text: qsTr("Rename")
                    icon.name: "edit_pencil"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        container.openChangeNicknamePopup(container.publicKey)
                        menuButton.highlighted = false
                    }
                    enabled: !container.isBlocked
                }
            }
        }
    ]
}

