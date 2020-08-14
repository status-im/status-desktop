import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared"
import "./AppLayouts"

RowLayout {
    property var appSettings

    id: rowLayout
    Layout.fillHeight: true
    Layout.fillWidth: true

    TabBar {
        id: tabBar
        width: 78
        Layout.maximumWidth: 80
        Layout.preferredWidth: 80
        Layout.minimumWidth: 80
        currentIndex: 0
        topPadding: 57
        rightPadding: 19
        leftPadding: 19
        transformOrigin: Item.Top
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.fillHeight: true
        spacing: 5
        background: Rectangle {
            color: "#00000000"
            border.color: Style.current.border
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
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/messageActive.svg" : "img/message.svg"
            }

            Rectangle {
                visible: chatsModel.unreadMessagesCount > 0
                anchors.top: image.top
                anchors.left: image.right
                anchors.leftMargin: -10
                anchors.topMargin: -5
                radius: 9
                color: Style.current.blue
                width: chatsModel.unreadMessagesCount < 10 ? 18 : childrenRect.width + 10
                height: 18
                Text {
                    font.pixelSize: chatsModel.unreadMessagesCount > 99 ? 10 : 12
                    color: Style.current.white
                    anchors.centerIn: parent
                    text: chatsModel.unreadMessagesCount
                }
            }

        }

        TabButton {
            id: walletBtn
            enabled: isExperimental === "1"
            visible: this.enabled
            width: 40
            height: this.enabled ? 40 : 0
            text: ""
            anchors.topMargin: this.enabled ? 50 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: chatBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image1
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/walletActive.svg" : "img/wallet.svg"
            }
        }

        TabButton {
            id: profileBtn
            width: 40
            height: 40
            text: ""
            anchors.topMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: walletBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image3
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/profileActive.svg" : "img/profile.svg"
            }
        }

        TabButton {
            id: nodeBtn
            enabled: isExperimental === "1"
            visible: this.enabled
            width: 40
            height: this.enabled ? 40 : 0
            text: ""
            anchors.topMargin: this.enabled ? 50 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: profileBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image4
                height: 24
                width: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: parent.checked ? "img/nodeActive.svg" : "img/node.svg"
            }
        }
    }

    StackLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.fillHeight: true
        currentIndex: tabBar.currentIndex

        ChatLayout {
            id: chatLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
            appSettings: rowLayout.appSettings
        }

        WalletLayout {
            id: walletLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
            appSettings: rowLayout.appSettings
        }

        ProfileLayout {
            id: profileLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
            appSettings: rowLayout.appSettings
        }

        NodeLayout {
            id: nodeLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.33000001311302185;height:770;width:1232}
}
##^##*/
