import QtQuick 2.15

import StatusQ.Core.Utils 0.1

import AppLayouts.Chat.stores 1.0
import AppLayouts.Communities.stores 1.0
import AppLayouts.Profile.helpers 1.0
import utils 1.0

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
