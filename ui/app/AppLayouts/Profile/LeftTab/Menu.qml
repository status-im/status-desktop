import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Rectangle {
    property alias profileCurrentIndex: profileScreenButtons.currentIndex
    readonly property int btnheight: 42
    readonly property int w: 340

    id: profileTabBar
    color: Style.current.transparent
    height: parent.height
    Layout.fillHeight: true
    Layout.fillWidth: true

    TabBar {
        id: profileScreenButtons
        width: profileTabBar.w
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
            width: profileTabBar.w
            height: 0 //profileTabBar.btnheight
            visible: false
            text: ""
            anchors.top: parent.top
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element1
                //% "ENS usernames"
                text: qsTrId("ens-usernames")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 0 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: contactsTabButton
            width: profileTabBar.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: ensTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element2
                //% "Contacts"
                text: qsTrId("contacts")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 1 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: privacyTabButton
            width: profileTabBar.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: contactsTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element3
                //% "Privacy and security"
                text: qsTrId("privacy-and-security")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 2 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: devicesTabButton
            width: profileTabBar.w
            height: profileTabBar.btnheight
            visible: true
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: privacyTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                //% "Devices"
                text: qsTrId("devices")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 3 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: syncTabButton
            width: profileTabBar.w
            height: 0 //profileTabBar.btnheight
            visible: false
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: devicesTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element4
                //% "Sync settings"
                text: qsTrId("sync-settings")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 3 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: languageTabButton
            width: profileTabBar.w
            height: 0 //profileTabBar.btnheight
            visible: false
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: syncTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element5
                //% "Language settings"
                text: qsTrId("language-settings")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 4 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: notificationsTabButton
            width: profileTabBar.w
            height: 0 //profileTabBar.btnheight
            visible: false
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: languageTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element6
                //% "Notifications settings"
                text: qsTrId("notifications-settings")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 5 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: advancedTabButton
            width: profileTabBar.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: notificationsTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element7
                //% "Advanced settings"
                text: qsTrId("advanced-settings")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 6 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: helpTabButton
            width: profileTabBar.w
            height: 0 //profileTabBar.btnheight
            text: ""
            visible: false
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: advancedTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element8
                //% "Need help?"
                text: qsTrId("need-help")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 7 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: aboutTabButton
            width: profileTabBar.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: helpTabButton.bottom
            anchors.topMargin: 0
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element9
                //% "About"
                text: qsTrId("about-app")
                anchors.left: parent.left
                anchors.leftMargin: 72
                anchors.verticalCenter: parent.verticalCenter
                font.weight: profileScreenButtons.currentIndex === 8 ? Font.Bold : Font.Medium
                font.pixelSize: 14
            }
        }

        TabButton {
            id: signoutTabButton
            width: profileTabBar.w
            height: profileTabBar.btnheight
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            background: Rectangle {
                color: Style.current.transparent
            }

            StyledText {
                id: element10
                //% "Sign out"
                text: qsTrId("sign-out")
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
