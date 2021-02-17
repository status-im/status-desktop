import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared"
import "../shared/status"
import "./AppLayouts"
import "./AppLayouts/Timeline"
import "./AppLayouts/Wallet"
import "./AppLayouts/Chat/components"
import "./AppLayouts/Chat/CommunityComponents"

RowLayout {
    id: appMain
    spacing: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    function getProfileImage(pubkey, isCurrentUser, useLargeImage) {
        if (isCurrentUser || (isCurrentUser === undefined && pubkey === profileModel.profile.pubKey)) {
            return profileModel.profile.thumbnailImage
        }

        const index = profileModel.contacts.list.getContactIndexByPubkey(pubkey)
        if (index === -1) {
            return
        }

        if (appSettings.onlyShowContactsProfilePics) {
            const isContact = profileModel.contacts.list.rowData(index, "isContact")
            if (isContact === "false") {
                return
            }
        }

        return profileModel.contacts.list.rowData(index, useLargeImage ? "largeImage" : "thumbnailImage")
    }

    function openPopup(popupComponent, params = {}) {
        const popup = popupComponent.createObject(appMain, params);
        popup.open()
        return popup
    }

    function getUserNickname(pubKey) {
        // Get contact nickname
        const contactList = profileModel.contacts.list
        const contactCount = contactList.rowCount()
        for (let i = 0; i < contactCount; i++) {
            if (contactList.rowData(i, 'pubKey') === pubKey) {
                return contactList.rowData(i, 'localNickname')
            }
        }
        return ""
    }


    function openLink(link) {
        if (appSettings.showBrowserSelector) {
            appMain.openPopup(chooseBrowserPopupComponent, {link: link})
        } else {
            if (appSettings.openLinksInStatus) {
                appMain.changeAppSection(Constants.browser)
                browserLayoutContainer.item.openUrlInNewTab(link)
            } else {
                Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: chooseBrowserPopupComponent
        ChooseBrowserPopup {
            onClosed: {
                destroy()
            }
        }
    }

    ToastMessage {
        id: toastMessage
    }

    // Add SenmdModal here as it is used by the Wallet as well as the Browser
    Loader {
        id: sendModal

        function open() {
            this.active = true
            this.item.open()
        }
        function closed() {
            // this.sourceComponent = undefined // kill an opened instance
            this.active = false
        }
        sourceComponent: SendModal {
            onOpened: {
                walletModel.getGasPricePredictions()
            }
            onClosed: {
                sendModal.closed()
            }
        }
    }

    Action {
        shortcut: "Ctrl+1"
        onTriggered: changeAppSection(Constants.chat)
    }
    Action {
        shortcut: "Ctrl+2"
        onTriggered: changeAppSection(Constants.browser)
    }
    Action {
        shortcut: "Ctrl+3"
        onTriggered: changeAppSection(Constants.wallet)
    }
    Action {
        shortcut: "Ctrl+4, Ctrl+,"
        onTriggered: changeAppSection(Constants.profile)
    }
    Action {
        shortcut: "Ctrl+K"
        onTriggered: {
            if (channelPicker.opened) {
                channelPicker.close()
            } else {
                channelPicker.open()
            }
        }
    }
    Component {
        id: statusIdenticonComponent
        StatusIdenticon {}
    }

    StatusInputListPopup {
        id: channelPicker
        title: qsTr("Where do you want to go?")
        showSearchBox: true
        width: 350
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        modelList: chatsModel.chats
        getText: function (modelData) {
            return modelData.name
        }
        getImageComponent: function (parent, modelData) {
            return statusIdenticonComponent.createObject(parent, {
                                                             width: channelPicker.imageWidth,
                                                             height: channelPicker.imageHeight,
                                                             chatName: modelData.name,
                                                             chatType: modelData.chatType,
                                                             identicon: modelData.identicon
                                                         });
        }
        onClicked: function (index) {
            chatsModel.setActiveChannelByIndex(index)
            appMain.changeAppSection(Constants.chat)
            channelPicker.close()
        }
    }

    function changeAppSection(section) {
        sLayout.currentIndex = Utils.getAppSectionIndex(section)
    }


    Item {
        id: leftTab
        Layout.topMargin: 50
        Layout.maximumWidth: 78
        Layout.minimumWidth: 78
        Layout.preferredWidth: 78
        Layout.fillHeight: true
        height: parent.height

        ScrollView {
            id: scrollView
            width: leftTab.width
            anchors.top: parent.top
            anchors.bottom: leftTabButtons.visible ? leftTabButtons.top : parent.bottom
            anchors.bottomMargin: tabBar.spacing
            clip: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                id: tabBar
                spacing: 12
                width: scrollView.width

                StatusIconTabButton {
                    id: chatBtn
                    icon.name: "message"
                    section: Constants.chat
                    doNotHandleClick: true
                    onClicked: {
                        chatsModel.communities.activeCommunity.active = false
                        appMain.changeAppSection(Constants.chat)
                    }

                    checked: !chatsModel.communities.activeCommunity.active  && sLayout.currentIndex === Utils.getAppSectionIndex(Constants.chat)

                    Rectangle {
                        id: chatBadge
                        visible: chatsModel.unreadMessagesCount > 0
                        anchors.top: parent.top
                        anchors.left: parent.right
                        anchors.leftMargin: -17
                        anchors.topMargin: 1
                        radius: height / 2
                        color: Style.current.blue
                        border.color: Style.current.background
                        border.width: 2
                        width: chatsModel.unreadMessagesCount < 10 ? 22 : messageCount.width + 14
                        height: 22
                        Text {
                            id: messageCount
                            font.pixelSize: chatsModel.unreadMessagesCount > 99 ? 10 : 12
                            color: Style.current.white
                            anchors.centerIn: parent
                            text: chatsModel.unreadMessagesCount > 99 ? "99+" : chatsModel.unreadMessagesCount
                        }
                    }
                }

                Loader {
                    id: communitiesListLoader
                    active: appSettings.communitiesEnabled
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: {
                        if (item && active) {
                            return item.height
                        }

                        return 0
                    }
                    sourceComponent: Component {
                        CommunityList {}
                    }
                }

                Loader {
                    active: !leftTabButtons.visible
                    width: parent.width
                    height: {
                        if (item && active) {
                            return item.height
                        }
                        return 0
                    }
                    sourceComponent: LeftTabBottomButtons {}
                }
            }
        }

        LeftTabBottomButtons {
            id: leftTabButtons
            visible: scrollView.contentHeight > leftTab.height
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.padding
        }
    }

    Rectangle {
        height: parent.height
        width: 1
        color: Style.current.border
    }

    StackLayout {
        id: sLayout
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.fillHeight: true
        currentIndex: 0
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

            if(this.children[currentIndex] === walletLayoutContainer){
                walletLayoutContainer.showSigningPhrasePopup();
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

        TimelineLayout {
            id: timelineLayoutContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
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
    D{i:0;formeditorZoom:1.75;height:770;width:1232}
}
##^##*/
