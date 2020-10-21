import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared"
import "./AppLayouts"
import "./AppLayouts/Wallet"

RowLayout {
    id: appMain
    spacing: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    ToastMessage {
        id: toastMessage
    }

    // Add SenmdModal here as it is used by the Wallet as well as the Browser
    SendModal{
        id: sendModal
        onOpened: {
          walletModel.getGasPricePredictions()
        }
    }

    function changeAppSection(section) {
        let sectionId = -1
        switch (section) {
        case Constants.chat: sectionId = 0; break;
        case Constants.wallet: sectionId = 1; break;
        case Constants.browser: sectionId = 2; break;
        case Constants.profile: sectionId = 3; break;
        case Constants.node: sectionId = 4; break;
        case Constants.ui: sectionId = 5; break;
        }
        if (sectionId === -1) {
            throw new Exception ("Unknown section name. Check the Constants to know the available ones")
        }
        tabBar.setCurrentIndex(sectionId)
    }

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
                width: chatsModel.unreadMessagesCount < 10 ? 18 : messageCount.width + 10
                height: 18
                Text {
                    id: messageCount
                    font.pixelSize: chatsModel.unreadMessagesCount > 99 ? 10 : 12
                    color: Style.current.white
                    anchors.centerIn: parent
                    text: chatsModel.unreadMessagesCount
                }
            }

        }

        TabButton {
            id: walletBtn
            enabled: isExperimental === "1" || appSettings.walletEnabled
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
            id: browserBtn
            enabled: isExperimental === "1" || appSettings.browserEnabled
            visible: this.enabled
            width: 40
            height: this.enabled ? 40 : 0
            text: ""
            anchors.topMargin: this.enabled ? 50 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: walletBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image2
                height: 24
                width: 24
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

        TabButton {
            id: uiComponentBtn
            enabled: isExperimental === "1"
            visible: this.enabled
            width: 40
            height: this.enabled ? 40 : 0
            text: ""
            anchors.topMargin: this.enabled ? 50 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: nodeBtn.top
            background: Rectangle {
                color: Style.current.secondaryBackground
                opacity: parent.checked ? 1 : 0
                radius: 50
            }

            SVGImage {
                id: image5
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
        onCurrentIndexChanged: {
            if (typeof this.children[currentIndex].onActivated === "function") {
                this.children[currentIndex].onActivated()
            }

            if(this.children[currentIndex] === browserLayoutContainer && browserLayoutContainer.active == false){
                browserLayoutContainer.active = true;
            }
        
        }

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

        Component {
            id: browserLayoutComponent
            BrowserLayout { }
        }

        Loader {
            id: browserLayoutContainer
            sourceComponent: browserLayoutComponent
            active: false
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
            // Loaders do not have access to the context, so props need to be set
            // Adding a "_" to avoid a binding loop
            property var _chatsModel: chatsModel
            property var _walletModel: walletModel
            property var _utilsModel: utilsModel
            property var _web3Provider: web3Provider
        }

        ProfileLayout {
            id: profileLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }

        NodeLayout {
            id: nodeLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
        }

        UIComponents {
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
