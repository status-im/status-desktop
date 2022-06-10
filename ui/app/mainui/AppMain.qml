import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import Qt.labs.qmlmodels 1.0
import Qt.labs.platform 1.1
import Qt.labs.settings 1.0

import AppLayouts.Wallet 1.0
import AppLayouts.Node 1.0
import AppLayouts.Browser 1.0
import AppLayouts.Chat 1.0
import AppLayouts.Chat.popups 1.0
import AppLayouts.Chat.views 1.0
import AppLayouts.Profile 1.0
import AppLayouts.Profile.popups 1.0
import AppLayouts.CommunitiesPortal 1.0

import utils 1.0
import shared 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1

import AppLayouts.Browser.stores 1.0 as BrowserStores

import AppLayouts.stores 1.0

Item {
    id: appMain
    anchors.fill: parent

    property alias appLayout: appLayout
    property alias dragAndDrop: dragTarget
    property RootStore rootStore: RootStore { }
    // set from main.qml
    property var sysPalette
    property var newVersionJSON: {
        try {
            return JSON.parse(rootStore.aboutModuleInst.newVersion)
        } catch (e) {
            console.error("Error parsing version data", e)
            return {}
        }
    }

    signal openContactsPopup()

    Connections {
        target: rootStore.aboutModuleInst
        onAppVersionFetched: {
            if (!newVersionJSON.available) {
                versionUpToDate.show()
            } else {
                versionWarning.show()
            }
        }
    }

    Connections {
        target: rootStore.mainModuleInst
        onDisplayUserProfile: Global.openProfilePopup(publicKey)
    }

    Connections {
        target: Global
        onOpenLinkInBrowser: {
            browserLayoutContainer.item.openUrlInNewTab(link);
        }
        onOpenChooseBrowserPopup: {
            Global.openPopup(chooseBrowserPopupComponent, {link: link});
        }
        onOpenDownloadModalRequested: {
            const downloadPage = downloadPageComponent.createObject(appMain,
                {
                    newVersionAvailable: newVersionJSON.available,
                    downloadURL: newVersionJSON.url,
                    currentVersion: rootStore.profileSectionStore.getCurrentVersion(),
                    newVersion: newVersionJSON.version
                })
            return downloadPage
        }
        onOpenProfilePopupRequested: {
            var popup = profilePopupComponent.createObject(appMain);
            if (parentPopup) {
                popup.parentPopup = parentPopup;
            }
            popup.openPopup(publicKey, state);
            Global.profilePopupOpened = true;
        }
        onOpenChangeProfilePicPopup: {
            var popup = changeProfilePicComponent.createObject(appMain);
            popup.chooseImageToCrop();
        }
        onOpenBackUpSeedPopup: {
            var popup = backupSeedModalComponent.createObject(appMain)
            popup.open()
        }
        onDisplayToastMessage: {
            appMain.rootStore.mainModuleInst.displayEphemeralNotification(title, subTitle, icon, loading, ephNotifType, url);
        }
    }

    function changeAppSectionBySectionId(sectionId) {
        mainModule.setActiveSectionById(sectionId)
    }

    function getContactListObject(dataModel) {
        // Not Refactored Yet - This should be resolved in a proper way in Chat Section Module most likely

//        const nbContacts = appMain.rootStore.contactsModuleInst.model.list.rowCount()
//        const contacts = []
//        let contact
//        for (let i = 0; i < nbContacts; i++) {
//            if (appMain.rootStore.contactsModuleInst.model.list.rowData(i, "isBlocked") === "true") {
//                continue
//            }

//            contact = {
//                name: appMain.rootStore.contactsModuleInst.model.list.rowData(i, "name"),
//                localNickname: appMain.rootStore.contactsModuleInst.model.list.rowData(i, "localNickname"),
//                pubKey: appMain.rootStore.contactsModuleInst.model.list.rowData(i, "pubKey"),
//                address: appMain.rootStore.contactsModuleInst.model.list.rowData(i, "address"),
//                identicon: appMain.rootStore.contactsModuleInst.model.list.rowData(i, "identicon"),
//                thumbnailImage: appMain.rootStore.contactsModuleInst.model.list.rowData(i, "thumbnailImage"),
//                isUser: false,
//                isContact: appMain.rootStore.contactsModuleInst.model.list.rowData(i, "isContact") !== "false"
//            }

//            contacts.push(contact)
//            if (dataModel) {
//                dataModel.append(contact);
//            }
//        }
//        return contacts

        return []
    }

    property Component backupSeedModalComponent: BackupSeedModal {
        id: backupSeedModal
        anchors.centerIn: parent
        privacyStore: appMain.rootStore.profileSectionStore.privacyStore
    }

    Component {
        id: downloadPageComponent
        DownloadPage {
            onClosed: {
                destroy();
            }
        }
    }

    StatusImageModal {
        id: imagePopup
        onClicked: {
            if (button === Qt.LeftButton) {
                imagePopup.close()
            } else if(button === Qt.RightButton) {
                contextMenu.imageSource = imagePopup.imageSource
                contextMenu.hideEmojiPicker = true
                contextMenu.isRightClickOnImage = true;
                contextMenu.show()
            }
        }
        Connections {
            target: Global
            onOpenImagePopup: {
                imagePopup.contextMenu = contextMenu
                imagePopup.openPopup(image)
            }
        }
    }

    property Component profilePopupComponent: ProfilePopup {
        id: profilePopup
        anchors.centerIn: parent
        profileStore: appMain.rootStore.profileSectionStore.profileStore
        contactsStore: appMain.rootStore.profileSectionStore.contactsStore
        onClosed: {
            if  (profilePopup.parentPopup) {
                profilePopup.parentPopup.close();
            }
            Global.profilePopupOpened = false;
            destroy();
        }
    }

    property Component changeProfilePicComponent: Component {
        ImageCropWorkflow {
            title: qsTr("Profile Picture")
            acceptButtonText: qsTr("Make this my Profile Pic")
            onImageCropped: {
                appMain.rootStore.profileSectionStore.profileStore.uploadImage(image,
                                              cropRect.x.toFixed(),
                                              cropRect.y.toFixed(),
                                              (cropRect.x + cropRect.width).toFixed(),
                                              (cropRect.y + cropRect.height).toFixed());
            }
        }
    }

    Audio {
        id: sendMessageSound
        store: rootStore
        track: Qt.resolvedUrl("../imports/assets/audio/send_message.wav")
    }

    Audio {
        id: notificationSound
        store: rootStore
        track: Qt.resolvedUrl("../imports/assets/audio/notification.wav")
    }

    Audio {
        id: errorSound
        track: Qt.resolvedUrl("../imports/assets/audio/error.mp3")
        store: rootStore
    }

    AppSearch {
        id: appSearch
        store: appMain.rootStore.appSearchStore
    }

    StatusEmojiPopup {
        id: statusEmojiPopup
        width: 360
        height: 440
    }

    StatusAppLayout {
        id: appLayout

        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        appNavBar: StatusAppNavBar {
            height: appMain.height
            communityTypeRole: "sectionType"
            communityTypeValue: Constants.appSection.community
            sectionModel: mainModule.sectionsModel

            Component.onCompleted: {
                mainModule.sectionsModel.sectionVisibilityUpdated.connect(function(){
                    triggerUpdate()
                })
            }

            property bool communityAdded: false

            onAboutToUpdateFilteredRegularModel: {
                communityAdded = false
            }

            filterRegularItem: function(item) {
                if(!item.enabled)
                    return false

                if(item.sectionType === Constants.appSection.community)
                    if(communityAdded)
                        return false
                    else
                        communityAdded = true

                return true
            }

            filterCommunityItem: function(item) {
                return item.sectionType === Constants.appSection.community
            }

            regularNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                onClicked: {
                    changeAppSectionBySectionId(model.id)
                }
            }

            communityNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                onClicked: {
                    changeAppSectionBySectionId(model.id)
                }

                popupMenu: StatusPopupMenu {
                    id: communityContextMenu

                    property var chatCommunitySectionModule

                    openHandler: function () {
                        // // we cannot return QVariant if we pass another parameter in a function call
                        // // that's why we're using it this way
                        mainModule.prepareCommunitySectionModuleForCommunityId(model.id)
                        communityContextMenu.chatCommunitySectionModule = mainModule.getCommunitySectionModule()

                    }

                    StatusMenuItem {
                        //% "Invite People"
                        text: qsTrId("invite-people")
                        icon.name: "share-ios"
                        enabled: model.canManageUsers
                        onTriggered: Global.openPopup(inviteFriendsToCommunityPopup, {
                            community: model,
                            hasAddedContacts: appMain.rootStore.hasAddedContacts,
                            communitySectionModule: communityContextMenu.chatCommunitySectionModule
                        })
                    }

                    StatusMenuItem {
                        //% "View Community"
                        text: qsTrId("view-community")
                        icon.name: "group-chat"
                        onTriggered: Global.openPopup(communityProfilePopup, {
                            store: appMain.rootStore,
                            community: model,
                            communitySectionModule: communityContextMenu.chatCommunitySectionModule
                        })
                    }

                    StatusMenuSeparator {}

                    StatusMenuItem {
                        //% "Leave Community"
                        text: qsTrId("leave-community")
                        icon.name: "arrow-right"
                        icon.width: 14
                        iconRotation: 180
                        type: StatusMenuItem.Type.Danger
                        onTriggered: communityContextMenu.chatCommunitySectionModule.leaveCommunity()
                    }
                }
            }

            navBarProfileButton: StatusNavBarTabButton {
                id: profileButton
                property bool opened: false

                name: appMain.rootStore.userProfileInst.name
                icon.source: appMain.rootStore.userProfileInst.icon
                identicon.icon.charactersLen: 2
                identicon.icon.color: Utils.colorForPubkey(appMain.rootStore.userProfileInst.pubKey)
                identicon.ringSettings.ringSpecModel: Utils.getColorHashAsJson(appMain.rootStore.userProfileInst.pubKey)

                badge.visible: true
                badge.anchors.rightMargin: 4
                badge.anchors.topMargin: 25
                badge.implicitHeight: 15
                badge.implicitWidth: 15
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusAppNavBar.backgroundColor
                badge.color: {
                    switch(appMain.rootStore.userProfileInst.currentUserStatus){
                        case Constants.currentUserStatus.automatic:
                        case Constants.currentUserStatus.alwaysOnline:
                            return Style.current.green;
                        default:
                            return Style.current.midGrey;
                    }
                }
                badge.border.width: 3
                onClicked: {
                    userStatusContextMenu.opened ?
                        userStatusContextMenu.close() :
                        userStatusContextMenu.open()
                }

                UserStatusContextMenu {
                    id: userStatusContextMenu
                    y: profileButton.y - userStatusContextMenu.height
                    store: appMain.rootStore
                }
            }
        }

        appView: ColumnLayout {
            anchors.fill: parent

            ModuleWarning {
                id: versionWarning
                width: parent.width
                height: 32
                visible: !!newVersionJSON.available
                color: Style.current.green
                btnWidth: 100
                text: qsTr("A new version of Status (%1) is available").arg(newVersionJSON.version)
                btnText: qsTr("Download")
                onClick: function(){
                    Global.openDownloadModal()
                }

                function show() {
                    versionWarning.visible = true
                }
            }

            ModuleWarning {
                id: versionUpToDate
                width: parent.width
                height: 32
                visible: false
                color: Style.current.green
                btnWidth: 100
                text: qsTr("Your version is up to date")
                btnText: qsTr("Close")

                Timer {
                    id: timer
                }
                function show() {
                    versionUpToDate.visible = true
                    timer.setTimeout(function() {
                        versionUpToDate.close()
                    }, 4000);
                }

                onClick: function(){
                    versionUpToDate.close()
                }
            }

            
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                StackLayout {
                    id: appView

                    anchors.fill: parent

                    currentIndex: {
                        if(mainModule.activeSection.sectionType === Constants.appSection.chat) {
                            return Constants.appViewStackIndex.chat
                        }
                        else if(mainModule.activeSection.sectionType === Constants.appSection.community) {

                            for(let i = this.children.length - 1; i >=0; i--)
                            {
                                var obj = this.children[i];
                                if(obj && obj.sectionId && obj.sectionId == mainModule.activeSection.id)
                                {
                                    return i
                                }
                            }

                            // Should never be here, correct index must be returned from the for loop above
                            console.error("Wrong section type: ", mainModule.activeSection.sectionType,
                                        " or section id: ", mainModule.activeSection.id)
                            return Constants.appViewStackIndex.community
                        }
                        else if(mainModule.activeSection.sectionType === Constants.appSection.communitiesPortal) {
                            return Constants.appViewStackIndex.communitiesPortal
                        }
                        else if(mainModule.activeSection.sectionType === Constants.appSection.wallet) {
                            return Constants.appViewStackIndex.wallet
                        }
                        else if(mainModule.activeSection.sectionType === Constants.appSection.browser) {
                            return Constants.appViewStackIndex.browser
                        }
                        else if(mainModule.activeSection.sectionType === Constants.appSection.profile) {
                            return Constants.appViewStackIndex.profile
                        }
                        else if(mainModule.activeSection.sectionType === Constants.appSection.node) {
                            return Constants.appViewStackIndex.node
                        }

                        // We should never end up here
                        console.error("Unknown section type")
                    }

                    onCurrentIndexChanged: {
                        var obj = this.children[currentIndex];
                        if(!obj)
                            return

                        if (obj.onActivated && typeof obj.onActivated === "function") {
                            this.children[currentIndex].onActivated()
                        }

                        if(obj === browserLayoutContainer && browserLayoutContainer.active == false){
                            browserLayoutContainer.active = true;
                        }

                        if(obj === walletLayoutContainer){
                            walletLayoutContainer.showSigningPhrasePopup();
                        }
                    }

                    // NOTE:
                    // If we ever change stack layout component order we need to updade
                    // Constants.appViewStackIndex accordingly

                    ChatLayout {
                        id: chatLayoutContainer
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.fillHeight: true

                        chatView.pinnedMessagesListPopupComponent: pinnedMessagesPopupComponent
                        chatView.emojiPopup: statusEmojiPopup

                        contactsStore: appMain.rootStore.contactStore
                        rootStore.emojiReactionsModel: appMain.rootStore.emojiReactionsModel

                        chatView.onProfileButtonClicked: {
                            Global.changeAppSectionBySectionType(Constants.appSection.profile);
                        }

                        chatView.onOpenAppSearch: {
                            appSearch.openSearchPopup()
                        }

                        Component.onCompleted: {
                            rootStore.chatCommunitySectionModule = mainModule.getChatSectionModule()
                        }
                    }

                    CommunitiesPortalLayout {
                        id: communitiesPortalLayoutContainer
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.fillHeight: true
                    }

                    WalletLayout {
                        id: walletLayoutContainer
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.fillHeight: true
                        store: appMain.rootStore
                        contactsStore: appMain.rootStore.profileSectionStore.contactsStore
                        emojiPopup: statusEmojiPopup
                        sendModal: sendModal
                    }

                    Component {
                        id: browserLayoutComponent
                        BrowserLayout {
                            globalStore: appMain.rootStore
                            sendTransactionModal: sendModal
                        }
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
                        // Not Refactored Yet
                        //                property var _chatsModel: chatsModel.messageView
                        // Not Refactored Yet
                        //                property var _walletModel: walletModel
                        // Not Refactored Yet
                        //                property var _utilsModel: utilsModel
                        property var _web3Provider: BrowserStores.Web3ProviderStore.web3ProviderInst
                    }

                    ProfileLayout {
                        id: profileLayoutContainer
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.fillHeight: true

                        store: appMain.rootStore.profileSectionStore
                        globalStore: appMain.rootStore
                        systemPalette: appMain.sysPalette
                        emojiPopup: statusEmojiPopup
                    }

                    NodeLayout {
                        id: nodeLayoutContainer
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.fillHeight: true
                    }

                    Repeater {
                        model: mainModule.sectionsModel

                        delegate: DelegateChooser {
                            id: delegateChooser
                            role: "sectionType"
                            DelegateChoice {
                                roleValue: Constants.appSection.community
                                delegate: ChatLayout {
                                    property string sectionId: model.id
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                    Layout.fillHeight: true

                                    chatView.pinnedMessagesListPopupComponent: pinnedMessagesPopupComponent
                                    chatView.emojiPopup: statusEmojiPopup

                                    contactsStore: appMain.rootStore.contactStore
                                    rootStore.emojiReactionsModel: appMain.rootStore.emojiReactionsModel

                                    chatView.onProfileButtonClicked: {
                                        Global.changeAppSectionBySectionType(Constants.appSection.profile);
                                    }

                                    chatView.onOpenAppSearch: {
                                        appSearch.openSearchPopup()
                                    }

                                    Component.onCompleted: {
                                        // we cannot return QVariant if we pass another parameter in a function call
                                        // that's why we're using it this way
                                        mainModule.prepareCommunitySectionModuleForCommunityId(model.id)
                                        rootStore.chatCommunitySectionModule = mainModule.getCommunitySectionModule()
                                    }
                                }
                            }
                        }
                    }
                }

                CreateChatView {
                    property bool opened: false

                    id: createChatView
                    rootStore: chatLayoutContainer.rootStore
                    emojiPopup: statusEmojiPopup
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.rightMargin: 8
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: chatLayoutContainer.chatView.width - chatLayoutContainer.chatView.leftPanel.width - anchors.rightMargin - anchors.leftMargin
                    visible: createChatView.opened
                    
                    Connections {
                        target: Global
                        onOpenCreateChatView: {
                            createChatView.opened = true
                        }
                        onCloseCreateChatView: {
                            createChatView.opened = false
                        }
                    }
                    Connections {
                        target: mainModule
                        onActiveSectionChanged: {
                            Global.closeCreateChatView()
                        }
                    }
                }
            }

            Connections {
                target: rootStore.mainModuleInst
                onMailserverNotWorking: {
                    if (!appLayout.mailserverNotWorkingPopup) {
                        appLayout.mailserverNotWorkingPopup = Global.openPopup(mailserverNotWorkingPopupComponent);
                    }
                }
            }
        } // ColumnLayout
        property var mailserverNotWorkingPopup: null

        Component {
            id: mailserverNotWorkingPopupComponent
            StatusModal {
                id: msNotWorkingPopup
                anchors.centerIn: parent
                header.title: qsTr("Can not connect to mailserver")
                onClosed: {
                    appLayout.mailserverNotWorkingPopup = null
                    destroy()
                }

                contentItem: Item {
                    width: msNotWorkingPopup.width
                    implicitHeight: 100

                    StatusBaseText {
                      text: qsTr("The mailserver you're connecting to is unavailable.")
                      color: Theme.palette.directColor1
                      anchors.centerIn: parent
                    }
                }

                rightButtons: [
                    StatusButton {
                      text: qsTr("Pick another")
                      onClicked: {
                          Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.messaging)
                          msNotWorkingPopup.close()
                      }
                    },
                    StatusButton {
                      text: qsTr("Retry")
                      onClicked: {
                        // Retrying already happens automatically, so doing nothing
                        // here is the same as retrying...
                        msNotWorkingPopup.close()
                      }
                    }
                ]
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

        Component {
            id: inviteFriendsToCommunityPopup
            InviteFriendsToCommunityPopup {
                anchors.centerIn: parent
                rootStore: appMain.rootStore
                contactsStore: appMain.rootStore.contactStore
                onClosed: {
                    destroy()
                }

                onSendInvites: {
                    const error = communitySectionModule.inviteUsersToCommunity(JSON.stringify(pubKeys))
                    processInviteResult(error)
                }
            }
        }

        Component {
            id: communityProfilePopup

            CommunityProfilePopup {
                anchors.centerIn: parent
                contactsStore: appMain.rootStore.contactStore
                hasAddedContacts: appMain.rootStore.hasAddedContacts

                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: pinnedMessagesPopupComponent
            PinnedMessagesPopup {
                id: pinnedMessagesPopup
                emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                onClosed: destroy()
            }
        }

        Component {
            id: genericConfirmationDialog
            ConfirmationDialog {
                onClosed: {
                    destroy()
                }
            }
        }

        DropArea {
            id: dragTarget

            signal droppedOnValidScreen(var drop)
            property alias droppedUrls: rptDraggedPreviews.model
            property var chatCommunitySectionModule: chatLayoutContainer.rootStore.chatCommunitySectionModule
            property int activeChatType: chatCommunitySectionModule && chatCommunitySectionModule.activeItem.type
            property bool enabled: !drag.source && !!loader.item && !!loader.item.appLayout
                                && (
                                    // in chat view
                                    (mainModule.activeSection.sectionType === Constants.appSection.chat &&
                                    (
                                        // in a one-to-one chat
                                        activeChatType === Constants.chatType.oneToOne ||
                                        // in a private group chat
                                        activeChatType === Constants.chatType.privateGroupChat
                                        )
                                    ) ||
                                    // In community section
                                    mainModule.activeSection.sectionType === Constants.appSection.community
                                    )

            width: appMain.width
            height: appMain.height

            function cleanup() {
                rptDraggedPreviews.model = []
            }

            onDropped: (drop) => {
                        if (enabled) {
                            droppedOnValidScreen(drop)
                        } else {
                            drop.accepted = false
                        }
                        cleanup()
                    }
            onEntered: {
                if (!enabled || !!drag.source) {
                    drag.accepted = false
                    return
                }

                // needed because drag.urls is not a normal js array
                rptDraggedPreviews.model = drag.urls.filter(img => Utils.hasDragNDropImageExtension(img))
            }
            onPositionChanged: {
                rptDraggedPreviews.x = drag.x
                rptDraggedPreviews.y = drag.y
            }
            onExited: cleanup()
            Rectangle {
                id: dropRectangle

                width: parent.width
                height: parent.height
                color: Style.current.transparent
                opacity: 0.8

                states: [
                    State {
                        when: dragTarget.enabled && dragTarget.containsDrag
                        PropertyChanges {
                            target: dropRectangle
                            color: Style.current.background
                        }
                    }
                ]
            }
            Repeater {
                id: rptDraggedPreviews

                Image {
                    source: modelData
                    width: 80
                    height: 80
                    sourceSize.width: 160
                    sourceSize.height: 160
                    fillMode: Image.PreserveAspectFit
                    x: index * 10 + rptDraggedPreviews.x
                    y: index * 10 + rptDraggedPreviews.y
                    z: 1
                }
            }
        }

        // Add SendModal here as it is used by the Wallet as well as the Browser
        Loader {
            id: sendModal
            active: false

            function open() {
                this.active = true
                this.item.open()
            }
            function closed() {
                // this.sourceComponent = undefined // kill an opened instance
                this.active = false
            }
            property var selectedAccount
            sourceComponent: SendModal {
                anchors.centerIn: parent
                store: appMain.rootStore
                contactsStore: appMain.rootStore.profileSectionStore.contactsStore
                onClosed: {
                    sendModal.closed()
                }
            }
            onLoaded: {
                if (!!sendModal.selectedAccount) {
                    item.selectedAccount = sendModal.selectedAccount
                }
            }
        }

        Action {
            shortcut: "Ctrl+1"
            onTriggered: Global.changeAppSectionBySectionType(Constants.appSection.chat)
        }
        Action {
            shortcut: "Ctrl+2"
            onTriggered: Global.changeAppSectionBySectionType(Constants.appSection.browser)
        }
        Action {
            shortcut: "Ctrl+3"
            onTriggered: Global.changeAppSectionBySectionType(Constants.appSection.wallet)
        }
        Action {
            shortcut: "Ctrl+4, Ctrl+,"
            onTriggered: Global.changeAppSectionBySectionType(Constants.appSection.profile)
        }
        Action {
            shortcut: "Ctrl+K"
            onTriggered: {
                // FIXME the focus is no longer on the AppMain when the popup is opened, so this does not work to close
                if (channelPicker.opened) {
                    channelPicker.close()
                } else {
                    channelPicker.open()
                }
            }
        }
        Action {
            shortcut: "Ctrl+F"
            onTriggered: {
                // FIXME the focus is no longer on the AppMain when the popup is opened, so this does not work to close
                if (appSearch.opened) {
                    appSearch.closeSearchPopup()
                } else {
                    appSearch.openSearchPopup()
                }
            }
        }

        StatusSearchListPopup {
            id: channelPicker

            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2

            searchBoxPlaceholder: qsTr("Where do you want to go?")
            model: rootStore.chatSearchModel
            delegate: StatusListItem {
                property var modelData
                property bool isCurrentItem: true
                function filterAccepts(searchText) {
                    return title.includes(searchText)
                }

                title: modelData ? modelData.name : ""
                label: modelData? modelData.sectionName : ""
                highlighted: isCurrentItem
                sensor.hoverEnabled: false
                statusListItemIcon {
                    name: modelData ? modelData.name : ""
                    active: true
                }
                icon {
                    width: image.width
                    height: image.height
                    color: modelData ? modelData.color : ""
                }
                image {
                    source: modelData ? modelData.icon : ""
                }
            }

            onAboutToShow: rootStore.rebuildChatSearchModel()
            onSelected: {
                rootStore.setActiveSectionChat(modelData.sectionId, modelData.chatId)
                close()
            }
        }
    }

    ListView {
        id: toastArea
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        spacing: 8
        verticalLayoutDirection: ListView.BottomToTop
        model: appMain.rootStore.mainModuleInst.ephemeralNotificationModel
        delegate: StatusToastMessage {
            primaryText: model.title
            secondaryText: model.subTitle
            icon.name: model.icon
            loading: model.loading
            type: model.ephNotifType
            linkUrl: model.url
            duration: model.durationInMs
            onLinkActivated: {
                Qt.openUrlExternally(link);
            }
            onClose: {
                appMain.rootStore.mainModuleInst.removeEphemeralNotification(model.id)
            }
        }
    }

    Component.onCompleted: {
        Global.appMain = this;
        const whitelist = appMain.rootStore.messagingStore.getLinkPreviewWhitelist()
        try {
            const whiteListedSites = JSON.parse(whitelist)
            let settingsUpdated = false

            // Add Status links to whitelist
            whiteListedSites.push({title: "Status", address: Constants.deepLinkPrefix, imageSite: false})
            whiteListedSites.push({title: "Status", address: Constants.joinStatusLink, imageSite: false})
            let settings = localAccountSensitiveSettings.whitelistedUnfurlingSites

            if (!settings) {
                settings = {}
            }

            // Set Status links as true. We intercept thoseURLs so it is privacy-safe
            if (!settings[Constants.deepLinkPrefix] || !settings[Constants.joinStatusLink]) {
                settings[Constants.deepLinkPrefix] = true
                settings[Constants.joinStatusLink] = true
                settingsUpdated = true
            }

            const whitelistedHostnames = []

            // Add whitelisted sites in to app settings that are not already there
            whiteListedSites.forEach(site => {
                                        if (!settings.hasOwnProperty(site.address))  {
                                            settings[site.address] = false
                                            settingsUpdated = true
                                        }
                                        whitelistedHostnames.push(site.address)
                                    })
            // Remove any whitelisted sites from app settings that don't exist in the
            // whitelist from status-go
            Object.keys(settings).forEach(settingsHostname => {
                if (!whitelistedHostnames.includes(settingsHostname)) {
                    delete settings[settingsHostname]
                    settingsUpdated = true
                }
            })
            if (settingsUpdated) {
                localAccountSensitiveSettings.whitelistedUnfurlingSites = settings
            }
        } catch (e) {
            console.error('Could not parse the whitelist for sites', e)
        }
        Global.settingsHasLoaded();
        Global.errorSound = errorSound;
    }
}
