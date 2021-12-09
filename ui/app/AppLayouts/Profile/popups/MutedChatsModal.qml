import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: root
    //% "Muted chats"
    title: qsTrId("muted-chats")
    property bool showMutedContacts: false
    property string noContentText: ""

    onClosed: {
        root.destroy()
    }

    ListView {
        id: mutedChatsList
        anchors.top: parent.top
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        model: root.showMutedContacts ? profileModel.mutedChats.contacts : profileModel.mutedChats.chats
        delegate: Rectangle {
            id: channelItem
            property bool isHovered: false
            height: contactImage.height + Style.current.smallPadding * 2
            width: parent.width
            radius: Style.current.radius
            color: isHovered ? Style.current.backgroundHover : Style.current.transparent

            StatusSmartIdenticon {
                id: contactImage
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                anchors.verticalCenter: parent.verticalCenter
                image: StatusImageSettings {
                    width: 40
                    height: 40
                    source: model.identicon
                    isIdenticon: true
                }
                icon: StatusIconSettings {
                    width: 40
                    height: 40
                    letterSize: 15
                    color: Theme.palette.miscColor5
                }
                name: model.name
            }

            StyledText {
                id: contactInfo
                text: model.chatType !== Constants.chatType.publicChat ?
                    Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(model.name)), "26x26") :
              "#" + Utils.filterXSS(model.name)
                anchors.right: unmuteButton.left
                anchors.rightMargin: Style.current.smallPadding
                elide: Text.ElideRight
                font.pixelSize: 15
                anchors.left: contactImage.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: channelItem.isHovered = true
                onExited: channelItem.isHovered = false
            }

            StatusFlatButton {
                id: unmuteButton
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
                anchors.verticalCenter: parent.verticalCenter
                //% "Unmute"
                text: qsTrId("unmute")

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        channelItem.isHovered = true
                    }
                    onClicked: {
                        chatsModel.channelView.unmuteChatItem(model.id)
                    }
                }
            }
        }
    }

    StyledText {
        anchors.centerIn: parent
        visible: (mutedChatsList.count === 0)
        text: root.noContentText
    }
}
