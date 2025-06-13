import QtQuick

import StatusQ.Core.Utils

import AppLayouts.Chat.stores
import AppLayouts.Communities.stores
import AppLayouts.Profile.helpers
import utils

import SortFilterProxyModel

QtObject {
    id: root

    property var mainModuleInst: mainModule
    property var profileSectionModuleInst: profileSectionModule

    property ContactsStore contactsStore: ContactsStore {}

    property AdvancedStore advancedStore: AdvancedStore {
        walletModule: profileSectionModuleInst.walletModule
        advancedModule: profileSectionModuleInst.advancedModule
    }

    property MessagingStore messagingStore: MessagingStore {
        privacyModule: profileSectionModuleInst.privacyModule
        syncModule: profileSectionModuleInst.syncModule
        wakuModule: profileSectionModuleInst.wakuModule
    }

    property DevicesStore devicesStore: DevicesStore {
        devicesModule: profileSectionModuleInst.devicesModule
    }

    property NotificationsStore notificationsStore: NotificationsStore {
        notificationsModule: profileSectionModuleInst.notificationsModule
    }

    property LanguageStore languageStore: LanguageStore {
        languageModule: profileSectionModuleInst.languageModule
    }

    property ProfileStore profileStore: ProfileStore {
        profileModule: profileSectionModuleInst.profileModule
    }

    property PrivacyStore privacyStore: PrivacyStore {
        privacyModule: profileSectionModuleInst.privacyModule
    }

    property EnsUsernamesStore ensUsernamesStore: EnsUsernamesStore {
        ensUsernamesModule: profileSectionModuleInst.ensUsernamesModule
    }

    property WalletStore walletStore: WalletStore {
        walletModule: profileSectionModuleInst.walletModule
    }

    property KeycardStore keycardStore: KeycardStore {
        keycardModule: profileSectionModuleInst.keycardModule
    }

    property var stickersModuleInst: stickersModule
    property StickersStore stickersStore: StickersStore {
        stickersModule: stickersModuleInst
    }

    property AboutStore aboutStore: AboutStore {}

    property var communitiesModuleInst: Global.appIsReady? communitiesModule : null
                            
    readonly property var communitiesList: SortFilterProxyModel {
        sourceModel: root.mainModuleInst.sectionsModel
        filters: ValueFilter {
            roleName: "sectionType"
            value: Constants.appSection.community
        }
    }
    property var communitiesProfileModule: profileSectionModuleInst.communitiesModule

    readonly property alias ownShowcaseCommunitiesModel: ownShowcaseModels.adaptedCommunitiesSourceModel
    readonly property alias ownShowcaseAccountsModel: ownShowcaseModels.adaptedAccountsSourceModel
    readonly property alias ownShowcaseCollectiblesModel: ownShowcaseModels.adaptedCollectiblesSourceModel
    readonly property alias ownShowcaseSocialLinksModel: ownShowcaseModels.adaptedSocialLinksSourceModel

    readonly property alias contactShowcaseCommunitiesModel: contactShowcaseModels.adaptedCommunitiesSourceModel
    readonly property alias contactShowcaseAccountsModel: contactShowcaseModels.adaptedAccountsSourceModel
    readonly property alias contactShowcaseCollectiblesModel: contactShowcaseModels.adaptedCollectiblesSourceModel
    readonly property alias contactShowcaseSocialLinksModel: contactShowcaseModels.adaptedSocialLinksSourceModel

    function requestContactShowcase(address) {
        root.contactsStore.requestProfileShowcase(address)
    }

    function requestOwnShowcase() {
        root.profileStore.requestProfileShowcasePreferences()
    }

    readonly property QObject d: QObject {
        ProfileShowcaseSettingsModelAdapter {
            id: ownShowcaseModels
            communitiesSourceModel: root.communitiesList
            communitiesShowcaseModel: root.profileStore.showcasePreferencesCommunitiesModel
            accountsSourceModel: root.walletStore.ownAccounts
            accountsShowcaseModel: root.profileStore.showcasePreferencesAccountsModel
            collectiblesSourceModel: root.walletStore.collectibles
            collectiblesShowcaseModel: root.profileStore.showcasePreferencesCollectiblesModel
            socialLinksSourceModel: root.profileStore.showcasePreferencesSocialLinksModel
        }

        ProfileShowcaseModelAdapter {
            id: contactShowcaseModels
            communitiesSourceModel: root.communitiesModuleInst.model
            communitiesShowcaseModel: root.contactsStore.showcaseContactCommunitiesModel
            accountsSourceModel: root.contactsStore.showcaseContactAccountsModel
            collectiblesSourceModel: root.contactsStore.showcaseCollectiblesModel
            collectiblesShowcaseModel: root.contactsStore.showcaseContactCollectiblesModel
            socialLinksSourceModel: root.contactsStore.showcaseContactSocialLinksModel

            isAddressSaved: (address) => {
                return false
            }
            isShowcaseLoading: root.contactsStore.isShowcaseForAContactLoading
        }
    }
}
