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
                                anchors.leftMargin: 16

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
                                    anchors.leftMargin: 10
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
                                   anchors.rightMargin: 16
                                   anchors.top: applicationWindow.top
                                   anchors.topMargin: 0
                                   anchors.left: parent.left
                                   anchors.leftMargin: 16
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
                                       anchors.leftMargin: 16
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
                                       anchors.leftMargin: 16
                                       anchors.top: parent.top
                                       anchors.topMargin: 10
                                       color: "black"
                                   }
                                   Text {
                                       id: lastChatMessage
                                       text: "Chatting blah blah..."
                                       anchors.bottom: parent.bottom
                                       anchors.bottomMargin: 10
                                       font.pixelSize: 15
                                       anchors.left: contactImage.right
                                       anchors.leftMargin: 16
                                       color: Theme.darkGrey
                                   }
                                   Text {
                                       id: contactTime
                                       text: "12:22 AM"
                                       anchors.right: parent.right
                                       anchors.rightMargin: 16
                                       anchors.top: parent.top
                                       anchors.topMargin: 10
                                       font.pixelSize: 11
                                       color: Theme.darkGrey
                                   }
                                   Rectangle {
                                       id: contactNumberChatsCircle
                                       width: 22
                                       height: 22
                                       radius: 50
                                       anchors.bottom: parent.bottom
                                       anchors.bottomMargin: 10
                                       anchors.right: parent.right
                                       anchors.rightMargin: 16
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
                            Layout.fillHeight: true
                            TextArea { id: callResult; Layout.fillWidth: true; text: logic.callResult; readOnly: true }
                        }

                        RowLayout {
                            Layout.bottomMargin: 20
                            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                            transformOrigin: Item.Bottom
                            Label { text: "data2" }
                            TextField { id: txtData; Layout.fillWidth: true; text: "" }
                            Button {
                                text: "Send"
                                onClicked: logic.onSend(txtData.text)
                                enabled: txtData.text !== ""
                            }
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
    D{i:9;anchors_height:40;anchors_width:40}
}
##^##*/
