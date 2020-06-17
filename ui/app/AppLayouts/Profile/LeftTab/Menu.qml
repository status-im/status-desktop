import QtGraphicalEffects 1.12
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "../../../../imports"

Rectangle {
    property alias profileCurrentIndex: profileScreenButtons.currentIndex
    readonly property int btnheight: 42

    id: profileTabBar
    color: "#ffffff"
    height: parent.height
    Layout.fillHeight: true
    Layout.fillWidth: true

    TabBar {
        id: profileScreenButtons
        width: profileInfoContainer.w
        height: parent.height
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        currentIndex: 0
        spacing: 0
        background: Rectangle {
            color: "#00000000"
        }

        TabButton {
            id: ensTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.top: parent.top
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element1
                color: "#000000"
                text: qsTr("ENS usernames")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 0 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: contactsTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: ensTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element2
                color: "#000000"
                text: qsTr("Contacts")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 1 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: privacyTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: contactsTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element3
                color: "#000000"
                text: qsTr("Privacy and security")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 2 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: syncTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: privacyTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element4
                color: "#000000"
                text: qsTr("Sync settings")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 3 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: languageTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: syncTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element5
                color: "#000000"
                text: qsTr("Language settings")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 4 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: notificationsTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: languageTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element6
                color: "#000000"
                text: qsTr("Notifications settings")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 5 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: advancedTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: notificationsTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element7
                color: "#000000"
                text: qsTr("Advanced settings")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 6 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: helpTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: advancedTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element8
                color: "#000000"
                text: qsTr("Need help?")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 7 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: aboutTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: helpTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element9
                color: "#000000"
                text: qsTr("About")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 8 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: signoutTabButton
            width: profileInfoContainer.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: aboutTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Theme.transparent
            }

            Text {
                id: element10
                color: "#000000"
                text: qsTr("Sign out")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 9 ? Font.Bold : Font.Medium
                font.pixelSize: 14

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        // profileModel.logout();
                        Qt.quit();
                    }
                }
            }
        }
    }
}
