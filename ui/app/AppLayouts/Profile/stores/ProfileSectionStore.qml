import QtQuick 2.15

import StatusQ.Core.Utils 0.1

import AppLayouts.Chat.stores 1.0
import AppLayouts.Communities.stores 1.0
import AppLayouts.Profile.helpers 1.0
import utils 1.0

QtObject {
    id: root

    readonly property QtObject _d: QtObject {
        id: d

        readonly property var mainModuleInst: mainModule
        readonly property var profileSectionModuleInst: profileSectionModule
    }

    property ProfileStore profileStore: ProfileStore {
        profileModule: d.profileSectionModuleInst.profileModule
        sectionsModel: d.mainModuleInst.sectionsModel
        ownAccounts: root.walletStore.ownAccounts
        collectibles: root.walletStore.collectibles
    }

    property KeycardStore keycardStore: KeycardStore {
        keycardModule: d.profileSectionModuleInst.keycardModule
    }

    property EnsUsernamesStore ensUsernamesStore: EnsUsernamesStore {
        ensUsernamesModule: d.profileSectionModuleInst.ensUsernamesModule
    }

    property DevicesStore devicesStore: DevicesStore {
        devicesModule: d.profileSectionModuleInst.devicesModule
    }

    property PrivacyStore privacyStore: PrivacyStore {
        privacyModule: d.profileSectionModuleInst.privacyModule
    }

    property NotificationsStore notificationsStore: NotificationsStore {
        notificationsModule: d.profileSectionModuleInst.notificationsModule
    }

    property LanguageStore languageStore: LanguageStore {
        languageModule: d.profileSectionModuleInst.languageModule
    }

    property AdvancedStore advancedStore: AdvancedStore {
        walletModule: d.profileSectionModuleInst.walletModule
        advancedModule: d.profileSectionModuleInst.advancedModule
    }

    property AboutStore aboutStore: AboutStore {}

    // TODO: Move up to `RootStore`
    property ContactsStore contactsStore: ContactsStore {}

    // TODO: Move to wallet related store
    property WalletStore walletStore: WalletStore {
        walletModule: d.profileSectionModuleInst.walletModule
    }
}
