import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../imports"

SplitView {
    property alias searchStr: searchText.text

    id: chatView
    x: 0
    y: 0
    Layout.fillHeight: true
    Layout.fillWidth: true
    // Those anchors show a warning too, but whithout them, there is a gap on the right
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0

    Item {

        id: contactsColumn
        width: 300
        height: parent.height
        Layout.minimumWidth: 200

        ColumnLayout {
            anchors.fill: parent

            Item {
                Layout.preferredHeight: 100
                Layout.fillHeight: false
                Layout.fillWidth: true

                Text {
                    id: element
                    x: 772
                    text: qsTr("Chat")
                    anchors.top: parent.top
                    anchors.topMargin: 17
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 17
                }

                Rectangle {
                    id: searchBox
                    height: 36
                    color: Theme.grey
                    anchors.top: parent.top
                    anchors.topMargin: 59
                    radius: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 65
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    TextField {
                        id: searchText
                        placeholderText: qsTr("Search")
                        anchors.left: parent.left
                        anchors.leftMargin: 32
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 12
                        background: Rectangle {
                            color: "#00000000"
                        }
                    }

                    Image {
                        id: image4
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: "../img/search.svg"
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked : {
                            searchText.forceActiveFocus(Qt.MouseFocusReason)
                        }
                    }
                }

                Rectangle {
                    id: addChat
                    width: 36
                    height: 36
                    color: Theme.blue
                    radius: 50
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.top: parent.top
                    anchors.topMargin: 59

                    Text {
                        id: element3
                        color: "#ffffff"
                        text: qsTr("+")
                        anchors.verticalCenterOffset: -1
                        anchors.horizontalCenterOffset: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        lineHeight: 1
                        fontSizeMode: Text.FixedSize
                        font.bold: true
                        font.pixelSize: 28
                    }

                     MouseArea {
                        anchors.fill: parent
                        onClicked : {
                            chatsModel.addNameTolist(searchText.text)
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Component {
                    id: chatViewDelegate

                    Rectangle {
                        id: wrapper
                        color: ListView.isCurrentItem ? Theme.lightBlue : Theme.transparent
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.padding
                        anchors.top: applicationWindow.top
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.padding
                        radius: 8
                        // Hide the box if it is filtered out
                        property bool isVisible: searchStr == "" || name.includes(searchStr)
                        visible: isVisible ? true : false
                        height: isVisible ? 64 : 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: chatGroupsListView.currentIndex = index
                        }

                        Rectangle {
                            id: contactImage
                            width: 40
                            color: Theme.darkGrey
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.padding
                            anchors.top: parent.top
                            anchors.topMargin: 12
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 12
                            radius: 50
                        }

                        Text {
                            id: contactInfo
                            text: name
                            anchors.right: contactTime.left
                            anchors.rightMargin: Theme.smallPadding
                            elide: Text.ElideRight
                            font.weight: Font.Medium
                            font.pixelSize: 15
                            anchors.left: contactImage.right
                            anchors.leftMargin: Theme.padding
                            anchors.top: parent.top
                            anchors.topMargin: Theme.smallPadding
                            color: "black"
                        }
                        Text {
                            id: lastChatMessage
                            text: "Chatting blah blah..."
                            anchors.right: contactNumberChatsCircle.left
                            anchors.rightMargin: Theme.smallPadding
                            elide: Text.ElideRight
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Theme.smallPadding
                            font.pixelSize: 15
                            anchors.left: contactImage.right
                            anchors.leftMargin: Theme.padding
                            color: Theme.darkGrey
                        }
                        Text {
                            id: contactTime
                            text: "12:22 AM"
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.padding
                            anchors.top: parent.top
                            anchors.topMargin: Theme.smallPadding
                            font.pixelSize: 11
                            color: Theme.darkGrey
                        }
                        Rectangle {
                            id: contactNumberChatsCircle
                            width: 22
                            height: 22
                            radius: 50
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Theme.smallPadding
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.padding
                            color: Theme.blue
                            Text {
                                id: contactNumberChats
                                text: qsTr("1")
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                color: "white"
                            }
                        }
                    }
                }

                ListView {
                    id: chatGroupsListView
                    anchors.topMargin: 24
                    anchors.fill: parent
                    model: chatsModel
                    delegate: chatViewDelegate
                }
            }
        }
    }

    ColumnLayout {
        id: chatColumn
        spacing: 0
        anchors.left: contactsColumn.right
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        RowLayout {
            id: chatContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            Component {
                id: chatLogViewDelegate
                Rectangle {
                    id: chatBox
                    height: 140
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
                onCountChanged: {
                    chatLogView.positionViewAtEnd()
                }
            }
        }

//        RowLayout {
//            id: separator
//            height: 16
//            Layout.fillWidth: true
//            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

//            Item {
//                id: separatorContent
//                width: 200
//                height: 16
//                Layout.fillHeight: false
//                Layout.fillWidth: true

//                Rectangle {
//                    id: lineSeparator1
//                    height: 1
//                    color: "#00000000"
//                    border.color: "#eef2f5"
//                    anchors.top: parent.top
//                    anchors.topMargin: 8
//                    anchors.right: separatorText.left
//                    anchors.rightMargin: 14
//                    anchors.left: parent.left
//                    anchors.leftMargin: 16
//                }

//                Text {
//                    id: separatorText
//                    color: Theme.darkGrey
//                    text: qsTr("Yesterday")
//                    font.pixelSize: 12
//                    anchors.centerIn: parent
//                }

//                Rectangle {
//                    id: lineSeparator2
//                    height: 1
//                    color: "#00000000"
//                    anchors.right: parent.right
//                    anchors.rightMargin: 16
//                    anchors.left: separatorText.right
//                    border.color: "#eef2f5"
//                    anchors.top: parent.top
//                    anchors.leftMargin: 14
//                    anchors.topMargin: 8
//                }
//            }

//        }

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
}
/*##^##
Designer {
    D{i:0;formeditorZoom:0.75;height:770;width:1152}
}
##^##*/
