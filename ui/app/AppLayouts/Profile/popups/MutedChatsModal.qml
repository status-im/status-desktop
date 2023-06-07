import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: root
    title: qsTr("Muted chats")

    property var model: []
    property string noContentText: ""

    signal unmuteChat(string chatId)

    onClosed: {
        root.destroy()
    }

    StatusListView {
        id: mutedChatsList
        anchors.fill: parent
        model: root.model
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
                asset.width: 40
                asset.height: 40
                asset.name: model.icon
                asset.isLetterIdenticon: asset.name === ""
                asset.letterSize: 15
                asset.color: Theme.palette.miscColor5
                name: model.name
            }

            StyledText {
                id: contactInfo
                text: model.name
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
                text: qsTr("Unmute")

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        channelItem.isHovered = true
                    }
                    onClicked: {
                        root.unmuteChat(model.itemId)
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
