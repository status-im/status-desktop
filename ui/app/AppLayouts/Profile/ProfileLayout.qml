import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

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

        readonly property int topMargin: secureYourSeedPhrase.visible ? secureYourSeedPhrase.height : 0
        readonly property int bottomMargin: 56
        readonly property int leftMargin: 48
        readonly property int rightMargin: 48

        readonly property int contentWidth: 560
    }

    leftPanel: LeftTabView {
        id: leftTab
        store: profileView.store
        anchors.fill: parent
        anchors.topMargin: d.topMargin
        onMenuItemClicked: {
            if (profileContainer.currentItem.dirty) {
                event.accepted = true;
                profileContainer.currentItem.notifyDirty();
            }
        }
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

            readonly property var currentItem: (currentIndex >= 0 && currentIndex < children.length) ? children[currentIndex] : null

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
                implicitWidth: parent.width
                implicitHeight: parent.height

                walletStore: profileView.store.walletStore
                profileStore: profileView.store.profileStore
                privacyStore: profileView.store.privacyStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.profile)
                contentWidth: d.contentWidth
            }

            ContactsView {
                implicitWidth: parent.width
                implicitHeight: parent.height
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
                implicitWidth: parent.width
                implicitHeight: parent.height

                ensUsernamesStore: profileView.store.ensUsernamesStore
                contactsStore: profileView.store.contactsStore
                stickersStore: profileView.store.stickersStore

                profileContentWidth: d.contentWidth
            }

            MessagingView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                messagingStore: profileView.store.messagingStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.messaging)
                contactsStore: profileView.store.contactsStore
                contentWidth: d.contentWidth
            }

            WalletView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                walletStore: profileView.store.walletStore
                emojiPopup: profileView.emojiPopup
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.wallet)
                contentWidth: d.contentWidth
            }

            AppearanceView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                appearanceStore: profileView.store.appearanceStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.appearance)
                contentWidth: d.contentWidth
                systemPalette: profileView.systemPalette
            }

            LanguageView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                languageStore: profileView.store.languageStore
                currencyStore: profileView.store.walletStore.currencyStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.language)
                contentWidth: d.contentWidth
            }

            NotificationsView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                notificationsStore: profileView.store.notificationsStore
                devicesStore: profileView.store.devicesStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.notifications)
                contentWidth: d.contentWidth
            }

            DevicesView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                devicesStore: profileView.store.devicesStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.devicesSettings)
                contentWidth: d.contentWidth
            }

            BrowserView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                store: profileView.store
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.browserSettings)
                contentWidth: d.contentWidth
            }

            AdvancedView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                advancedStore: profileView.store.advancedStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.advanced)
                contentWidth: d.contentWidth
            }

            AboutView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                store: profileView.store
                globalStore: profileView.globalStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.about)
                contentWidth: d.contentWidth
            }

            CommunitiesView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                profileSectionStore: profileView.store
                rootStore: profileView.globalStore
                contactStore: profileView.store.contactsStore
                sectionTitle: profileView.store.getNameForSubsection(Constants.settingsSubsection.communitiesSettings)
                contentWidth: d.contentWidth
            }
        }
    } // Item
    ModuleWarning {
        id: secureYourSeedPhrase
        width: parent.width
        visible: {
          if (profileContainer.currentIndex !== Constants.settingsSubsection.profile) {
            return false
          }
          if (profileView.store.profileStore.userDeclinedBackupBanner) {
            return false
          }
          return !profileView.store.profileStore.privacyStore.mnemonicBackedUp
        }
        color: Style.current.red
        btnWidth: 100
        text: qsTr("Secure your seed phrase")
        btnText: qsTr("Back up now")

        onClick: function(){
            Global.openBackUpSeedPopup();
        }

        onClosed: {
            profileView.store.profileStore.userDeclinedBackupBanner = true
        }

    }
} // StatusAppTwoPanelLayout
