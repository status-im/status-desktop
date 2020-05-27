import QtGraphicalEffects 1.12
import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"
import "."

Item {
    id: profileView
    x: 0
    y: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    LeftTab {
        id: leftTab
    }

    StackLayout {
        id: profileContainer
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: leftTab.right
        anchors.leftMargin: 0
        currentIndex: leftTab.currentTab

        Item {
            id: ensContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element1
                text: qsTr("ENS usernames")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }
        }

        Item {
            id: contactsContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element2
                text: qsTr("Contacts")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Component {
                id: contactsList

                Item {
                    height: 56
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    Column {
                        Row {
                            Text {
                                text: name
                                font.weight: Font.Bold
                                font.pixelSize: 14
                            }
                        }
                        Row {
                            Text {
                                text: address
                                font.weight: Font.Bold
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }

            ListView {
              id: contactListView
              anchors.topMargin: 48
              anchors.top: element2.bottom
              anchors.fill: parent
              model: profileModel.contactList
              delegate: contactsList
            }

        }

        Item {
            id: privacyContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element3
                text: qsTr("Privacy and security settings")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }
        }

        Item {
            id: syncContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element4
                text: qsTr("Sync settings")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }


            Component {
              id: mailserversList

              RadioButton {
                text: name
                checked: index == 0 ? true: false
              }
            }

            ListView {
              id: mailServersListView
              anchors.topMargin: 48
              anchors.top: element4.bottom
              anchors.fill: parent
              model: profileModel.mailserversList
              delegate: mailserversList
            }
        }

        Item {
            id: languageContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element5
                text: qsTr("Language settings")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }
        }

        Item {
            id: notificationsContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element6
                text: qsTr("Notifications settings")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }
        }

        Item {
            id: advancedContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element7
                text: qsTr("Advanced settings")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }
        }

        Item {
            id: helpContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element8
                text: qsTr("Help menus: FAQ, Glossary, etc.")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                anchors.centerIn: parent
                text: "<a href='https://status.im/docs/FAQs.html'>Frequently asked questions</a>"
                onLinkActivated: Qt.openUrlExternally(link)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }

        Item {
            id: aboutContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element9
                text: qsTr("About the app")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }
        }

        Item {
            id: signoutContainer
            width: 200
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: element10
                text: qsTr("Sign out controls")
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: parent.top
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 20
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
