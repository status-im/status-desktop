import QtQuick 2.15
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import Qt.labs.platform 1.1
import QtQml.Models 2.14
import QtQml 2.15

import AppLayouts.Wallet 1.0
import AppLayouts.Node 1.0
import AppLayouts.Browser 1.0
import AppLayouts.Chat 1.0
import AppLayouts.Chat.views 1.0
import AppLayouts.Profile 1.0
import AppLayouts.CommunitiesPortal 1.0

import utils 1.0
import shared 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.popups.keycard 1.0
import shared.status 1.0
import shared.stores 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core 0.1

import AppLayouts.Browser.stores 1.0 as BrowserStores
import AppLayouts.stores 1.0
import AppLayouts.Chat.stores 1.0 as ChatStores
import AppLayouts.CommunitiesPortal.stores 1.0

import mainui.activitycenter.stores 1.0
import mainui.activitycenter.popups 1.0

import SortFilterProxyModel 0.2

import "panels"

Item {
    id: appMain

    property alias appLayout: appLayout
    property RootStore rootStore: RootStore {}
    property var rootChatStore: ChatStores.RootStore {
        contactsStore: appMain.rootStore.contactStore
        communityTokensStore: appMain.communityTokensStore
        emojiReactionsModel: appMain.rootStore.emojiReactionsModel
        openCreateChat: createChatView.opened
        networkConnectionStore: appMain.networkConnectionStore
    }
    property var createChatPropertiesStore: ChatStores.CreateChatPropertiesStore {}
    property ActivityCenterStore activityCenterStore: ActivityCenterStore {}
    property NetworkConnectionStore networkConnectionStore: NetworkConnectionStore {}
    property CommunityTokensStore communityTokensStore: CommunityTokensStore {}
    property CommunitiesStore communitiesStore: CommunitiesStore {}
    // set from main.qml
    property var sysPalette

    Connections {
        target: rootStore.mainModuleInst

        function onDisplayUserProfile(publicKey: string) {
            popups.openProfilePopup(publicKey)
        }

        function onDisplayKeycardSharedModuleFlow() {
            keycardPopup.active = true
        }

        function onDestroyKeycardSharedModuleFlow() {
            keycardPopup.active = false
        }

        function onMailserverWorking() {
            mailserverConnectionBanner.hide()
        }

        function onMailserverNotWorking() {
            mailserverConnectionBanner.show()
        }

        function onActiveSectionChanged() {
            createChatView.opened = false
        }

        function onOpenActivityCenter() {
            d.openActivityCenterPopup()
        }
    }

    QtObject {
        id: d

        property var activityCenterPopupObj: null

        function openActivityCenterPopup() {
            if (!activityCenterPopupObj) {
                activityCenterPopupObj = activityCenterPopupComponent.createObject(appMain)
            }

            if (activityCenterPopupObj.opened) {
                activityCenterPopupObj.close()
            } else {
                activityCenterPopupObj.open()
            }
        }
    }

    Popups {
        id: popups
        popupParent: appMain
        rootStore: appMain.rootStore
        communitiesStore: appMain.communitiesStore
    }

    Connections {
        id: globalConns
        target: Global

        function onOpenLinkInBrowser(link: string) {
            changeAppSectionBySectionId(Constants.appSection.browser)
            Qt.callLater(() => browserLayoutContainer.item.openUrlInNewTab(link));
        }

        function onOpenCreateChatView() {
            createChatView.opened = true
        }

        function onCloseCreateChatView() {
            createChatView.opened = false
        }

        function onOpenActivityCenterPopupRequested() {
            d.openActivityCenterPopup()
        }

        function onDisplayToastMessage(title: string, subTitle: string, icon: string, loading: bool, ephNotifType: int, url: string) {
            appMain.rootStore.mainModuleInst.displayEphemeralNotification(title, subTitle, icon, loading, ephNotifType, url)
        }

        function onOpenLink(link: string) {
            // Qt sometimes inserts random HTML tags; and this will break on invalid URL inside QDesktopServices::openUrl(link)
            link = appMain.rootStore.plainText(link)
            if (appMain.rootStore.showBrowserSelector) {
                popups.openChooseBrowserPopup(link)
            } else {
                if (appMain.rootStore.openLinksInStatus) {
                    globalConns.onAppSectionBySectionTypeChanged(Constants.appSection.browser)
                    globalConns.onOpenLinkInBrowser(link)
                } else {
                    Qt.openUrlExternally(link)
                }
            }
        }

        function onPlaySendMessageSound() {
            sendMessageSound.stop()
            sendMessageSound.play()
        }

        function onPlayNotificationSound() {
            notificationSound.stop()
            notificationSound.play()
        }

        function onPlayErrorSound() {
            errorSound.stop()
            errorSound.play()
        }

        function onSetNthEnabledSectionActive(nthSection: int) {
            if(!appMain.rootStore.mainModuleInst)
                return
            appMain.rootStore.mainModuleInst.setNthEnabledSectionActive(nthSection)
        }

        function onAppSectionBySectionTypeChanged(sectionType: int, subsection: int) {
            if(!appMain.rootStore.mainModuleInst)
                return

            appMain.rootStore.mainModuleInst.setActiveSectionBySectionType(sectionType)
            if (sectionType === Constants.appSection.profile) {
                Global.settingsSubsection = subsection;
            }
        }

        function onOpenSendModal(address: string) {
            sendModal.open(address)
        }

        function onSwitchToCommunity(communityId: string) {
            appMain.communitiesStore.setActiveCommunity(communityId)
        }
    }

    function changeAppSectionBySectionId(sectionId) {
        appMain.rootStore.mainModuleInst.setActiveSectionById(sectionId)
    }

    Audio {
        id: sendMessageSound
        store: rootStore
        source: "qrc:/imports/assets/audio/send_message.wav"
    }

    Audio {
        id: notificationSound
        store: rootStore
        source: "qrc:/imports/assets/audio/notification.wav"
    }

    Audio {
        id: errorSound
        source: "qrc:/imports/assets/audio/error.mp3"
        store: rootStore
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

    Loader {
        id: statusEmojiPopup
        active: appMain.rootStore.mainModuleInst.sectionsLoaded
        sourceComponent: StatusEmojiPopup {
            width: 360
            height: 440
        }
    }

    Loader {
        id: statusStickersPopupLoader
        active: appMain.rootStore.mainModuleInst.sectionsLoaded
        sourceComponent: StatusStickersPopup {
            id: statusStickersPopup
            store: appMain.rootChatStore
        }
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

                popupMenu: Component {
                    StatusMenu {
                        id: communityContextMenu

                        property var chatCommunitySectionModule

                        openHandler: function () {
                            // we cannot return QVariant if we pass another parameter in a function call
                            // that's why we're using it this way
                            appMain.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(model.id)
                            communityContextMenu.chatCommunitySectionModule = appMain.rootStore.mainModuleInst.getCommunitySectionModule()
                        }

                        StatusAction {
                            text: qsTr("Invite People")
                            icon.name: "share-ios"
                            enabled: model.canManageUsers
                            onTriggered: {
                                popups.openInviteFriendsToCommunityPopup(model,
                                                                         communityContextMenu.chatCommunitySectionModule,
                                                                         null)
                            }
                        }

                        StatusAction {
                            text: qsTr("View Community")
                            icon.name: "group-chat"
                            onTriggered: popups.openCommunityProfilePopup(appMain.rootStore, model, communityContextMenu.chatCommunitySectionModule)
                        }

                        StatusAction {
                            text: model.muted ? qsTr("Unmute Community") : qsTr("Mute Community")
                            icon.name: model.muted ? "notification-muted" : "notification"
                            onTriggered: {
                                communityContextMenu.chatCommunitySectionModule.setCommunityMuted(!model.muted)
                            }
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

                enabled: !localAppSettings.testEnvironment
                visible: enabled

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

                Component.onCompleted: {
                    if (!isConnected)
                        processConnected()
                }

                Connections {
                    target: rootStore.aboutModuleInst
                    function onAppVersionFetched(available: bool, version: string, url: string) {
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

                    onClicked: popups.openBackUpSeedPopup()

                    onCloseClicked: {
                        appMain.rootStore.profileSectionStore.profileStore.userDeclinedBackupBanner = true
                    }
                }


                ModuleWarning {
                    Layout.fillWidth: true
                    readonly property int progress: appMain.communitiesStore.discordImportProgress
                    readonly property bool inProgress: (progress > 0 && progress < 100) || appMain.communitiesStore.discordImportInProgress
                    readonly property bool finished: progress >= 100
                    readonly property bool cancelled: appMain.communitiesStore.discordImportCancelled
                    readonly property bool stopped: appMain.communitiesStore.discordImportProgressStopped
                    readonly property int errors: appMain.communitiesStore.discordImportErrorsCount
                    readonly property int warnings: appMain.communitiesStore.discordImportWarningsCount
                    readonly property string communityId: appMain.communitiesStore.discordImportCommunityId
                    readonly property string communityName: appMain.communitiesStore.discordImportCommunityName

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
                    onLinkActivated: popups.openDiscordImportProgressPopup()
                    progressValue: progress
                    closeBtnVisible: finished || stopped
                    buttonText: finished && !errors ? qsTr("Visit your Community") : ""
                    onClicked: function() {
                        appMain.communitiesStore.setActiveCommunity(communityId)
                    }
                    onCloseClicked: {
                        hide();
                    }
                }

                ModuleWarning {
                    id: downloadingArchivesBanner
                    Layout.fillWidth: true
                    active: appMain.communitiesStore.downloadingCommunityHistoryArchives
                    type: ModuleWarning.Danger
                    text: qsTr("Downloading message history archives, DO NOT CLOSE THE APP until this banner disappears.")
                    closeBtnVisible: false
                }

                ModuleWarning {
                    id: mailserverConnectionBanner
                    type: ModuleWarning.Warning
                    text: qsTr("Can not connect to store node. Retrying automatically")
                    onCloseClicked: hide()
                    Layout.fillWidth: true
                }

                Component {
                    id: connectedBannerComponent

                    ModuleWarning {
                        id: connectedBanner
                        property bool isConnected: true

                        objectName: "connectionInfoBanner"
                        Layout.fillWidth: true
                        text: isConnected ? qsTr("You are back online") : qsTr("Internet connection lost. Reconnect to ensure everything is up to date.")
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
                        onHideFinished: {
                            destroy()
                            bannersLayout.connectedBanner = null
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
                        onHideFinished: {
                            destroy()
                            bannersLayout.updateBanner = null
                        }
                    }
                }

                ConnectionWarnings {
                    id: walletBlockchainConnectionBanner
                    objectName: "walletBlockchainConnectionBanner"
                    Layout.fillWidth: true
                    websiteDown: Constants.walletConnections.blockchains
                    withCache: networkConnectionStore.balanceCache
                    networkConnectionStore: appMain.networkConnectionStore
                    tooltipMessage: qsTr("Pocket Network (POKT) & Infura are currently both unavailable for %1. Balances for those chains are as of %2.").arg(jointChainIdString).arg(lastCheckedAt)
                    toastText: {
                        switch(connectionState) {
                        case Constants.ConnectionStatus.Success:
                            return qsTr("Pocket Network (POKT) connection successful")
                        case Constants.ConnectionStatus.Failure:
                            if(completelyDown) {
                                if(withCache)
                                    return qsTr("POKT & Infura down. Token balances are as of %1.").arg(lastCheckedAt)
                                else
                                    return qsTr("POKT & Infura down. Token balances cannot be retrieved.")
                            }
                            else if(chainIdsDown.length > 0) {
                                if(chainIdsDown.length > 2) {
                                    return qsTr("POKT & Infura down for <a href='#'>multiple chains </a>. Token balances for those chains cannot be retrieved.")
                                }
                                else if(chainIdsDown.length === 1) {
                                    return qsTr("POKT & Infura down for %1. %1 token balances are as of %2.").arg(jointChainIdString).arg(lastCheckedAt)
                                }
                                else {
                                    return qsTr("POKT & Infura down for %1. %1 token balances cannot be retrieved.").arg(jointChainIdString)
                                }
                            }
                            else
                                return ""
                        case Constants.ConnectionStatus.Retrying:
                            return qsTr("Retrying connection to Pocket Network (POKT).")
                        default:
                            return ""
                        }
                    }
                }

                ConnectionWarnings {
                    id: walletCollectiblesConnectionBanner
                    objectName: "walletCollectiblesConnectionBanner"
                    Layout.fillWidth: true
                    websiteDown: Constants.walletConnections.collectibles
                    withCache: networkConnectionStore.collectiblesCache
                    networkConnectionStore: appMain.networkConnectionStore
                    toastText: {
                        switch(connectionState) {
                        case Constants.ConnectionStatus.Success:
                            return qsTr("Opensea connection successful")
                        case Constants.ConnectionStatus.Failure:
                            if(withCache){
                                return qsTr("Opensea down. Collectibles are as of %1.").arg(lastCheckedAt)
                            }
                            else {
                                return qsTr("Opensea down.")
                            }
                        case Constants.ConnectionStatus.Retrying:
                            return qsTr("Retrying connection to Opensea...")
                        default:
                            return ""
                        }
                    }
                }

                ConnectionWarnings {
                    id: walletMarketConnectionBanner
                    objectName: "walletMarketConnectionBanner"
                    Layout.fillWidth: true
                    websiteDown: Constants.walletConnections.market
                    withCache: networkConnectionStore.marketValuesCache
                    networkConnectionStore: appMain.networkConnectionStore
                    toastText: {
                        switch(connectionState) {
                        case Constants.ConnectionStatus.Success:
                            return qsTr("CryptoCompare and CoinGecko connection successful")
                        case Constants.ConnectionStatus.Failure: {
                            if(withCache) {
                                return qsTr("CryptoCompare and CoinGecko down. Market values are as of %1.").arg(lastCheckedAt)
                            }
                            else {
                                return qsTr("CryptoCompare and CoinGecko down. Market values cannot be retrieved.")
                            }
                        }
                        case Constants.ConnectionStatus.Retrying:
                            return qsTr("Retrying connection to CryptoCompare and CoinGecko...")
                        default:
                            return ""
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
                            for (let i = this.children.length - 1; i >=0; i--) {
                                var obj = this.children[i]
                                if (obj && obj.sectionId && obj.sectionId === appMain.rootStore.mainModuleInst.activeSection.id) {
                                    return i
                                }
                            }

                            // Should never be here, correct index must be returned from the for loop above
                            console.error("Wrong section type:", appMain.rootStore.mainModuleInst.activeSection.sectionType,
                                          "or section id: ", appMain.rootStore.mainModuleInst.activeSection.id)
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

                    // NOTE:
                    // If we ever change stack layout component order we need to updade
                    // Constants.appViewStackIndex accordingly

                    Loader {
                        id: personalChatLayoutLoader
                        asynchronous: true
                        active: false
                        sourceComponent: {
                            if (appMain.rootStore.mainModuleInst.chatsLoadingFailed) {
                                return errorStateComponent
                            }
                            if (appMain.rootStore.mainModuleInst.sectionsLoaded) {
                                return personalChatLayoutComponent
                            }
                            return loadingStateComponent
                        }

                        // Do not unload section data from the memory in order not
                        // to reset scroll, not send text input and etc during the
                        // sections switching
                        Binding on active {
                            when: appView.currentIndex === Constants.appViewStackIndex.chat
                            value: true
                            restoreMode: Binding.RestoreNone
                        }
                        
                        Component {
                            id: loadingStateComponent
                            Item {
                                anchors.fill: parent

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    StatusBaseText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: qsTr("Loading sections...")
                                    }
                                    LoadingAnimation { anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                        
                        Component {
                            id: errorStateComponent
                            Item {
                                anchors.fill: parent
                                StatusBaseText {
                                    text: qsTr("Error loading chats, try closing the app and restarting")
                                    anchors.centerIn: parent
                                }
                            }
                        }

                        Component {
                            id: personalChatLayoutComponent

                            ChatLayout {
                                id: chatLayoutContainer

                                Binding {
                                    target: rootDropAreaPanel
                                    property: "enabled"
                                    value: chatLayoutContainer.currentIndex === 0 // Meaning: Chats / channels view
                                    when: visible
                                    restoreMode: Binding.RestoreBindingOrValue
                                }

                                rootStore: ChatStores.RootStore {
                                    contactsStore: appMain.rootStore.contactStore
                                    communityTokensStore: appMain.communityTokensStore
                                    emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                                    openCreateChat: createChatView.opened
                                    chatCommunitySectionModule: appMain.rootStore.mainModuleInst.getChatSectionModule()
                                    networkConnectionStore: appMain.networkConnectionStore
                                }
                                createChatPropertiesStore: appMain.createChatPropertiesStore
                                emojiPopup: statusEmojiPopup.item
                                stickersPopup: statusStickersPopupLoader.item

                                onProfileButtonClicked: {
                                    Global.changeAppSectionBySectionType(Constants.appSection.profile);
                                }

                                onOpenAppSearch: {
                                    appSearch.openSearchPopup()
                                }
                            }
                        }
                    }

                    Loader {
                        active: appView.currentIndex === Constants.appViewStackIndex.communitiesPortal
                        asynchronous: true
                        CommunitiesPortalLayout {
                            anchors.fill: parent
                            communitiesStore: appMain.communitiesStore
                            assetsModel: appMain.rootChatStore.assetsModel
                            collectiblesModel: appMain.rootChatStore.collectiblesModel
                            notificationCount: appMain.activityCenterStore.unreadNotificationsCount
                            hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
                        }
                    }

                    Loader {
                        active: appView.currentIndex === Constants.appViewStackIndex.wallet
                        asynchronous: true
                        sourceComponent: WalletLayout {
                            store: appMain.rootStore
                            contactsStore: appMain.rootStore.profileSectionStore.contactsStore
                            emojiPopup: statusEmojiPopup.item
                            sendModalPopup: sendModal
                            networkConnectionStore: appMain.networkConnectionStore
                        }
                        onLoaded: item.showSigningPhrasePopup()
                    }

                    Loader {
                        id: browserLayoutContainer
                        active: appView.currentIndex === Constants.appViewStackIndex.browser
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
                        active: appView.currentIndex === Constants.appViewStackIndex.profile
                        asynchronous: true
                        sourceComponent: ProfileLayout {
                            store: appMain.rootStore.profileSectionStore
                            globalStore: appMain.rootStore
                            systemPalette: appMain.sysPalette
                            emojiPopup: statusEmojiPopup.item
                            networkConnectionStore: appMain.networkConnectionStore
                        }
                    }

                    Loader {
                        active: appView.currentIndex === Constants.appViewStackIndex.node
                        asynchronous: true
                        sourceComponent: NodeLayout {}
                    }

                    Repeater {
                        model: SortFilterProxyModel {
                            sourceModel: appMain.rootStore.mainModuleInst.sectionsModel
                            filters: ValueFilter {
                                roleName: "sectionType"
                                value: Constants.appSection.community
                            }
                        }

                        delegate: Loader {
                            id: communityLoader

                            readonly property string sectionId: model.id

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            Layout.fillHeight: true

                            asynchronous: true
                            active: false

                            // Do not unload section data from the memory in order not
                            // to reset scroll, not send text input and etc during the
                            // sections switching
                            Binding on active {
                                when: sectionId === appMain.rootStore.mainModuleInst.activeSection.id
                                value: true
                                restoreMode: Binding.RestoreNone
                            }

                            sourceComponent: ChatLayout {
                                id: chatLayoutComponent

                                Binding {
                                    target: rootDropAreaPanel
                                    property: "enabled"
                                    value: chatLayoutComponent.currentIndex === 0 // Meaning: Chats / channels view
                                    when: visible
                                    restoreMode: Binding.RestoreBindingOrValue
                                }

                                emojiPopup: statusEmojiPopup.item
                                stickersPopup: statusStickersPopupLoader.item
                                sectionItemModel: model

                                rootStore: ChatStores.RootStore {
                                    contactsStore: appMain.rootStore.contactStore
                                    communityTokensStore: appMain.communityTokensStore
                                    emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                                    openCreateChat: createChatView.opened
                                    chatCommunitySectionModule: {
                                        appMain.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(model.id)
                                        return appMain.rootStore.mainModuleInst.getCommunitySectionModule()
                                    }
                                }

                                onProfileButtonClicked: {
                                    Global.changeAppSectionBySectionType(Constants.appSection.profile);
                                }

                                onOpenAppSearch: {
                                    appSearch.openSearchPopup()
                                }
                            }
                        }
                    }
                }

                Loader {
                    id: createChatView

                    property bool opened: false
                    active: appMain.rootStore.mainModuleInst.sectionsLoaded && opened

                    asynchronous: true
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.rightMargin: 8
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: active ?
                            parent.width - Constants.chatSectionLeftColumnWidth -
                            anchors.rightMargin - anchors.leftMargin : 0

                    sourceComponent: CreateChatView {
                        rootStore: ChatStores.RootStore {
                            contactsStore: appMain.rootStore.contactStore
                            communityTokensStore: appMain.communityTokensStore
                            emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                            openCreateChat: createChatView.opened
                            chatCommunitySectionModule: appMain.rootStore.mainModuleInst.getChatSectionModule()
                        }
                        createChatPropertiesStore: appMain.createChatPropertiesStore
                        emojiPopup: statusEmojiPopup.item
                        stickersPopup: statusStickersPopupLoader.item
                    }
                }
            }
        } // ColumnLayout

        Component {
            id: activityCenterPopupComponent
            ActivityCenterPopup {
                // TODO get screen size // Taken from old code top bar height was fixed there to 56
                readonly property int _buttonSize: 56

                x: parent.width - width - Style.current.smallPadding
                y: parent.y + _buttonSize
                height: appView.height - _buttonSize * 2
                store: ChatStores.RootStore {
                    contactsStore: appMain.rootStore.contactStore
                    communityTokensStore: appMain.communityTokensStore
                    emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                    openCreateChat: createChatView.opened
                    chatCommunitySectionModule: appMain.rootStore.mainModuleInst.getChatSectionModule()
                }
                activityCenterStore: appMain.activityCenterStore
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
        clip: false

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
                if (link.startsWith("#")) // internal link to section
                    globalConns.onAppSectionBySectionTypeChanged(link.substring(1))
                else
                    Global.openLink(link)
            }

            onClose: {
                appMain.rootStore.mainModuleInst.removeEphemeralNotification(model.timestamp)
            }
        }
    }

    Component.onCompleted: {
        const whitelist = appMain.rootStore.messagingStore.getLinkPreviewWhitelist()
        try {
            const whiteListedSites = JSON.parse(whitelist)
            let settingsUpdated = false

            // Add Status links to whitelist
            whiteListedSites.push({title: "Status", address: Constants.deepLinkPrefix, imageSite: false})
            whiteListedSites.push({title: "Status", address: Constants.externalStatusLink, imageSite: false})
            let settings = localAccountSensitiveSettings.whitelistedUnfurlingSites

            if (!settings) {
                settings = {}
            }

            // Set Status links as true. We intercept those URLs so it is privacy-safe
            if (!settings[Constants.deepLinkPrefix] || !settings[Constants.externalStatusLink]) {
                settings[Constants.deepLinkPrefix] = true
                settings[Constants.externalStatusLink] = true
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

    DropAreaPanel {
        id: rootDropAreaPanel

        width: appMain.width
        height: appMain.height
    }
}
