import QtQml
import QtQuick
import QtQuick.Controls

import Status.Application.Navigation
import Status.Controls.Navigation
import Status.Wallet

Item {
    property var sections: [walletSection, settingsSection]

    ButtonGroup {
        id: oneSectionSelectedGroup
    }

    ApplicationSection {
        id: walletSection
        navigationSection: SimpleNavBarSection {
            name: "Wallet"
            mutuallyExclusiveGroup: oneSectionSelectedGroup
        }
        content: WalletView {}
    }
    ApplicationSection {
        id: settingsSection
        navigationSection: SimpleNavBarSection {
            name: "Settings"
            mutuallyExclusiveGroup: oneSectionSelectedGroup
        }
        content: ApplicationContentView {
            Label {
                anchors.centerIn: parent
                text: "TODO Settings"
            }
        }
    }
}
