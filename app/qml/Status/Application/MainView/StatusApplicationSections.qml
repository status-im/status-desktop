import QtQml
import QtQuick
import QtQuick.Controls

import Status.Application
import Status.Application.Navigation
import Status.Controls.Navigation
import Status.Wallet
import Status.ChatSection as ChatSectionModule

Item {
    id: root

    required property ApplicationController appController
    property var sections: [chatSection, walletSection, settingsSection]

    ButtonGroup {
        id: oneSectionSelectedGroup
    }

    ApplicationSection {
        id: chatSection
        navigationSection: SimpleNavBarSection {
            name: "Chat"
            mutuallyExclusiveGroup: oneSectionSelectedGroup
        }
        content: ChatSectionModule.MainView {
            sectionId: root.appController.dbSettings.publicKey
        }
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
