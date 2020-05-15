import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../imports"

SplitView {
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
                        height: 64
                        color: ListView.isCurrentItem ? Theme.lightBlue : Theme.transparent
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.padding
                        anchors.top: applicationWindow.top
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.padding
                        radius: 8

                        MouseArea {
                            anchors.fill: parent
                            onClicked: listView.currentIndex = index
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
                            text: "Name:" + name
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
                    id: listView
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

            Rectangle {
                id: chatBox
                height: 140
                color: "#00000000"
                border.color: "#00000000"
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillWidth: true

                Image {
                    id: chatImage
                    width: 30
                    height: 30
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    fillMode: Image.PreserveAspectFit
                    source: "../img/placeholder-profile.png"
                }

                TextEdit {
                    id: chatName
                    text: qsTr("Slushy Welltodo Woodborer")
                    anchors.top: parent.top
                    anchors.topMargin: 22
                    anchors.left: chatImage.right
                    anchors.leftMargin: 16
                    font.bold: true
                    font.pixelSize: 14
                    readOnly: true
                    selectByMouse: true
                }

                TextEdit {
                    id: chatText
                    text: qsTr("I’m generally against putting too many rules on social interaction because it makes interaction anything but social, but technical specifics on how to get on board or participate in a team are I think generally useful, especially if they prevent maintainers from pasting the same response to every PR / issue.")
                    font.family: "Inter"
                    wrapMode: Text.WordWrap
                    anchors.right: parent.right
                    anchors.rightMargin: 60
                    anchors.left: chatName.left
                    anchors.leftMargin: 0
                    anchors.top: chatName.bottom
                    anchors.topMargin: 16
                    font.pixelSize: 14
                    readOnly: true
                    selectByMouse: true
                }

                TextEdit {
                    id: chatTime
                    color: Theme.darkGrey
                    font.family: "Inter"
                    text: qsTr("7:30 AM")
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    font.pixelSize: 10
                    readOnly: true
                    selectByMouse: true
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

            Item {
                id: element2
                width: 200
                height: 70
                Layout.fillWidth: true

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
    D{i:0;formeditorZoom:0.5;height:770;width:1152}
}
##^##*/
