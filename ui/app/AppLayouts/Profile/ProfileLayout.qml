import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.stores 1.0 as SharedStores
import shared.popups.keycard 1.0

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.stores 1.0

import "stores"
import "popups"
import "views"

import StatusQ.Core 0.1
import StatusQ.Layout 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

StatusSectionLayout {
    id: root

    objectName: "profileStatusSectionLayout"

    property ProfileSectionStore store
    property var globalStore
    property var systemPalette
    property var emojiPopup
    property var networkConnectionStore
    required property TokensStore tokensStore

    backButtonName: root.store.backButtonName
    notificationCount: activityCenterStore.unreadNotificationsCount
    hasUnseenNotifications: activityCenterStore.hasUnseenNotifications

    onNotificationButtonClicked: Global.openActivityCenterPopup()
    onBackButtonClicked: {
        switch (Global.settingsSubsection) {
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
        Global.settingsSubSubsection = -1
    }

    Component.onCompleted: {
        profileContainer.currentIndex = -1
        profileContainer.currentIndex = Qt.binding(() => Global.settingsSubsection)
        root.store.devicesStore.loadDevices() // Load devices to get non-paired number for badge
    }

    QtObject {
        id: d

        readonly property int leftMargin: 64

        readonly property int contentWidth: 560
    }

    headerBackground: AccountHeaderGradient {
        width: parent.width
        overview: root.store.walletStore.selectedAccount
        visible: profileContainer.currentIndex === Constants.settingsSubsection.wallet && !!root.store.walletStore.selectedAccount
    }

    leftPanel: LeftTabView {
        store: root.store
        anchors.fill: parent
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
        anchors.leftMargin: d.leftMargin

        currentIndex: Global.settingsSubsection

        onCurrentIndexChanged: {
            if (!!children[currentIndex] && !children[currentIndex].active)
                children[currentIndex].active = true

            root.store.backButtonName = ""

            if (currentIndex === Constants.settingsSubsection.contacts) {
                root.store.backButtonName = root.store.getNameForSubsection(Constants.settingsSubsection.messaging)
            } else if (currentIndex === Constants.settingsSubsection.about_privacy || currentIndex === Constants.settingsSubsection.about_terms) {
                root.store.backButtonName = root.store.getNameForSubsection(Constants.settingsSubsection.about)
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
                implicitWidth: parent.width
                implicitHeight: parent.height

                walletStore: root.store.walletStore
                profileStore: root.store.profileStore
                privacyStore: root.store.privacyStore
                contactsStore: root.store.contactsStore
                communitiesModel: root.store.communitiesList
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.profile)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: ContactsView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                contactsStore: root.store.contactsStore
                sectionTitle: qsTr("Contacts")
                contentWidth: d.contentWidth
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
                contactsStore: root.store.contactsStore
                stickersStore: root.store.stickersStore
                networkConnectionStore: root.networkConnectionStore
                profileContentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: MessagingView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                advancedStore: root.store.advancedStore
                messagingStore: root.store.messagingStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.messaging)
                contactsStore: root.store.contactsStore
                contentWidth: d.contentWidth
            }
        }

        Loader {
            id: walletView
            active: false
            asynchronous: true
            sourceComponent: WalletView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                rootStore: root.store
                walletStore: root.store.walletStore
                tokensStore: root.tokensStore
                emojiPopup: root.emojiPopup
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.wallet)
                contentWidth: d.contentWidth
            }
            onLoaded: root.store.backButtonName = ""
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: AppearanceView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                appearanceStore: root.store.appearanceStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.appearance)
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

                languageStore: root.store.languageStore
                currencyStore: SharedStores.RootStore.currencyStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.language)
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
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.notifications)
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
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.syncingSettings)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: BrowserView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                store: root.store
                accountSettings: localAccountSensitiveSettings
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.browserSettings)
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
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.advanced)
                contentWidth: d.contentWidth
            }
        }

        Loader {
            active: false
            asynchronous: true
            sourceComponent: AboutView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.about)
                contentWidth: d.contentWidth

                store: QtObject {
                    readonly property bool isProduction: production

                    function checkForUpdates() {
                        return root.store.checkForUpdates()
                    }

                    function getCurrentVersion() {
                        return root.store.getCurrentVersion()
                    }

                    function getStatusGoVersion() {
                        return root.store.getStatusGoVersion()
                    }

                    function getReleaseNotes() {
                        const link = isProduction ? "https://github.com/status-im/status-desktop/releases/tag/%1" :
                                                    "https://github.com/status-im/status-desktop/commit/%1"

                        openLink(link.arg(getCurrentVersion()))
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
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.communitiesSettings)
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
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.keycard)
                mainSectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.keycard)
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
                sectionTitle: "Status Software Terms of Use"
                contentWidth: d.contentWidth

                StatusBaseText {
                    width: d.contentWidth
                    wrapMode: Text.Wrap
                    textFormat: Text.MarkdownText
                    text: SQUtils.StringUtils.readTextFile(":/imports/assets/docs/terms-of-use.mdwn")
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
                sectionTitle: "Status Software Privacy Statement"
                contentWidth: d.contentWidth

                StatusBaseText {
                    width: d.contentWidth
                    wrapMode: Text.Wrap
                    textFormat: Text.MarkdownText
                    text: SQUtils.StringUtils.readTextFile(":/imports/assets/docs/privacy.mdwn")
                }
            }
        }
    }

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
            sharedKeycardModule: root.store.keycardStore.keycardModule.keycardSharedModule
            emojiPopup: root.emojiPopup
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
