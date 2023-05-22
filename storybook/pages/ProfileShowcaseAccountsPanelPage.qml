import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import mainui 1.0
import AppLayouts.Profile.panels 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Popups {
        popupParent: root
        rootStore: QtObject {}
    }

    readonly property string currentWallet: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"

    ListModel {
        id: accountsModel
        ListElement {
            name: "My Status Account"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7420"
            colorId: "primary"
            emoji: "🇨🇿"
            walletType: ""
        }
        ListElement {
            name: "testing (no emoji, colored, seed)"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7000"
            colorId: ""
            emoji: ""
            walletType: "seed"
        }
        ListElement {
            name: "My Bro's Account"
            address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421"
            colorId: "orange"
            emoji: "🇸🇰"
            walletType: "watch"
        }
        ListElement {
            name: "Keycard"
            address: "0xdeadbeef"
            colorId: "turquoise"
            emoji: ""
            walletType: "key"
        }
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500
        ProfileShowcaseAccountsPanel {
            id: showcasePanel
            width: 500
            baseModel: accountsModel
            currentWallet: root.currentWallet
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Button {
            text: "Reset (clear settings)"
            onClicked: showcasePanel.settings.reset()
        }
    }
}
