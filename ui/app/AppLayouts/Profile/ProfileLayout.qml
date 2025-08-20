import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import shared
import shared.panels
import shared.popups.keycard
import shared.stores as SharedStores
import shared.stores.send
import utils

import "popups"
import "views"
import "views/profile"

import StatusQ
import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Layout
import StatusQ.Popups.Dialog

import AppLayouts.Communities.stores as CommunitiesStore
import AppLayouts.Profile.helpers
import AppLayouts.Profile.stores as ProfileStores
import AppLayouts.Wallet.controls
import AppLayouts.Wallet.stores
import AppLayouts.stores as AppLayoutsStores
import AppLayouts.stores.Messaging as MessagingStores

import SortFilterProxyModel


StatusSectionLayout {
    id: root

    required property bool isProduction

    property alias settingsSubsection: leftPanel.settingsSubsection
    property int settingsSubSubsection

    objectName: "profileStatusSectionLayout"

    required property TokensStore tokensStore
    required property WalletAssetsStore walletAssetsStore
    required property CollectiblesStore collectiblesStore
    required property SharedStores.CurrenciesStore currencyStore
    required property SharedStores.NetworksStore networksStore
    required property MessagingStores.MessagingRootStore messagingRootStore

    required property ProfileStores.ProfileStore profileStore
    required property ProfileStores.DevicesStore devicesStore
    required property ProfileStores.AdvancedStore advancedStore
    required property ProfileStores.PrivacyStore privacyStore
    required property ProfileStores.NotificationsStore notificationsStore
    required property ProfileStores.LanguageStore languageStore
    required property ProfileStores.KeycardStore keycardStore
    required property ProfileStores.WalletStore walletStore
    required property ProfileStores.EnsUsernamesStore ensUsernamesStore
    required property ProfileStores.AboutStore aboutStore

    property SharedStores.RootStore sharedRootStore
    property SharedStores.UtilsStore utilsStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    property CommunitiesStore.CommunitiesStore communitiesStore
    property MessagingStores.MessagingSettingsStore messagingSettingsStore
    property AppLayoutsStores.ContactsStore contactsStore
    property AppLayoutsStores.RootStore globalStore

    property var emojiPopup

    required property Keychain keychain

    property bool isKeycardEnabled: true
    property bool isBrowserEnabled: true
    required property bool privacyModeFeatureEnabled

    property var mutualContactsModel
    property var blockedContactsModel
    property var pendingContactsModel
    property int pendingReceivedContactsCount
    property var dismissedReceivedRequestContactsModel

    required property bool isCentralizedMetricsEnabled

    required property int theme // Theme.Style.xxx
    required property int fontSize // Theme.FontSize.xxx
    
    signal addressWasShownRequested(string address)
    signal connectUsernameRequested(string ensName, string ownerAddress)
    signal registerUsernameRequested(string ensName)
    signal releaseUsernameRequested(string ensName, string senderAddress, int chainId)

    signal themeChangeRequested(int theme)
    signal fontSizeChangeRequested(int fontSize)
    signal leaveCommunityRequest(string communityId)
    signal setCommunityMutedRequest(string communityId, int mutedType)
    signal inviteFriends(var communityData)

    signal openThirdpartyServicesInfoPopupRequested()
    signal openDiscussPageRequested()

    backButtonName: d.backButtonName
    onBackButtonClicked: {
        switch (root.settingsSubsection) {
        case Constants.settingsSubsection.contacts:
            Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.messaging)
            break;
        case Constants.settingsSubsection.about_privacy:
        case Constants.settingsSubsection.about_terms:
            Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.about)
            break;
        case Constants.settingsSubsection.wallet:
            walletView.item.resetStack()
            break;
        case Constants.settingsSubsection.keycard:
            keycardView.item.handleBackAction()
            break;
        }

        root.settingsSubSubsection = -1
    }

    Component.onCompleted: {
        profileContainer.currentIndexChanged()
        root.devicesStore.loadDevices() // Load devices to get non-paired number for badge
    }

    QtObject {
        id: d

        readonly property int contentWidth: Math.min(root.centerPanel.width, 560)
        readonly property int rightPanelWidth: Math.min(root.centerPanel.height, 768)

        readonly property bool isProfilePanelActive: profileContainer.currentIndex === Constants.settingsSubsection.profile
        readonly property bool sideBySidePreviewAvailable: root.Window.width >= 1840 // design

        // Used to alternatively add an error message to the dirty bubble if ephemeral notification
        // can clash at smaller viewports
        readonly property bool toastClashesWithDirtyBubble: root.Window.width <= 1650 // design

        property string backButtonName
    }

    SettingsEntriesModel {
        id: settingsEntriesModel

        showWalletEntries: root.walletStore.isWalletEnabled
        showBrowserEntries: root.isBrowserEnabled
        showBackUpSeed: !root.privacyStore.mnemonicBackedUp
        backUpSeedBadgeCount: root.profileStore.userDeclinedBackupBanner ? 0 : showBackUpSeed
        isKeycardEnabled: root.isKeycardEnabled

        syncingBadgeCount: root.devicesStore.devicesModel.count -
                           root.devicesStore.devicesModel.pairedCount
        messagingBadgeCount: root.pendingReceivedContactsCount
    }

    headerBackground: AccountHeaderGradient {
        width: parent.width
        overview: root.walletStore.selectedAccount
        visible: profileContainer.currentIndex === Constants.settingsSubsection.wallet && !!root.walletStore.selectedAccount
    }

    leftPanel: SettingsLeftTabView {
        id: leftPanel
        anchors.fill: parent

        model: settingsEntriesModel

        onMenuItemClicked: {
            if (profileContainer.currentItem.dirty && !profileContainer.currentItem.ignoreDirty) {
                event.accepted = true;
                profileContainer.currentItem.notifyDirty();
            }
            root.goToNextPanel();
        }
    }

    centerPanel: StackLayout {
        id: profileContainer

        readonly property var currentItem: (currentIndex >= 0 && currentIndex < children.length) ? children[currentIndex].item : null

        anchors.fill: parent
        anchors.leftMargin: Constants.settingsSection.leftMargin
        anchors.rightMargin: Constants.settingsSection.rightMargin

        currentIndex: leftPanel.settingsSubsection
        onCurrentIndexChanged: {
            if (!!children[currentIndex] && !children[currentIndex].active)
                children[currentIndex].active = true

            d.backButtonName = ""

            if (currentIndex === Constants.settingsSubsection.contacts) {
                d.backButtonName = settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.messaging)
            } else if (currentIndex === Constants.settingsSubsection.about_privacy || currentIndex === Constants.settingsSubsection.about_terms) {
                d.backButtonName = settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.about)
            } else if (currentIndex === Constants.settingsSubsection.wallet) {
                walletView.item.resetStack()
            } else if (currentIndex === Constants.settingsSubsection.keycard) {
                keycardView.item.handleBackAction()
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: MyProfileView {
                id: myProfileView
                implicitWidth: parent.width
                implicitHeight: parent.height

                profileStore: root.profileStore
                contactsStore: root.contactsStore
                communitiesStore: root.communitiesStore
                utilsStore: root.utilsStore
                networksStore: root.networksStore

                sendToAccountEnabled: root.networkConnectionStore.sendBuyBridgeEnabled
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.profile)
                contentWidth: d.contentWidth
                sideBySidePreview: d.sideBySidePreviewAvailable
                toastClashesWithDirtyBubble: d.toastClashesWithDirtyBubble

                communitiesShowcaseModel: root.profileStore.ownShowcaseCommunitiesModel
                accountsShowcaseModel: root.profileStore.ownShowcaseAccountsModel
                socialLinksShowcaseModel: root.profileStore.ownShowcaseSocialLinksModel
                collectiblesShowcaseModel: SortFilterProxyModel {
                    sourceModel: root.profileStore.ownShowcaseCollectiblesModel
                    sorters: [
                        FastExpressionSorter {
                            expression: {
                                root.collectiblesStore.collectiblesController.revision
                                return root.collectiblesStore.collectiblesController.compareTokens(modelLeft.uid, modelRight.uid)
                            }
                            expectedRoles: ["uid"]
                        }
                    ]
                    filters: [
                        FastExpressionFilter {
                            expression: {
                                root.collectiblesStore.collectiblesController.revision
                                return root.collectiblesStore.collectiblesController.filterAcceptsSymbol(model.uid)
                            }
                            expectedRoles: ["uid"]
                        }
                    ]
                }

                assetsModel: root.globalStore.globalAssetsModel
                collectiblesModel: root.globalStore.globalCollectiblesModel
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: ChangePasswordView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                privacyStore: root.privacyStore
                keychain: root.keychain
                passwordStrengthScoreFunction: root.sharedRootStore.getPasswordStrengthScore
                contentWidth: d.contentWidth
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.password)
            }
        }

        Loader {
            id: contactsView

            active: false
            asynchronous: true
            sourceComponent: ContactsView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                contactsStore: root.contactsStore
                utilsStore: root.utilsStore
                sectionTitle: qsTr("Contacts")
                contentWidth: d.contentWidth

                mutualContactsModel: root.mutualContactsModel
                blockedContactsModel: root.blockedContactsModel
                pendingContactsModel: root.pendingContactsModel
                pendingReceivedContactsCount: root.pendingReceivedContactsCount
                dismissedReceivedRequestContactsModel: root.dismissedReceivedRequestContactsModel
            }
        }

        Loader {
            id: ensContainer
            active: false
            asynchronous: true
            sourceComponent: EnsView {
                // TODO: we need to align structure for the entire this part using `SettingsContentBase` as root component
                // TODO: handle structure for this subsection to match style used in onther sections
                // using `SettingsContentBase` component as base.

                implicitWidth: parent.width
                implicitHeight: parent.height
                ensUsernamesStore: root.ensUsernamesStore
                walletAssetsStore: root.walletAssetsStore
                contactsStore: root.contactsStore
                networkConnectionStore: root.networkConnectionStore
                profileContentWidth: d.contentWidth
                onConnectUsernameRequested: (ensName, ownerAddress) => root.connectUsernameRequested(ensName, ownerAddress)
                onRegisterUsernameRequested: root.registerUsernameRequested(ensName)
                onReleaseUsernameRequested: root.releaseUsernameRequested(ensName, senderAddress, chainId)
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: MessagingView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                contentWidth: d.contentWidth

                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.messaging)
                requestsCount: root.pendingReceivedContactsCount
                messagingSettingsStore: root.messagingSettingsStore
            }
        }

        Loader {
            id: walletView
            active: false
            asynchronous: true
            sourceComponent: WalletView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                contentWidth: d.contentWidth

                settingsSubSubsection: root.settingsSubSubsection
                isKeycardEnabled: root.isKeycardEnabled

                walletStore: root.walletStore
                keycardStore: root.keycardStore
                tokensStore: root.tokensStore
                networkConnectionStore: root.networkConnectionStore
                assetsStore: root.walletAssetsStore
                collectiblesStore: root.collectiblesStore
                networksStore: root.networksStore
                contactsStore: root.contactsStore

                myPublicKey: root.contactsStore.myPublicKey
                currencySymbol: root.sharedRootStore.currencyStore.currentCurrency
                emojiPopup: root.emojiPopup
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.wallet)

                onAddressWasShownRequested: root.addressWasShownRequested(address)

                onBackButtonNameChanged: d.backButtonName = backButtonName
            }
            onLoaded: d.backButtonName = ""
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: AppearanceView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.appearance)
                contentWidth: d.contentWidth
                theme: root.theme
                fontSize: root.fontSize
                onThemeChangeRequested: (theme) => root.themeChangeRequested(theme)
                onFontSizeChangeRequested: (fontSize) => root.fontSizeChangeRequested(fontSize)
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: LanguageView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                languageSelectionEnabled: localAppSettings.translationsEnabled
                languageStore: root.languageStore
                currencyStore: root.currencyStore
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.language)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: NotificationsView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                privacyStore: root.privacyStore
                notificationsStore: root.notificationsStore
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.notifications)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: SyncingView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                isProduction: root.isProduction
                profileStore: root.profileStore
                devicesStore: root.devicesStore
                privacyStore: root.privacyStore
                advancedStore: root.advancedStore
                localBackupEnabled: root.devicesStore.localBackupEnabled
                backupPath: root.devicesStore.backupPath
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.syncingSettings)
                contentWidth: d.contentWidth
                onBackupPathSet: function(path) {
                    root.devicesStore.setBackupPath(path)
                }
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: BrowserView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                accountSettings: localAccountSensitiveSettings
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.browserSettings)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            id: advancedView

            active: false
            asynchronous: true
            sourceComponent: AdvancedView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                messagingSettingsStore: root.messagingSettingsStore
                advancedStore: root.advancedStore
                walletStore: root.walletStore
                isFleetSelectionEnabled: fleetSelectionEnabled
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.advanced)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: AboutView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.about)
                contentWidth: d.contentWidth
                isProduction: root.isProduction
                currentVersion: root.aboutStore.getCurrentVersion()
                gitCommit: root.aboutStore.getGitCommit()
                statusGoVersion: root.aboutStore.getStatusGoVersion()
                qtRuntimeVersion: SystemUtils.qtRuntimeVersion()

                onCheckForUpdates: root.aboutStore.checkForUpdates()
                onOpenLink: (url) => Global.openLink(url)
            }
        }

        Loader {
            id: communitiesView
            
            active: false
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: CommunitiesView {

                function getSpecificCommunityAccessStore(communityId: string) {
                    const communityRootStore = root.messagingRootStore.createCommunityRootStore(this, communityId)
                    return communityRootStore ? communityRootStore.communityAccessStore : null
                }

                implicitWidth: parent.width
                implicitHeight: parent.height

                rootStore: root.globalStore
                currencyStore: root.currencyStore
                walletAssetsStore: root.walletAssetsStore
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.communitiesSettings)
                contentWidth: d.contentWidth
                communitiesList: root.profileStore.communitiesList
                fnIsMyCommunityRequestPending: (communityId) => {
                                                   const communityAccessStore = getSpecificCommunityAccessStore(communityId)
                                                   if(communityAccessStore) {
                                                       return communityAccessStore.isMyCommunityRequestPending
                                                   }
                                                   return false
                                               }

                onLeaveCommunityRequest: root.leaveCommunityRequest(communityId)
                onSetCommunityMutedRequest: root.setCommunityMutedRequest(communityId, mutedType)
                onInviteFriends: root.inviteFriends(communityData)
                onCancelPendingRequestRequested: (communityId) => {
                                                     const communityAccessStore = getSpecificCommunityAccessStore(communityId)
                                                     if(communityAccessStore) {
                                                         communityAccessStore.cancelPendignRequest(communityId)
                                                     }
                                                 }
            }
        }

        Loader {
            id: keycardView
            active: false
            asynchronous: true
            sourceComponent: KeycardView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                keycardStore: root.keycardStore
                emojiPopup: root.emojiPopup
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.keycard)
                mainSectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.keycard)
                backButtonName: d.backButtonName
                contentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: SettingsContentBase {
                implicitWidth: parent.width
                implicitHeight: parent.height
                sectionTitle: "Status Software - Terms of Use"
                contentWidth: d.contentWidth

                StatusBaseText {
                    width: d.contentWidth
                    wrapMode: Text.Wrap
                    textFormat: Text.MarkdownText
                    text: SQUtils.StringUtils.readTextFile(":/imports/assets/docs/terms-of-use.mdwn")
                    onLinkActivated: Global.openLinkWithConfirmation(link, SQUtils.StringUtils.extractDomainFromLink(link))
                }
            }
        }

        Loader {
            active: false
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: SettingsContentBase {
                implicitWidth: parent.width
                implicitHeight: parent.height
                sectionTitle: "Status Software - Privacy Policy"
                contentWidth: d.contentWidth

                StatusBaseText {
                    width: d.contentWidth
                    wrapMode: Text.Wrap
                    textFormat: Text.MarkdownText
                    text: SQUtils.StringUtils.readTextFile(":/imports/assets/docs/privacy.mdwn")
                    onLinkActivated: Global.openLinkWithConfirmation(link, SQUtils.StringUtils.extractDomainFromLink(link))
                }
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: PrivacyAndSecurityView {
                isStatusNewsViaRSSEnabled: root.privacyStore.isStatusNewsViaRSSEnabled
                isCentralizedMetricsEnabled: root.isCentralizedMetricsEnabled
                thirdpartyServicesEnabled: root.privacyStore.thirdpartyServicesEnabled
                privacyModeFeatureEnabled: root.privacyModeFeatureEnabled
                implicitWidth: parent.width
                implicitHeight: parent.height

                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.privacyAndSecurity)
                contentWidth: d.contentWidth

                onSetNewsRSSEnabledRequested: function (isStatusNewsViaRSSEnabled) {
                    root.privacyStore.setNewsRSSEnabled(isStatusNewsViaRSSEnabled)
                }
                onOpenThirdpartyServicesInfoPopupRequested: root.openThirdpartyServicesInfoPopupRequested()
                onOpenDiscussPageRequested: root.openDiscussPageRequested()
            }
        }
    }

    showRightPanel: d.isProfilePanelActive && d.sideBySidePreviewAvailable
    rightPanelWidth: d.rightPanelWidth
    rightPanel: Loader {
        active: root.showRightPanel
        sourceComponent: profileContainer.currentItem.sideBySidePreviewComponent
    }

    Connections {
        target: root.keycardStore.keycardModule
        enabled: profileContainer.currentIndex === Constants.settingsSubsection.wallet ||
                 profileContainer.currentIndex === Constants.settingsSubsection.keycard

        function onDisplayKeycardSharedModuleFlow() {
            keycardPopup.active = true
        }
        function onDestroyKeycardSharedModuleFlow() {
            keycardPopup.active = false
        }
        function onSharedModuleBusy() {
            Global.openPopup(sharedModuleBusyPopupComponent)
        }
    }

    Loader {
        id: keycardPopup
        active: false
        sourceComponent: KeycardPopup {
            myKeyUid: root.profileStore.keyUid
            sharedKeycardModule: root.keycardStore.keycardModule.keycardSharedModule
            emojiPopup: root.emojiPopup

            // This connection ensures that when a PIN is chagned on Keycard, biometrics are updated (if enabled).
            // Should be removed/simplified when KeycardPopup is refactored to use KeycardServiceV2.
            // We put it here, because ProfileLayout has access to Keychain and it is also the only place
            // where KeycardPopup can be used to change PIN.
            Connections {
                target: root.keycardStore.keycardModule.keycardSharedModule

                function onKeycardPinChanged(pin) {
                    const keyUid = root.profileStore.keyUid
                    root.keychain.updateCredential(keyUid, pin)
                }
            }
        }

        onLoaded: {
            keycardPopup.item.open()
        }
    }

    Component {
        id: sharedModuleBusyPopupComponent
        StatusDialog {
            id: titleContentDialog
            title: qsTr("Status Keycard")

            StatusBaseText {
                anchors.fill: parent
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
                text: qsTr("The Keycard module is still busy, please try again")
            }

            standardButtons: Dialog.Ok
        }
    }
}
