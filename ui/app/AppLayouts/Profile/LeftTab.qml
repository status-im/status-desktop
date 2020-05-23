import QtGraphicalEffects 1.12
import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"

ColumnLayout {
    readonly property int w: 340
    property alias currentTab: profileScreenButtons.currentIndex

    id: profileInfoContainer
    width: w
    spacing: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 0

    RowLayout {
        id: profileHeader
        height: 240
        Layout.fillWidth: true
        width: profileInfoContainer.w

        Rectangle {
            id: profileHeaderContent
            height: parent.height
            Layout.fillWidth: true

            Item {
                id: profileImgNameContainer
                width: profileHeaderContent.width
                height: profileHeaderContent.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                Image {
                    id: profileImg
                    source: profileModel.profile.identicon
                    width: 80
                    height: 80
                    fillMode: Image.PreserveAspectCrop
                    anchors.horizontalCenter: parent.horizontalCenter

                    property bool rounded: true
                    property bool adapt: false
                    y: 78

                    layer.enabled: rounded
                    layer.effect: OpacityMask {
                        maskSource: Item {
                            width: profileImg.width
                            height: profileImg.height
                            Rectangle {
                                anchors.centerIn: parent
                                width: profileImg.adapt ? profileImg.width : Math.min(profileImg.width, profileImg.height)
                                height: profileImg.adapt ? profileImg.height : width
                                radius: Math.min(width, height)
                            }
                        }
                    }
                }

                Text {
                    id: profileName
                    text: profileModel.profile.username
                    anchors.top: profileImg.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenterOffset: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.weight: Font.Medium
                    font.pixelSize: 20
                }
            }
        }
    }

    RowLayout {
        readonly property int btnheight: 42

        id: profileTabBar
        width: profileInfoContainer.w
        height: btnheight * 10
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            id: profileTabBarBg
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
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
                        font.weight: Font.Medium
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:15;anchors_height:56}
}
##^##*/
