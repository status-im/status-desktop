import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared"
import "../shared/status"
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

        StatusIconTabButton {
              id: chatBtn
              anchors.horizontalCenter: parent.horizontalCenter
              icon.name: "message"
              anchors.topMargin: 0

              Rectangle {
                  visible: chatsModel.unreadMessagesCount > 0
                  anchors.top: parent.top
                  anchors.left: parent.right
                  anchors.leftMargin: -10
                  anchors.topMargin: -5
                  radius: width / 2
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

        StatusIconTabButton {
              id: walletBtn
              anchors.top: chatBtn.top
              enabled: isExperimental === "1" || appSettings.walletEnabled
              icon.name: "wallet"
        }

        StatusIconTabButton {
              id: browserBtn
              anchors.top: walletBtn.top
              enabled: isExperimental === "1" || appSettings.browserEnabled
              icon.name: "compass"
        }

        StatusIconTabButton {
              id: profileBtn
              anchors.top: browserBtn.top
              icon.name: "profile"

              Rectangle {
                id: profileBadge
                visible: !profileModel.isMnemonicBackedUp && sLayout.children[sLayout.currentIndex] !== profileLayoutContainer
                anchors.top: parent.top
                anchors.left: parent.right
                anchors.leftMargin: -10
                anchors.topMargin: -5
                radius: width / 2
                color: Style.current.blue
                width: 18
                height: 18
                Text {
                    font.pixelSize: 12
                    color: Style.current.white
                    anchors.centerIn: parent
                    text: "1"
                }
            }
        }

        StatusIconTabButton {
              id: nodeBtn
              enabled: isExperimental === "1"
              anchors.top: profileBtn.top
              icon.name: "node"
        }

        StatusIconTabButton {
              id: uiComponentBtn
              enabled: isExperimental === "1"
              anchors.top: nodeBtn.top
              icon.name: "node"
        }
    }

    StackLayout {
        id: sLayout
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

            if(this.children[currentIndex] === chatLayoutContainer){
                chatLayoutContainer.chatColumn.chatMessages.chatLogView.scrollToBottom(true);
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
