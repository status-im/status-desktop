import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0

import "stores"
import "popups"
import "views"

import StatusQ.Layout 0.1
import StatusQ.Controls 0.1

StatusAppTwoPanelLayout {
    id: profileView

    property ProfileSectionStore store
    property var globalStore
    property var systemPalette
    property var emojiPopup

    Component.onCompleted: {
        Global.privacyModuleInst = store.privacyStore.privacyModule
    }

    QtObject {
        id: d

        readonly property int topMargin: 0
        readonly property int bottomMargin: 56
        readonly property int leftMargin: 48
        readonly property int rightMargin: 48

        readonly property int contentWidth: 560
    }

    leftPanel: LeftTabView {
        id: leftTab
        store: profileView.store
        anchors.fill: parent
    }

    rightPanel: Item {
        anchors.fill: parent

        StatusBanner {
            id: banner
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            visible: profileContainer.currentIndex === Constants.settingsSubsection.wallet &&
                     profileView.store.walletStore.areTestNetworksEnabled
            type: StatusBanner.Type.Danger
            statusText: {
                if(profileContainer.currentIndex === Constants.settingsSubsection.wallet &&
                        profileView.store.walletStore.areTestNetworksEnabled)
                    return qsTr("Testnet mode is enabled. All balances, transactions and dApp interactions will be on testnets.")
                return ""
            }
        }

        StackLayout {
            id: profileContainer

            anchors.top: banner.visible? banner.bottom : parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: d.topMargin
            anchors.bottomMargin: d.bottomMargin
            anchors.leftMargin: d.leftMargin
            anchors.rightMargin: d.rightMargin

            currentIndex: Global.settingsSubsection

            onCurrentIndexChanged: {
                if(visibleChildren[0] === ensContainer){
                    ensContainer.goToStart();
                }
            }

            MyProfileView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                profileStore: profileView.store.profileStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.profile)
                contentWidth: d.contentWidth
            }

            ContactsView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                contactsStore: profileView.store.contactsStore
                sectionTitle: qsTr("Contacts")
                contentWidth: d.contentWidth

                backButtonName: profileView.store.getNameForSubsection(Constants.settingsSubsection.messaging)

                onBackButtonClicked: {
                    Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.messaging)
                }
            }

            EnsView {
                // TODO: we need to align structure for the entire this part using `SettingsContentBase` as root component
                // TODO: handle structure for this subsection to match style used in onther sections
                // using `SettingsContentBase` component as base.
                id: ensContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                ensUsernamesStore: profileView.store.ensUsernamesStore
                contactsStore: profileView.store.contactsStore
                stickersStore: profileView.store.stickersStore

                profileContentWidth: d.contentWidth
            }

            MessagingView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                messagingStore: profileView.store.messagingStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.messaging)
                contentWidth: d.contentWidth
            }

            WalletView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                walletStore: profileView.store.walletStore
                emojiPopup: profileView.emojiPopup
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.wallet)
                contentWidth: d.contentWidth
            }

            PrivacyView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                privacyStore: profileView.store.privacyStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.privacyAndSecurity)
                contentWidth: d.contentWidth
            }

            AppearanceView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                appearanceStore: profileView.store.appearanceStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.appearance)
                contentWidth: d.contentWidth
                systemPalette: profileView.systemPalette
            }

            LanguageView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                languageStore: profileView.store.languageStore
                currencyStore: profileView.store.walletStore.currencyStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.language)
                contentWidth: d.contentWidth
            }

            NotificationsView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                notificationsStore: profileView.store.notificationsStore
                devicesStore: profileView.store.devicesStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.notifications)
                contentWidth: d.contentWidth
            }

            SyncingView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                emojiPopup: profileView.emojiPopup
                devicesStore: profileView.store.devicesStore
                profileStore: profileView.store.profileStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.devicesSettings)
                contentWidth: d.contentWidth
            }

            BrowserView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                store: profileView.store
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.browserSettings)
                contentWidth: d.contentWidth
            }

            AdvancedView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                advancedStore: profileView.store.advancedStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.advanced)
                contentWidth: d.contentWidth
            }

            AboutView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                store: profileView.store
                globalStore: profileView.globalStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.about)
                contentWidth: d.contentWidth
            }

            CommunitiesView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                profileSectionStore: profileView.store
                rootStore: profileView.globalStore
                contactStore: profileView.store.contactsStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.communitiesSettings)
                contentWidth: d.contentWidth
            }
        }
    }
}
