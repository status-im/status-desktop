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
        sectionsModel: root.mainModuleInst.sectionsModel
        ownAccounts: root.walletStore.ownAccounts
        collectibles: root.walletStore.collectibles
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
}
