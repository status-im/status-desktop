import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "./imports"

ApplicationWindow {
    id: applicationWindow
    width: 1024
    height: 768
    title: "Nim Status Client"
    visible: true
    font.family: "Inter"

    SystemTrayIcon {
        visible: true
        icon.source: "status-logo.png"

        onActivated: {
            applicationWindow.show()
            applicationWindow.raise()
            applicationWindow.requestActivate()
        }
    }

    RowLayout {
        id: rowLayout
        width: parent.width
        height: parent.height
        anchors.fill: parent
        //        spacing: 50

        TabBar {
            id: tabBar
            y: 0
            width: 50
            height: width *2 + spacing
            Layout.preferredHeight: 0
            currentIndex: 0
            topPadding: 57
            rightPadding: 19
            leftPadding: 19
            transformOrigin: Item.Top
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
            anchors.top: parent.top
            spacing: 5
            Layout.fillWidth: true
            Layout.minimumWidth: 80
            Layout.preferredWidth: 80
            Layout.maximumWidth: 80
            Layout.minimumHeight: 0
            background: Rectangle {
                color: "#00000000"
                border.color: Theme.grey
            }

            TabButton {
                id: chatBtn
                x: 0
                width: 40
                height: 40
                text: ""
                padding: 0
                transformOrigin: Item.Center
                anchors.horizontalCenter: parent.horizontalCenter
                background: Rectangle {
                    color: Theme.lightBlue
                    opacity: parent.checked ? 1 : 0
                    radius: 50
                }

                Image {
                    id: image
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.checked ? "img/messageActive.svg" : "img/message.svg"
                }
            }

            TabButton {
                id: walletBtn
                width: 40
                height: 40
                text: ""
                anchors.topMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: chatBtn.top
                background: Rectangle {
                    color: Theme.lightBlue
                    opacity: parent.checked ? 1 : 0
                    radius: 50
                }

                Image {
                    id: image1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.checked ? "img/walletActive.svg" : "img/wallet.svg"
                }
            }

            TabButton {
                id: browserBtn
                width: 40
                height: 40
                text: ""
                anchors.topMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: walletBtn.top
                background: Rectangle {
                    color: Theme.lightBlue
                    opacity: parent.checked ? 1 : 0
                    radius: 50
                }

                Image {
                    id: image2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.checked ? "img/compassActive.svg" : "img/compass.svg"
                }
            }

            TabButton {
                id: profileBtn
                width: 40
                height: 40
                text: ""
                anchors.topMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: browserBtn.top
                background: Rectangle {
                    color: Theme.lightBlue
                    opacity: parent.checked ? 1 : 0
                    radius: 50
                }

                Image {
                    id: image3
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: parent.checked ? "img/profileActive.svg" : "img/profile.svg"
                }
            }
        }

        StackLayout {
            width: parent.width
            Layout.fillWidth: true
            currentIndex: tabBar.currentIndex

            SplitView {
                id: splitView
                x: 9
                y: 0
                Layout.fillHeight: true
                //            anchors.fill: parent
                //            width: parent.width
                Layout.leftMargin: 0
                Layout.fillWidth: true
                Layout.minimumWidth: 100
                Layout.preferredWidth: 200
                //            Layout.preferredHeight: 100

                Item {
                    id: element1
                    width: 300
                    height: parent.height
                    Layout.minimumWidth: 200

                    ColumnLayout {
                        anchors.rightMargin: 0
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
                                anchors.leftMargin: Theme.padding

                                TextField {
                                    id: searchText
                                    placeholderText: qsTr("Search")
                                    anchors.left: parent.left
                                    anchors.leftMargin: 32
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: 12
                                    background: {
                                    }
                                }

                                Image {
                                    id: image4
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.smallPadding
                                    anchors.verticalCenter: parent.verticalCenter
                                    fillMode: Image.PreserveAspectFit
                                    source: "img/search.svg"
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
                                anchors.rightMargin: Theme.padding
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

                Item {
                    width: parent.width/2
                    height: parent.height

                    ColumnLayout {
                        anchors.rightMargin: 0
                        anchors.fill: parent

                        RowLayout {
                            id: chatContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

                            Rectangle {
                                id: chatBox
                                height: 140
                                color: "#00000000"
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                Layout.fillWidth: true
                                border.color: "#00000000"

                                Image {
                                    id: chatImage
                                    width: 30
                                    height: 30
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.top: parent.top
                                    anchors.topMargin: 16
                                    fillMode: Image.PreserveAspectFit
                                    source: "img/placeholder-profile.png"
                                }

                                Text {
                                    id: chatName
                                    text: qsTr("Slushy Welltodo Woodborer")
                                    anchors.top: parent.top
                                    anchors.topMargin: 22
                                    anchors.left: chatImage.right
                                    anchors.leftMargin: 16
                                    font.bold: true
                                    font.pixelSize: 14
                                }

                                Text {
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
                                }

                                Text {
                                    id: chatTime
                                    color: Theme.darkGrey
                                    font.family: "Inter"
                                    text: qsTr("7:30 AM")
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    font.pixelSize: 10
                                }
                            }
                        }

                        RowLayout {
                            id: separator
                            height: 16
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            anchors.top: chatContainer.bottom
                            anchors.topMargin: Theme.padding

                            Item {
                                id: separatorContent
                                width: 200
                                height: 16
                                Layout.fillHeight: false
                                Layout.fillWidth: true

                                Rectangle {
                                    id: lineSeparator1
                                    height: 1
                                    color: "#00000000"
                                    border.color: "#eef2f5"
                                    anchors.top: parent.top
                                    anchors.topMargin: 8
                                    anchors.right: separatorText.left
                                    anchors.rightMargin: 14
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                }

                                Text {
                                    id: separatorText
                                    color: Theme.darkGrey
                                    text: qsTr("Yesterday")
                                    font.pixelSize: 12
                                    anchors.centerIn: parent
                                }

                                Rectangle {
                                    id: lineSeparator2
                                    height: 1
                                    color: "#00000000"
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    anchors.left: separatorText.right
                                    border.color: "#eef2f5"
                                    anchors.top: parent.top
                                    anchors.leftMargin: 14
                                    anchors.topMargin: 8
                                }
                            }

                        }

                        RowLayout {
                            id: resultContainer
                            Layout.fillHeight: true
                            TextArea { id: callResult; Layout.fillWidth: true; text: logic.callResult; readOnly: true }
                        }

                        RowLayout {
                            id: chatInputContainer
                            height: 70
                            Layout.bottomMargin: 20
                            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                            transformOrigin: Item.Bottom
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 0
                            
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
                                        onClicked: logic.onSend(txtData.text)
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
                                        background: {}
                                    }


                    }

                }


            }

            ColumnLayout {
                anchors.fill: parent

                RowLayout {
                    Layout.fillHeight: true
                    TextArea { id: accountResult; Layout.fillWidth: true; text: logic.accountResult; readOnly: true }
                }
            }

            Item {

            }
        }
    }


}




/*##^##
Designer {
    D{i:0;formeditorZoom:0.8999999761581421}D{i:61;anchors_height:100;anchors_width:100}
}
##^##*/
