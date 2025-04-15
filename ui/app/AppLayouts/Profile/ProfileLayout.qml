import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import shared 1.0
import shared.panels 1.0
import shared.popups.keycard 1.0
import shared.stores 1.0 as SharedStores
import shared.stores.send 1.0
import utils 1.0

import "popups"
import "views"
import "views/profile"

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Layout 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Communities.stores 1.0 as CommunitiesStore
import AppLayouts.Profile.helpers 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.stores 1.0 as AppLayoutsStores

import SortFilterProxyModel 0.2


StatusSectionLayout {
    id: root

    property alias settingsSubsection: leftPanel.settingsSubsection
    property int settingsSubSubsection

    objectName: "profileStatusSectionLayout"

    property SharedStores.RootStore sharedRootStore
    property SharedStores.UtilsStore utilsStore
    property ProfileStores.ProfileSectionStore store
    property AppLayoutsStores.RootStore globalStore
    property CommunitiesStore.CommunitiesStore communitiesStore
    property var systemPalette
    property var emojiPopup
    property SharedStores.NetworkConnectionStore networkConnectionStore
    required property TokensStore tokensStore
    required property WalletAssetsStore walletAssetsStore
    required property CollectiblesStore collectiblesStore
    required property SharedStores.CurrenciesStore currencyStore
    required property SharedStores.NetworksStore networksStore
    required property Keychain keychain

    property bool isKeycardEnabled: true

    property var mutualContactsModel
    property var blockedContactsModel
    property var pendingContactsModel
    property int pendingReceivedContactsCount
    property var dismissedReceivedRequestContactsModel

    required property bool isCentralizedMetricsEnabled

    signal connectUsernameRequested(string ensName)
    signal registerUsernameRequested(string ensName)
    signal releaseUsernameRequested(string ensName, string senderAddress, int chainId)

    backButtonName: root.store.backButtonName
    notificationCount: activityCenterStore.unreadNotificationsCount
    hasUnseenNotifications: activityCenterStore.hasUnseenNotifications

    onNotificationButtonClicked: Global.openActivityCenterPopup()
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
        root.store.devicesStore.loadDevices() // Load devices to get non-paired number for badge
    }

    QtObject {
        id: d

        readonly property int contentWidth: 560
        readonly property int rightPanelWidth: 768

        readonly property bool isProfilePanelActive: profileContainer.currentIndex === Constants.settingsSubsection.profile
        readonly property bool sideBySidePreviewAvailable: root.Window.width >= 1840 // design

        // Used to alternatively add an error message to the dirty bubble if ephemeral notification
        // can clash at smaller viewports
        readonly property bool toastClashesWithDirtyBubble: root.Window.width <= 1650 // design
    }

    SettingsEntriesModel {
        id: settingsEntriesModel

        showWalletEntries: root.store.walletMenuItemEnabled
        showBackUpSeed: !root.store.privacyStore.mnemonicBackedUp
        isKeycardEnabled: root.isKeycardEnabled

        syncingBadgeCount: root.store.devicesStore.devicesModel.count -
                           root.store.devicesStore.devicesModel.pairedCount
        messagingBadgeCount: root.pendingReceivedContactsCount
    }

    headerBackground: AccountHeaderGradient {
        width: parent.width
        overview: root.store.walletStore.selectedAccount
        visible: profileContainer.currentIndex === Constants.settingsSubsection.wallet && !!root.store.walletStore.selectedAccount
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
        }
    }

    centerPanel: StackLayout {
        id: profileContainer

        readonly property var currentItem: (currentIndex >= 0 && currentIndex < children.length) ? children[currentIndex].item : null

        anchors.fill: parent
        anchors.leftMargin: Constants.settingsSection.leftMargin

        currentIndex: leftPanel.settingsSubsection
        onCurrentIndexChanged: {
            if (!!children[currentIndex] && !children[currentIndex].active)
                children[currentIndex].active = true

            root.store.backButtonName = ""

            if (currentIndex === Constants.settingsSubsection.contacts) {
                root.store.backButtonName = settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.messaging)
            } else if (currentIndex === Constants.settingsSubsection.about_privacy || currentIndex === Constants.settingsSubsection.about_terms) {
                root.store.backButtonName = settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.about)
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

                profileStore: root.store.profileStore
                contactsStore: root.store.contactsStore
                communitiesStore: root.communitiesStore
                utilsStore: root.utilsStore
                networksStore: root.networksStore

                sendToAccountEnabled: root.networkConnectionStore.sendBuyBridgeEnabled
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.profile)
                contentWidth: d.contentWidth
                sideBySidePreview: d.sideBySidePreviewAvailable
                toastClashesWithDirtyBubble: d.toastClashesWithDirtyBubble

                communitiesShowcaseModel: root.store.ownShowcaseCommunitiesModel
                accountsShowcaseModel: root.store.ownShowcaseAccountsModel
                socialLinksShowcaseModel: root.store.ownShowcaseSocialLinksModel
                collectiblesShowcaseModel: SortFilterProxyModel {
                    sourceModel: root.store.ownShowcaseCollectiblesModel
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
                privacyStore: root.store.privacyStore
                keychain: root.keychain
                passwordStrengthScoreFunction: root.sharedRootStore.getPasswordStrengthScore
                contentWidth: d.contentWidth
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.password)
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: ContactsView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                contactsStore: root.store.contactsStore
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
                ensUsernamesStore: root.store.ensUsernamesStore
                walletAssetsStore: root.walletAssetsStore
                contactsStore: root.store.contactsStore
                networkConnectionStore: root.networkConnectionStore
                profileContentWidth: d.contentWidth
                onConnectUsernameRequested: root.connectUsernameRequested(ensName)
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
                messagingStore: root.store.messagingStore
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

                rootStore: root.store
                tokensStore: root.tokensStore
                networkConnectionStore: root.networkConnectionStore
                assetsStore: root.walletAssetsStore
                collectiblesStore: root.collectiblesStore
                networksStore: root.networksStore

                myPublicKey: root.store.contactsStore.myPublicKey
                currencySymbol: root.sharedRootStore.currencyStore.currentCurrency
                emojiPopup: root.emojiPopup
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.wallet)
            }
            onLoaded: root.store.backButtonName = ""
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: AppearanceView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.appearance)
                contentWidth: d.contentWidth
                systemPalette: root.systemPalette
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: LanguageView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                languageSelectionEnabled: localAppSettings.translationsEnabled
                languageStore: root.store.languageStore
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

                notificationsStore: root.store.notificationsStore
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

                isProduction: production
                profileStore: root.store.profileStore
                devicesStore: root.store.devicesStore
                privacyStore: root.store.privacyStore
                advancedStore: root.store.advancedStore
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.syncingSettings)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: AdvancedView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                messagingStore: root.store.messagingStore
                advancedStore: root.store.advancedStore
                walletStore: root.store.walletStore
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

                store: QtObject {
                    readonly property bool isProduction: production

                    function checkForUpdates() {
                        return root.store.checkForUpdates()
                    }

                    function getCurrentVersion() {
                        return root.store.getCurrentVersion()
                    }

                    function getGitCommit() {
                        return root.store.getGitCommit()
                    }

                    function getStatusGoVersion() {
                        return root.store.getStatusGoVersion()
                    }

                    function qtRuntimeVersion() {
                        return SystemUtils.qtRuntimeVersion()
                    }

                    function getReleaseNotes() {
                        const link = isProduction ? "https://github.com/status-im/status-desktop/releases/tag/%1".arg(getCurrentVersion()) :
                                                    "https://github.com/status-im/status-desktop/commit/%1".arg(getGitCommit())

                        openLink(link)
                    }

                    function openLink(url) {
                        Global.openLink(url)
                    }
                }
            }
        }

        Loader {
            active: false
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: CommunitiesView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                profileSectionStore: root.store
                rootStore: root.globalStore
                currencyStore: root.currencyStore
                walletAssetsStore: root.walletAssetsStore
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.communitiesSettings)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            id: keycardView
            active: false
            asynchronous: true
            sourceComponent: KeycardView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                profileSectionStore: root.store
                keycardStore: root.store.keycardStore
                emojiPopup: root.emojiPopup
                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.keycard)
                mainSectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.keycard)
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
                isCentralizedMetricsEnabled: root.isCentralizedMetricsEnabled
                implicitWidth: parent.width
                implicitHeight: parent.height

                sectionTitle: settingsEntriesModel.getNameForSubsection(Constants.settingsSubsection.privacyAndSecurity)
                contentWidth: d.contentWidth
            }
        }
    }

    showRightPanel: d.isProfilePanelActive && d.sideBySidePreviewAvailable
    rightPanelWidth: d.rightPanelWidth
    rightPanel: d.isProfilePanelActive ? profileContainer.currentItem.sideBySidePreviewComponent : null

    Connections {
        target: root.store.keycardStore.keycardModule
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
            myKeyUid: store.profileStore.keyUid
            sharedKeycardModule: root.store.keycardStore.keycardModule.keycardSharedModule
            emojiPopup: root.emojiPopup

            // This connection ensures that when a PIN is chagned on Keycard, biometrics are updated (if enabled).
            // Should be removed/simplified when KeycardPopup is refactored to use KeycardServiceV2.
            // We put it here, because ProfileLayout has access to Keychain and it is also the only place
            // where KeycardPopup can be used to change PIN.
            Connections {
                target: root.store.keycardStore.keycardModule.keycardSharedModule

                function onKeycardPinChanged(pin) {
                    const keyUid = store.profileStore.keyUid
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
