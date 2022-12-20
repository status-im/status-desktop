import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import Qt.labs.qmlmodels 1.0
import Qt.labs.platform 1.1
import Qt.labs.settings 1.0
import QtQml.Models 2.14

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
import shared.popups.keycard 1.0
import shared.status 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core 0.1

import AppLayouts.Browser.stores 1.0 as BrowserStores
import AppLayouts.stores 1.0

import SortFilterProxyModel 0.2

import "popups"
import "panels"
import "activitycenter/popups"
import "activitycenter/stores"

Item {
    id: appMain

    property alias appLayout: appLayout
    property RootStore rootStore: RootStore {}
    property ActivityCenterStore activityCenterStore: ActivityCenterStore {}
    // set from main.qml
    property var sysPalette

    signal closeProfilePopup()

    Connections {
        target: rootStore.mainModuleInst

        onDisplayUserProfile: Global.openProfilePopup(publicKey)

        onDisplayKeycardSharedModuleFlow: {
            keycardPopup.active = true
        }

        onDestroyKeycardSharedModuleFlow: {
            keycardPopup.active = false
        }

        function onMailserverNotWorking() {
            Global.openPopup(mailserverNotWorkingPopupComponent)
        }

        function onActiveSectionChanged() {
            createChatView.opened = false
        }
    }

    Popups {
        rootStore: appMain.rootStore

        Component.onCompleted: {
            Global.openSendIDRequestPopup.connect(openSendIDRequestPopup)
            Global.openOutgoingIDRequestPopup.connect(openOutgoingIDRequestPopup)
            Global.openIncomingIDRequestPopup.connect(openIncomingIDRequestPopup)
            Global.openInviteFriendsToCommunityPopup.connect(openInviteFriendsToCommunityPopup)
            Global.openContactRequestPopup.connect(openContactRequestPopup)
        }
    }

    Connections {
        target: Global
        onOpenLinkInBrowser: {
            if (!browserLayoutContainer.active)
                browserLayoutContainer.active = true;
            browserLayoutContainer.item.openUrlInNewTab(link);
        }
        onOpenChooseBrowserPopup: {
            Global.openPopup(chooseBrowserPopupComponent, {link: link});
        }
        onOpenDownloadModalRequested: {
            const downloadPage = downloadPageComponent.createObject(appMain,
                {
                    newVersionAvailable: available,
                    downloadURL: url,
                    currentVersion: rootStore.profileSectionStore.getCurrentVersion(),
                    newVersion: version
                })
            return downloadPage
        }

        onOpenImagePopup: {
            var popup = imagePopupComponent.createObject(appMain)
            popup.contextMenu = contextMenu
            popup.openPopup(image)
        }

        onOpenCreateChatView: {
            createChatView.opened = true
        }

        onCloseCreateChatView: {
            createChatView.opened = false
        }

        onOpenProfilePopupRequested: {
            if (Global.profilePopupOpened) {
                appMain.closeProfilePopup()
            }
            Global.openPopup(profilePopupComponent, {publicKey: publicKey, parentPopup: parentPopup})
            Global.profilePopupOpened = true
        }
        onOpenNicknamePopupRequested: {
            Global.openPopup(nicknamePopupComponent, {publicKey: publicKey, nickname: nickname, "header.subTitle": subtitle})
        }
        onBlockContactRequested: {
            Global.openPopup(blockContactConfirmationComponent, {contactName: contactName, contactAddress: publicKey})
        }
        onUnblockContactRequested: {
            Global.openPopup(unblockContactConfirmationComponent, {contactName: contactName, contactAddress: publicKey})
        }

        onOpenActivityCenterPopupRequested: {
            Global.openPopup(activityCenterPopupComponent)
        }

        onOpenChangeProfilePicPopup: {
            var popup = changeProfilePicComponent.createObject(appMain, {callback: cb});
            popup.chooseImageToCrop();
        }
        onOpenBackUpSeedPopup: Global.openPopup(backupSeedModalComponent)
        onDisplayToastMessage: {
            appMain.rootStore.mainModuleInst.displayEphemeralNotification(title, subTitle, icon, loading, ephNotifType, url);
        }
        onOpenEditDisplayNamePopup: Global.openPopup(displayNamePopupComponent)

        onOpenPopupRequested: {
            const popup = popupComponent.createObject(appMain, params);
            popup.open();
            return popup;
        }

        onOpenLink: {
            // Qt sometimes inserts random HTML tags; and this will break on invalid URL inside QDesktopServices::openUrl(link)
            link = appMain.rootStore.plainText(link);
            if (appMain.rootStore.showBrowserSelector) {
                Global.openChooseBrowserPopup(link);
            } else {
                if (appMain.rootStore.openLinksInStatus) {
                    Global.changeAppSectionBySectionType(Constants.appSection.browser);
                    Global.openLinkInBrowser(link);
                } else {
                    Qt.openUrlExternally(link);
                }
            }
        }

        onSetNthEnabledSectionActive: {
            if(!appMain.rootStore.mainModuleInst)
                return
            appMain.rootStore.mainModuleInst.setNthEnabledSectionActive(nthSection)
        }

        onAppSectionBySectionTypeChanged: {
            if(!appMain.rootStore.mainModuleInst)
                return

            appMain.rootStore.mainModuleInst.setActiveSectionBySectionType(sectionType)
            if (sectionType === Constants.appSection.profile) {
                Global.settingsSubsection = subsection;
            }
        }
    }

    function changeAppSectionBySectionId(sectionId) {
        appMain.rootStore.mainModuleInst.setActiveSectionById(sectionId)
    }

    Component {
        id: backupSeedModalComponent
        BackupSeedModal {
            anchors.centerIn: parent
            privacyStore: appMain.rootStore.profileSectionStore.privacyStore
            onClosed: destroy()
        }
    }

    Component {
        id: displayNamePopupComponent
        DisplayNamePopup {
            anchors.centerIn: parent
            profileStore: appMain.rootStore.profileSectionStore.profileStore
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: downloadPageComponent
        DownloadPage {
            onClosed: {
                destroy();
            }
        }
    }

    Component {
        id: imagePopupComponent
        StatusImageModal {
            id: imagePopup
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    imagePopup.close()
                } else if(mouse.button === Qt.RightButton) {
                    contextMenu.imageSource = imagePopup.imageSource
                    contextMenu.hideEmojiPicker = true
                    contextMenu.isRightClickOnImage = true
                    contextMenu.parent = imagePopup.contentItem
                    contextMenu.show()
                }
            }
            onClosed: destroy()
        }
    }

    Component {
        id: profilePopupComponent
        ProfileDialog {
            id: profilePopup
            profileStore: appMain.rootStore.profileSectionStore.profileStore
            contactsStore: appMain.rootStore.profileSectionStore.contactsStore

            onClosed: {
                if (profilePopup.parentPopup) {
                    profilePopup.parentPopup.close()
                }
                Global.profilePopupOpened = false
                destroy()
            }

            Component.onCompleted: {
                appMain.closeProfilePopup.connect(profilePopup.close)
            }
        }
    }

    Component {
        id: changeProfilePicComponent
        ImageCropWorkflow {
            title: qsTr("Profile Picture")
            acceptButtonText: qsTr("Make this my Profile Pic")
            onImageCropped: {
                if (callback) {
                    callback(image,
                             cropRect.x.toFixed(),
                             cropRect.y.toFixed(),
                             (cropRect.x + cropRect.width).toFixed(),
                             (cropRect.y + cropRect.height).toFixed())
                    return
                }

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
        source: "qrc:/imports/assets/audio/send_message.wav"
        Component.onCompleted: {
            Global.sendMessageSound = this;
        }
    }

    Audio {
        id: notificationSound
        store: rootStore
        source: "qrc:/imports/assets/audio/notification.wav"
        Component.onCompleted: {
            Global.notificationSound = this;
        }
    }

    Audio {
        id: errorSound
        source: "qrc:/imports/assets/audio/error.mp3"
        store: rootStore
        Component.onCompleted: {
            Global.errorSound = this;
        }
    }

    Loader {
        id: appSearch
        active: false
        asynchronous: true

        function openSearchPopup() {
            if (!active)
                active = true
            item.openSearchPopup()
        }

        function closeSearchPopup() {
            if (item)
                item.closeSearchPopup()

            active = false
        }

        sourceComponent: AppSearch {
            store: appMain.rootStore.appSearchStore
            onClosed: appSearch.active = false
        }
    }

    StatusEmojiPopup {
        id: statusEmojiPopup
        width: 360
        height: 440
    }

    StatusStickersPopup {
        id: statusStickersPopup
        store: chatLayoutContainer.rootStore
    }

    StatusMainLayout {
        id: appLayout

        anchors.fill: parent

        leftPanel: StatusAppNavBar {
            chatItemsModel: SortFilterProxyModel {
                sourceModel: appMain.rootStore.mainModuleInst.sectionsModel
                filters: [
                    ValueFilter {
                        roleName: "sectionType"
                        value: Constants.appSection.chat
                    },
                    ValueFilter {
                        roleName: "enabled"
                        value: true
                    }
                ]
            }
            chatItemDelegate: navbarButton

            communityItemsModel: SortFilterProxyModel {
                sourceModel: appMain.rootStore.mainModuleInst.sectionsModel
                filters: [
                    ValueFilter {
                        roleName: "sectionType"
                        value: Constants.appSection.community
                    },
                    ValueFilter {
                        roleName: "enabled"
                        value: true
                    }
                ]
            }
            communityItemDelegate: StatusNavBarTabButton {
                objectName: "CommunityNavBarButton"
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                identicon.asset.color: (hovered || identicon.highlighted || checked) ? model.color : icon.color
                tooltip.text: model.name
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                onClicked: {
                    changeAppSectionBySectionId(model.id)
                }

                popupMenu: StatusMenu {
                    id: communityContextMenu

                    property var chatCommunitySectionModule

                    openHandler: function () {
                        // // we cannot return QVariant if we pass another parameter in a function call
                        // // that's why we're using it this way
                        appMain.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(model.id)
                        communityContextMenu.chatCommunitySectionModule = appMain.rootStore.mainModuleInst.getCommunitySectionModule()

                    }

                    StatusAction {
                        text: qsTr("Invite People")
                        icon.name: "share-ios"
                        enabled: model.canManageUsers
                        onTriggered: {
                            Global.openInviteFriendsToCommunityPopup(model,
                                                                     communityContextMenu.chatCommunitySectionModule,
                                                                     null)
                        }
                    }

                    StatusAction {
                        text: qsTr("View Community")
                        icon.name: "group-chat"
                        onTriggered: Global.openPopup(communityProfilePopup, {
                            store: appMain.rootStore,
                            community: model,
                            communitySectionModule: communityContextMenu.chatCommunitySectionModule
                        })
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: qsTr("Leave Community")
                        icon.name: "arrow-left"
                        type: StatusAction.Type.Danger
                        onTriggered: communityContextMenu.chatCommunitySectionModule.leaveCommunity()
                    }
                }
            }

            regularItemsModel: SortFilterProxyModel {
                sourceModel: appMain.rootStore.mainModuleInst.sectionsModel
                filters: [
                    RangeFilter {
                        roleName: "sectionType"
                        minimumValue: Constants.appSection.wallet
                        maximumValue: Constants.appSection.communitiesPortal
                    },
                    ValueFilter {
                        roleName: "enabled"
                        value: true
                    }
                ]
            }
            regularItemDelegate: navbarButton

            delegateHeight: 40

            profileComponent: StatusNavBarTabButton {
                id: profileButton
                objectName: "statusProfileNavBarTabButton"
                property bool opened: false

                name: appMain.rootStore.userProfileInst.name
                icon.source: appMain.rootStore.userProfileInst.icon
                implicitWidth: 32
                implicitHeight: 32
                identicon.asset.width: width
                identicon.asset.height: height
                identicon.asset.charactersLen: 2
                identicon.asset.color: Utils.colorForPubkey(appMain.rootStore.userProfileInst.pubKey)
                identicon.ringSettings.ringSpecModel: Utils.getColorHashAsJson(appMain.rootStore.userProfileInst.pubKey,
                                                                               appMain.rootStore.userProfileInst.preferredName)

                badge.visible: true
                badge.anchors {
                    left: undefined
                    top: undefined
                    right: profileButton.right
                    bottom: profileButton.bottom
                    margins: 0
                    rightMargin: -badge.border.width
                    bottomMargin: -badge.border.width
                }
                badge.implicitHeight: 12
                badge.implicitWidth: 12
                badge.border.width: 2
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

                onClicked: userStatusContextMenu.opened ? userStatusContextMenu.close() : userStatusContextMenu.open()

                UserStatusContextMenu {
                    id: userStatusContextMenu
                    y: profileButton.y - userStatusContextMenu.height + profileButton.height
                    x: profileButton.x + profileButton.width + 5
                    store: appMain.rootStore
                }
            }

            Component {
                id: navbarButton
                StatusNavBarTabButton {
                    id: navbar
                    objectName: model.name + "-navbar"
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: model.icon.length > 0? "" : model.name
                    icon.name: model.icon
                    icon.source: model.image
                    tooltip.text: Utils.translatedSectionName(model.sectionType, model.name)
                    checked: model.active
                    badge.value: model.notificationsCount
                    badge.visible: model.hasNotification
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                    badge.border.width: 2
                    onClicked: {
                        changeAppSectionBySectionId(model.id)
                    }
                }
            }
        }

        rightPanel: ColumnLayout {
            spacing: 0
            objectName: "mainRightView"

            ColumnLayout {
                id: bannersLayout

                property var updateBanner: null
                property var connectedBanner: null
                readonly property bool isConnected: appMain.rootStore.mainModuleInst.isOnline

                function processUpdateAvailable() {
                    if (!updateBanner)
                        updateBanner = updateBannerComponent.createObject(this)
                }

                function processConnected() {
                    if (!connectedBanner)
                        connectedBanner = connectedBannerComponent.createObject(this)
                }

                Layout.fillWidth: true
                Layout.maximumHeight: implicitHeight
                spacing: 1

                onIsConnectedChanged: {
                    processConnected()
                }

                Connections {
                    target: rootStore.aboutModuleInst
                    onAppVersionFetched: {
                        rootStore.setLatestVersionInfo(available, version, url);
                        bannersLayout.processUpdateAvailable()
                    }
                }

                ModuleWarning {
                    id: testnetBanner
                    objectName: "testnetBanner"
                    Layout.fillWidth: true
                    text: qsTr("Testnet mode is enabled. All balances, transactions and dApp interactions will be on testnets.")
                    buttonText: qsTr("Turn off")
                    type: ModuleWarning.Danger
                    active: appMain.rootStore.profileSectionStore.walletStore.areTestNetworksEnabled

                    onClicked: {
                        testnetBannerDialog.open()
                    }

                    onCloseClicked: {
                        testnetBannerDialog.open()
                    }

                    StatusDialog {
                        id: testnetBannerDialog

                        width: 400
                        title: qsTr("Turn off Testnet mode")

                        StatusBaseText {
                            anchors.fill: parent
                            text: qsTr("Closing this banner will turn off Testnet mode.\nAll future transactions will be on mainnet or other active networks.")
                            font.pixelSize: 15
                            wrapMode: Text.WordWrap
                        }

                        footer: StatusDialogFooter {
                            rightButtons: ObjectModel {
                                StatusButton {
                                    type: StatusButton.Danger
                                    text: qsTr("Turn off Testnet")
                                    onClicked: {
                                        appMain.rootStore.profileSectionStore.walletStore.toggleTestNetworksEnabled()
                                        testnetBannerDialog.close()
                                    }
                                }
                            }
                        }
                    }
                }

                ModuleWarning {
                    id: secureYourSeedPhrase
                    objectName: "secureYourSeedPhraseBanner"
                    Layout.fillWidth: true
                    active: !appMain.rootStore.profileSectionStore.profileStore.userDeclinedBackupBanner
                              && !appMain.rootStore.profileSectionStore.profileStore.privacyStore.mnemonicBackedUp
                    type: ModuleWarning.Danger
                    text: qsTr("Secure your seed phrase")
                    buttonText: qsTr("Back up now")

                    onClicked: {
                        Global.openBackUpSeedPopup();
                    }

                    onCloseClicked: {
                        appMain.rootStore.profileSectionStore.profileStore.userDeclinedBackupBanner = true
                    }
                }


                ModuleWarning {
                    Layout.fillWidth: true
                    readonly property int progress: communitiesPortalLayoutContainer.communitiesStore.discordImportProgress
                    readonly property bool inProgress: (progress > 0 && progress < 100) || communitiesPortalLayoutContainer.communitiesStore.discordImportInProgress
                    readonly property bool finished: progress >= 100
                    readonly property bool cancelled: communitiesPortalLayoutContainer.communitiesStore.discordImportCancelled
                    readonly property bool stopped: communitiesPortalLayoutContainer.communitiesStore.discordImportProgressStopped
                    readonly property int errors: communitiesPortalLayoutContainer.communitiesStore.discordImportErrorsCount
                    readonly property int warnings: communitiesPortalLayoutContainer.communitiesStore.discordImportWarningsCount
                    readonly property string communityId: communitiesPortalLayoutContainer.communitiesStore.discordImportCommunityId
                    readonly property string communityName: communitiesPortalLayoutContainer.communitiesStore.discordImportCommunityName

                    active: !cancelled && (inProgress || finished || stopped)
                    type: errors ? ModuleWarning.Type.Danger : ModuleWarning.Type.Success
                    text: {
                        if (finished || stopped) {
                            if (errors)
                                return qsTr("The import of ‘%1’ from Discord to Status was stopped: <a href='#'>Critical issues found</a>").arg(communityName)

                            let result = qsTr("‘%1’ was successfully imported from Discord to Status").arg(communityName) + "  <a href='#'>"
                            if (warnings)
                                result += qsTr("Details (%1)").arg(qsTr("%n issue(s)", "", warnings))
                            else
                                result += qsTr("Details")
                            result += "</a>"
                            return result
                        }
                        if (inProgress) {
                            let result = qsTr("Importing ‘%1’ from Discord to Status").arg(communityName) + "  <a href='#'>"
                            if (warnings)
                                result += qsTr("Check progress (%1)").arg(qsTr("%n issue(s)", "", warnings))
                            else
                                result += qsTr("Check progress")
                            result += "</a>"
                            return result
                        }

                        return ""
                    }
                    onLinkActivated: Global.openPopup(communitiesPortalLayoutContainer.discordImportProgressPopup)
                    progressValue: progress
                    closeBtnVisible: finished || stopped
                    buttonText: finished && !errors ? qsTr("Visit your Community") : ""
                    onClicked: function() {
                        communitiesPortalLayoutContainer.communitiesStore.setActiveCommunity(communityId)
                    }
                    onCloseClicked: {
                        hide();
                    }
                }

                
                ModuleWarning {
                    id: downloadingArchivesBanner
                    Layout.fillWidth: true
                    active: communitiesPortalLayoutContainer.communitiesStore.downloadingCommunityHistoryArchives
                    type: ModuleWarning.Danger
                    text: qsTr("Downloading message history archives, DO NOT CLOSE THE APP until this banner disappears.")
                    closeBtnVisible: false
                }

                Component {
                    id: connectedBannerComponent

                    ModuleWarning {
                        id: connectedBanner
                        property bool isConnected: true

                        objectName: "connectionInfoBanner"
                        Layout.fillWidth: true
                        text: isConnected ? qsTr("Connected") : qsTr("Disconnected")
                        type: isConnected ? ModuleWarning.Success : ModuleWarning.Danger

                        function updateState() {
                            if (isConnected)
                                showFor()
                            else
                                show();
                        }

                        Component.onCompleted: {
                            connectedBanner.isConnected = Qt.binding(() => bannersLayout.isConnected);
                        }
                        onIsConnectedChanged: {
                            updateState();
                        }
                        onCloseClicked: {
                            hide();
                        }
                        onHideStarted: {
                            bannersLayout.connectedBanner = null
                        }
                        onHideFinished: {
                            destroy()
                        }
                    }
                }

                Component {
                    id: updateBannerComponent

                    ModuleWarning {
                        readonly property string version: appMain.rootStore.latestVersion
                        readonly property bool updateAvailable: appMain.rootStore.newVersionAvailable

                        objectName: "appVersionUpdateBanner"
                        Layout.fillWidth: true
                        type: ModuleWarning.Success
                        text: updateAvailable ? qsTr("A new version of Status (%1) is available").arg(version)
                                              : qsTr("Your version is up to date")

                        buttonText: updateAvailable ? qsTr("Update")
                                                    : qsTr("Close")

                        function updateState() {
                            if (updateAvailable)
                                show()
                            else
                                showFor(5000)
                        }

                        Component.onCompleted: {
                            updateState()
                        }
                        onUpdateAvailableChanged: {
                            updateState();
                        }
                        onClicked: {
                            if (updateAvailable)
                                Global.openDownloadModal(appMain.rootStore.newVersionAvailable,
                                                         appMain.rootStore.latestVersion,
                                                         appMain.rootStore.downloadURL)
                            else
                                close()
                        }
                        onCloseClicked: {
                            if (updateAvailable)
                                appMain.rootStore.resetLastVersion();
                            hide()
                        }
                        onHideStarted: {
                            bannersLayout.updateBanner = null
                        }
                        onHideFinished: {
                            destroy()
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                StackLayout {
                    id: appView
                    anchors.fill: parent

                    currentIndex: {
                        const activeSectionType = appMain.rootStore.mainModuleInst.activeSection.sectionType

                        if (activeSectionType === Constants.appSection.chat)
                            return Constants.appViewStackIndex.chat
                        if (activeSectionType === Constants.appSection.community) {

                            for(let i = this.children.length - 1; i >=0; i--)
                            {
                                var obj = this.children[i]
                                if (obj && obj.sectionId && obj.sectionId === appMain.rootStore.mainModuleInst.activeSection.id)
                                {
                                    obj.active = true
                                    return i
                                }
                            }

                            // Should never be here, correct index must be returned from the for loop above
                            console.error("Wrong section type: ", appMain.rootStore.mainModuleInst.activeSection.sectionType,
                                        " or section id: ", appMain.rootStore.mainModuleInst.activeSection.id)
                            return Constants.appViewStackIndex.community
                        }
                        if (activeSectionType === Constants.appSection.communitiesPortal)
                            return Constants.appViewStackIndex.communitiesPortal
                        if (activeSectionType === Constants.appSection.wallet)
                            return Constants.appViewStackIndex.wallet
                        if (activeSectionType === Constants.appSection.browser)
                            return Constants.appViewStackIndex.browser
                        if (activeSectionType === Constants.appSection.profile)
                            return Constants.appViewStackIndex.profile
                        if (activeSectionType === Constants.appSection.node)
                            return Constants.appViewStackIndex.node

                        // We should never end up here
                        console.error("AppMain: Unknown section type")
                    }

                    onCurrentIndexChanged: {
                        var obj = this.children[currentIndex]
                        if (!obj)
                            return

                        createChatView.opened = false

                        if (obj === browserLayoutContainer && browserLayoutContainer.active == false) {
                            browserLayoutContainer.active = true;
                        }

                        if (obj === walletLayoutContainer && !walletLayoutContainer.active) {
                            walletLayoutContainer.active = true
                            walletLayoutContainer.item.showSigningPhrasePopup()
                        }

                        if (obj === profileLayoutContainer && !profileLayoutContainer.active) {
                            profileLayoutContainer.active = true
                        }

                        if (obj === nodeLayoutContainer && !nodeLayoutContainer.active) {
                            nodeLayoutContainer.active = true
                        }

                        if (obj.onActivated && typeof obj.onActivated === "function") {
                            this.children[currentIndex].onActivated()
                        }
                    }

                    // NOTE:
                    // If we ever change stack layout component order we need to updade
                    // Constants.appViewStackIndex accordingly

                    ChatLayout {
                        id: chatLayoutContainer

                        chatView.emojiPopup: statusEmojiPopup
                        chatView.stickersPopup: statusStickersPopup

                        contactsStore: appMain.rootStore.contactStore
                        rootStore.emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                        rootStore.openCreateChat: createChatView.opened

                        chatView.onProfileButtonClicked: {
                            Global.changeAppSectionBySectionType(Constants.appSection.profile);
                        }

                        chatView.onOpenAppSearch: {
                            appSearch.openSearchPopup()
                        }

                        onImportCommunityClicked: {
                            Global.openPopup(communitiesPortalLayoutContainer.importCommunitiesPopup);
                        }

                        onCreateCommunityClicked: {
                            Global.openPopup(communitiesPortalLayoutContainer.createCommunitiesPopup);
                        }

                        Component.onCompleted: {
                            rootStore.chatCommunitySectionModule = appMain.rootStore.mainModuleInst.getChatSectionModule()
                        }
                    }

                    CommunitiesPortalLayout {
                        id: communitiesPortalLayoutContainer
                    }

                    Loader {
                        id: walletLayoutContainer
                        active: false
                        asynchronous: true
                        sourceComponent: WalletLayout {
                            store: appMain.rootStore
                            contactsStore: appMain.rootStore.profileSectionStore.contactsStore
                            emojiPopup: statusEmojiPopup
                            sendModalPopup: sendModal
                        }
                    }

                    Loader {
                        id: browserLayoutContainer
                        active: false
                        asynchronous: true
                        sourceComponent: BrowserLayout {
                            globalStore: appMain.rootStore
                            sendTransactionModal: sendModal
                        }
                        // Loaders do not have access to the context, so props need to be set
                        // Adding a "_" to avoid a binding loop
                        // Not Refactored Yet
                        //                property var _chatsModel: chatsModel.messageView
                        // Not Refactored Yet
                        //                property var _walletModel: walletModel
                        // Not Refactored Yet
                        //                property var _utilsModel: utilsModel
                        //  property var _web3Provider: BrowserStores.Web3ProviderStore.web3ProviderInst
                    }

                    Loader {
                        id: profileLayoutContainer
                        active: false
                        asynchronous: true
                        sourceComponent: ProfileLayout {
                            store: appMain.rootStore.profileSectionStore
                            globalStore: appMain.rootStore
                            systemPalette: appMain.sysPalette
                            emojiPopup: statusEmojiPopup
                        }
                    }

                    Loader {
                        id: nodeLayoutContainer
                        active: false
                        asynchronous: true
                        sourceComponent: NodeLayout {}
                    }

                    Repeater {
                        model: appMain.rootStore.mainModuleInst.sectionsModel

                        delegate: DelegateChooser {
                            role: "sectionType"
                            DelegateChoice {
                                roleValue: Constants.appSection.community

                                delegate: Loader {
                                    property string sectionId: model.id
                                    active: false
                                    asynchronous: true
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                    Layout.fillHeight: true

                                    sourceComponent: ChatLayout {
                                        chatView.emojiPopup: statusEmojiPopup
                                        chatView.stickersPopup: statusStickersPopup

                                        contactsStore: appMain.rootStore.contactStore
                                        rootStore.emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                                        rootStore.openCreateChat: createChatView.opened

                                        chatView.onProfileButtonClicked: {
                                            Global.changeAppSectionBySectionType(Constants.appSection.profile);
                                        }

                                        chatView.onOpenAppSearch: {
                                            appSearch.openSearchPopup()
                                        }

                                        Component.onCompleted: {
                                            // we cannot return QVariant if we pass another parameter in a function call
                                            // that's why we're using it this way
                                            appMain.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(model.id)
                                            rootStore.chatCommunitySectionModule = appMain.rootStore.mainModuleInst.getCommunitySectionModule()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Loader {
                    id: createChatView

                    property bool opened: false
                    active: opened

                    asynchronous: true
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.rightMargin: 8
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: parent.width - chatLayoutContainer.chatView.leftPanel.width - anchors.rightMargin - anchors.leftMargin

                    sourceComponent: CreateChatView {
                        rootStore: chatLayoutContainer.rootStore
                        emojiPopup: statusEmojiPopup
                    }
                }
            }
        } // ColumnLayout

        Component {
            id: mailserverNotWorkingPopupComponent
            MailserverConnectionDialog {
                onClosed: {
                    destroy()
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

        Component {
            id: activityCenterPopupComponent
            ActivityCenterPopup {
                id: activityCenter
                // TODO get screen size // Taken from old code top bar height was fixed there to 56
                property int _buttonSize: 56

                x: parent.width - width - Style.current.smallPadding
                y: parent.y + _buttonSize
                height: appView.height - _buttonSize * 2
                store: chatLayoutContainer.rootStore
                activityCenterStore: appMain.activityCenterStore
            }
        }

        Component {
            id: nicknamePopupComponent
            NicknamePopup {
                onEditDone: {
                    if (nickname !== newNickname) {
                        appMain.rootStore.contactStore.changeContactNickname(publicKey, newNickname)
                    }
                    close()
                }
                onClosed: destroy()
            }
        }

        Component {
            id: unblockContactConfirmationComponent
            UnblockContactConfirmationDialog {
                onUnblockButtonClicked: {
                    appMain.rootStore.contactStore.unblockContact(contactAddress)
                    close()
                }
                onClosed: destroy()
            }
        }

        Component {
            id: blockContactConfirmationComponent
            BlockContactConfirmationDialog {
                onBlockButtonClicked: {
                    appMain.rootStore.contactStore.blockContact(contactAddress)
                    close()
                }
                onClosed: destroy()
            }
        }

        // Add SendModal here as it is used by the Wallet as well as the Browser
        Loader {
            id: sendModal
            active: false

            function open(address = "") {
                this.active = true
                this.item.addressText = address;
                this.item.open()
            }
            function closed() {
                // this.sourceComponent = undefined // kill an opened instance
                this.active = false
            }
            property var selectedAccount
            property bool isBridgeTx
            sourceComponent: SendModal {
                onClosed: {
                    sendModal.closed()
                    sendModal.isBridgeTx = false
                }
            }
            onLoaded: {
                if (!!sendModal.selectedAccount) {
                    item.selectedAccount = sendModal.selectedAccount
                }
                if(isBridgeTx)
                    item.isBridgeTx = sendModal.isBridgeTx
            }
        }

        Action {
            shortcut: "Ctrl+1"
            onTriggered: {
                Global.setNthEnabledSectionActive(0)
            }
        }
        Action {
            shortcut: "Ctrl+2"
            onTriggered: {
                Global.setNthEnabledSectionActive(1)
            }
        }
        Action {
            shortcut: "Ctrl+3"
            onTriggered: {
                Global.setNthEnabledSectionActive(2)
            }
        }
        Action {
            shortcut: "Ctrl+4"
            onTriggered: {
                Global.setNthEnabledSectionActive(3)
            }
        }
        Action {
            shortcut: "Ctrl+5"
            onTriggered: {
                Global.setNthEnabledSectionActive(4)
            }
        }
        Action {
            shortcut: "Ctrl+6"
            onTriggered: {
                Global.setNthEnabledSectionActive(5)
            }
        }
        Action {
            shortcut: "Ctrl+7"
            onTriggered: {
                Global.setNthEnabledSectionActive(6)
            }
        }
        Action {
            shortcut: "Ctrl+8"
            onTriggered: {
                Global.setNthEnabledSectionActive(7)
            }
        }
        Action {
            shortcut: "Ctrl+9"
            onTriggered: {
                Global.setNthEnabledSectionActive(8)
            }
        }

        Action {
            shortcut: "Ctrl+K"
            onTriggered: {
                // FIXME the focus is no longer on the AppMain when the popup is opened, so this does not work to close
                if (!channelPickerLoader.active)
                    channelPickerLoader.active = true

                if (channelPickerLoader.item.opened) {
                    channelPickerLoader.item.close()
                    channelPickerLoader.active = false
                } else {
                    channelPickerLoader.item.open()
                }
            }
        }
        Action {
            shortcut: "Ctrl+F"
            onTriggered: {
                // FIXME the focus is no longer on the AppMain when the popup is opened, so this does not work to close
                if (appSearch.active) {
                    appSearch.closeSearchPopup()
                } else {
                    appSearch.openSearchPopup()
                }
            }
        }

        Loader {
            id: channelPickerLoader
            active: false
            asynchronous: true
            sourceComponent: StatusSearchListPopup {
                searchBoxPlaceholder: qsTr("Where do you want to go?")
                model: rootStore.chatSearchModel
                delegate: StatusListItem {
                    property var modelData
                    property bool isCurrentItem: true
                    function filterAccepts(searchText) {
                        const lowerCaseSearchText = searchText.toLowerCase()
                        return title.toLowerCase().includes(lowerCaseSearchText) || label.toLowerCase().includes(lowerCaseSearchText)
                    }

                    title: modelData ? modelData.name : ""
                    label: modelData? modelData.sectionName : ""
                    highlighted: isCurrentItem
                    sensor.hoverEnabled: false
                    statusListItemIcon {
                        name: modelData ? modelData.name : ""
                        active: true
                    }
                    asset.width: 30
                    asset.height: 30
                    asset.color: modelData ? modelData.color : ""
                    asset.name: modelData ? modelData.icon : ""
                    asset.isImage: asset.name.includes("data")
                }

                onAboutToShow: rootStore.rebuildChatSearchModel()
                onSelected: {
                    rootStore.setActiveSectionChat(modelData.sectionId, modelData.chatId)
                    close()
                }
            }
        }
    }

    StatusListView {
        id: toastArea
        objectName: "ephemeralNotificationList"
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        width: 343
        height: Math.min(parent.height - 120, toastArea.contentHeight)
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
            onClicked: {
                appMain.rootStore.mainModuleInst.ephemeralNotificationClicked(model.timestamp)
                this.open = false
            }
            onLinkActivated: {
                Qt.openUrlExternally(link);
            }

            onClose: {
                appMain.rootStore.mainModuleInst.removeEphemeralNotification(model.timestamp)
            }
        }
    }

    Component.onCompleted: {
        Global.appMain = this;
        Global.pinnedMessagesPopup = pinnedMessagesPopupComponent;
        Global.communityProfilePopup = communityProfilePopup;
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
        Global.settingsLoaded()
    }

    Loader {
        id: keycardPopup
        active: false
        sourceComponent: KeycardPopup {
            anchors.centerIn: parent
            sharedKeycardModule: appMain.rootStore.mainModuleInst.keycardSharedModule
        }

        onLoaded: {
            keycardPopup.item.open()
        }
    }

    Connections {
        target: appMain.rootStore.mainModuleInst
        function onActiveSectionChanged() {
            if (!!appMain.rootStore.mainModuleInst.getCommunitySectionModule())
                rootDropAreaPanel.activeChatType = appMain.rootStore.mainModuleInst.getCommunitySectionModule().activeItem.type
        }
    }

    DropAreaPanel {
        id: rootDropAreaPanel
        width: appMain.width
        height: appMain.height
        activeChatType: appMain.rootStore.mainModuleInst.getCommunitySectionModule() ? appMain.rootStore.mainModuleInst.getCommunitySectionModule().activeItem.type
                                                                                     : 0
        enabled: !drag.source && (
                                // in chat view
                                (appMain.rootStore.mainModuleInst.activeSection.sectionType === Constants.appSection.chat &&
                                (
                                    // in a one-to-one chat
                                    activeChatType === Constants.chatType.oneToOne ||
                                    // in a private group chat
                                    activeChatType === Constants.chatType.privateGroupChat
                                    )
                                ) ||
                                // In community section
                                appMain.rootStore.mainModuleInst.activeSection.sectionType === Constants.appSection.community)
    }
}
