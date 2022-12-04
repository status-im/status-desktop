import QtQuick 2.14

import shared.stores 1.0

import NimModules 1.0

QtObject {
    id: root
    property ChatSectionChatContentInputArea gifProviderMock: ChatSectionChatContentInputArea { }
    property WalletSectionAccounts walletSectionAccountsMock: WalletSectionAccounts {}
    property WalletSectionCurrent walletSectionCurrent: WalletSectionCurrent {}
    property WalletSectionAllTokens walletSectionAllTokens: WalletSectionAllTokens {}
    property WalletSectionTransactions walletSectionTransactions: WalletSectionTransactions {}
    property ProfileSectionModule profileSectionModule: ProfileSectionModule {}
    property WalletSection walletSection: WalletSection {}
    property UserProfile userProfile: UserProfile {}
    property LocalAppSettings localAppSettings: LocalAppSettings {}
    property LocalAccountSensitiveSettings localAccountSensitiveSettings: LocalAccountSensitiveSettings {}
    property NetworksModule networksModule: NetworksModule {}
    property GlobalUtils globalUtils: GlobalUtils {}
    property WalletSectionSavedAddresses walletSectionSavedAddresses: WalletSectionSavedAddresses {}
    property CurrenciesStore currencyStore: CurrenciesStore {
        currentCurrency: root.walletSection.currentCurrency
    }

    Component.onCompleted: {
        RootStore.gifProvider =                      root.gifProviderMock
        RootStore.walletSectionAccountsProvider=     root.walletSectionAccountsMock
        RootStore.currentAccount=                    root.walletSectionCurrent
        RootStore.walletTokensModule=                root.walletSectionAllTokens
        RootStore.history=                           root.walletSectionTransactions
        RootStore.profileSectionModuleInst=          root.profileSectionModule
        RootStore.walletSectionInst=                 root.walletSection
        RootStore.userProfileInst=                   root.userProfile
        RootStore.appSettings=                       root.localAppSettings
        RootStore.accountSensitiveSettings=          root.localAccountSensitiveSettings
        RootStore.networksModuleInst=                root.networksModule
        RootStore.globalUtilsInst=                   root.globalUtils
        RootStore.walletSectionSavedAddressesInst=   root.walletSectionSavedAddresses
        RootStore.currencyStore=                     root.currencyStore
    }

    Component.onDestruction: {
        RootStore.gifProvider =                      {}
        RootStore.walletSectionAccountsProvider=     {}
        RootStore.currentAccount=                    {}
        RootStore.walletTokensModule=                {}
        RootStore.history=                           {}
        RootStore.profileSectionModuleInst=          {}
        RootStore.walletSectionInst=                 {}
        RootStore.userProfileInst=                   {}
        RootStore.appSettings=                       {}
        RootStore.accountSensitiveSettings=          {}
        RootStore.networksModuleInst=                {}
        RootStore.globalUtilsInst=                   {}
        RootStore.walletSectionSavedAddressesInst=   {}
    }
}
