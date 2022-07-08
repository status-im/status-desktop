import QtQml

import Status.Controls.Navigation

QtObject {
    readonly property var sectionsList: [wallet, settings]
    readonly property ApplicationSection wallet: ApplicationSection {
        navButton: WalletButtonComponent
        content: WalletContentComponent

        component WalletButtonComponent: NavigationBarButton {
        }
        component WalletContentComponent: ApplicationContentView {
        }
    }
    readonly property ApplicationSection settings: ApplicationSection {
        navButton: SettingsButtonComponent
        content: SettingsContentComponent

        component SettingsButtonComponent: NavigationBarButton {
        }
        component SettingsContentComponent: ApplicationContentView {
        }
    }
}
