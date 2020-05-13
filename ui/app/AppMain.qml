import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../imports"
import "./AppLayouts"

RowLayout {
    id: rowLayout
    Layout.fillHeight: true
    Layout.fillWidth: true

    TabBar {
        id: tabBar
        width: 80
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
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.fillHeight: true
        // Those anchors show a warning, but they are the only way to have QT Creator show correctly
        anchors.left: tabBar.right
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        currentIndex: tabBar.currentIndex

        ChatLayout {
            id: chatLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }

        WalletLayout {
            id: walletLayoutContainer
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
