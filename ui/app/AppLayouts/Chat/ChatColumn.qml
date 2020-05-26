import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"

StackLayout {
    property int chatGroupsListViewCount: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    currentIndex: chatGroupsListViewCount > 0 ? 0 : 1

    ColumnLayout {
        id: chatColumn

        RowLayout {
            id: chatTopBar
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            z: 60

            Rectangle {
                property string channelNameStr: "#" + chatsModel.activeChannel

                id: chatTopBarContent
                color: "white"
                height: 56
                Layout.fillWidth: true
                border.color: Theme.grey
                border.width: 1

                // TODO this should be the Identicon if it's a private chat
                Rectangle {
                    id: channelIcon
                    width: 36
                    height: 36
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.padding
                    anchors.top: parent.top
                    anchors.topMargin: Theme.smallPadding
                    color: {
                        if (!chatsModel.activeChannel) {
                            return Theme.transparent
                        }
                        const color = chatsModel.getChannelColor(chatsModel.activeChannel)
                        if (!color) {
                            return Theme.transparent
                        }
                        return color
                    }
                    radius: 50

                    Text {
                        id: channelIconText
                        color: "white"
                        opacity: 0.7
                        text: chatTopBarContent.channelNameStr.substring(1, 2).toUpperCase()
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.weight: Font.Bold
                        font.pixelSize: 18
                    }
                }

                TextEdit {
                    id: channelName
                    width: 80
                    height: 20
                    text: chatTopBarContent.channelNameStr
                    anchors.left: channelIcon.right
                    anchors.leftMargin: Theme.smallPadding
                    anchors.top: parent.top
                    anchors.topMargin: Theme.smallPadding
                    font.weight: Font.Medium
                    font.pixelSize: 15
                    selectByMouse: true
                    readOnly: true
                }

                Text {
                    id: channelIdentifier
                    color: Theme.darkGrey
                    // TODO change this in case of private message
                    text: "Public chat"
                    font.pixelSize: 12
                    anchors.left: channelIcon.right
                    anchors.leftMargin: Theme.smallPadding
                    anchors.top: channelName.bottom
                    anchors.topMargin: 0
                }

                Text {
                    id: moreActionsBtn
                    text: "..."
                    font.letterSpacing: 0.5
                    font.bold: true
                    lineHeight: 1.4
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    font.pixelSize: 25

                    MouseArea {
                        id: mouseArea
                        // The negative margins are for the mouse area to be a bit more wide around the button and have more space for the click
                        anchors.topMargin: -10
                        anchors.bottomMargin: -10
                        anchors.rightMargin: -15
                        anchors.leftMargin: -15
                        anchors.fill: parent
                        onClicked: console.log("Options click. Will do something later...")
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        RowLayout {
            id: chatContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            Component {
                id: chatLogViewDelegate
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
            }

            ListView {
                id: chatLogView
                anchors.fill: parent
                model: chatsModel.messageList
                Layout.fillWidth: true
                Layout.fillHeight: true
                delegate: chatLogViewDelegate
                highlightFollowsCurrentItem: true
                onCountChanged: {
                    if (!this.atYEnd) {
                        // User has scrolled up, we don't want to scroll back
                        return;
                    }

                    // positionViewAtEnd doesn't work well. Instead, we use highlightFollowsCurrentItem
                    // and set the current Item/Index to the latest item
                    while (this.currentIndex < this.count - 1) {
                        this.incrementCurrentIndex()
                    }

                }
            }
        }

        RowLayout {
            id: chatInputContainer
            height: 70
            Layout.fillWidth: true
            Layout.bottomMargin: 0
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            transformOrigin: Item.Bottom

            Rectangle {
                id: element2
                width: 200
                height: 70
                Layout.fillWidth: true
                color: "white"
                border.width: 0

                Rectangle {
                    id: rectangle
                    color: "#00000000"
                    border.color: Theme.grey
                    anchors.fill: parent

                    Button {
                        id: chatSendBtn
                        x: 100
                        width: 30
                        height: 30
                        text: "\u2191"
                        font.bold: true
                        font.pointSize: 12
                        anchors.top: parent.top
                        anchors.topMargin: 20
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        onClicked: {
                            chatsModel.onSend(txtData.text)
                            txtData.text = ""
                        }
                        enabled: txtData.text !== ""
                        background: Rectangle {
                            color: parent.enabled ? Theme.blue : Theme.grey
                            radius: 50
                        }
                    }

                    TextField {
                        id: txtData
                        text: ""
                        leftPadding: 0
                        padding: 0
                        font.pixelSize: 14
                        placeholderText: qsTr("Type a message...")
                        anchors.right: chatSendBtn.left
                        anchors.rightMargin: 16
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        Keys.onEnterPressed: {
                            chatsModel.onSend(txtData.text)
                            txtData.text = ""
                        }
                        Keys.onReturnPressed: {
                            chatsModel.onSend(txtData.text)
                            txtData.text = ""
                        }
                        background: Rectangle {
                            color: "#00000000"
                        }
                    }

                    MouseArea {
                        id: mouseArea1
                        anchors.rightMargin: 50
                        anchors.fill: parent
                        onClicked : {
                            txtData.forceActiveFocus(Qt.MouseFocusReason)
                        }
                    }
                }
            }
        }

    }

    ColumnLayout {
        Layout.margins: 0
        Layout.fillHeight: false
        Layout.fillWidth: false
        anchors.left: parent.left
        anchors.leftMargin: 200
        anchors.right: parent.right
        anchors.rightMargin: 200
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 200
        anchors.top: parent.top
        anchors.topMargin: 100
        Image {
            source: "../../../onboarding/img/chat@2x.jpg"
        }

        Text {
            text: "Select a chat to start messaging"
            font.weight: Font.DemiBold
            font.pixelSize: 15
            color: Theme.darkGrey
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
    }
}

/*##^##
Designer {
    D{i:0;height:770;width:800}
}
##^##*/
