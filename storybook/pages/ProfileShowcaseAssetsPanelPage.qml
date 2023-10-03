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

    ListModel {
        id: assetsModel
        readonly property var data: [
            {
                name: "Decentraland",
                symbol: "MANA",
                enabledNetworkBalance: {
                    amount: 301,
                    symbol: "MANA"
                },
                changePct24hour: -2.1,
                visibleForNetworkWithPositiveBalance: true
            },
            {
                name: "Ave Maria",
                symbol: "AAVE",
                enabledNetworkBalance: {
                    amount: 23.3,
                    symbol: "AAVE"
                },
                changePct24hour: 4.56,
                visibleForNetworkWithPositiveBalance: true
            },
            {
                name: "Polymorphism",
                symbol: "POLY",
                enabledNetworkBalance: {
                    amount: 3590,
                    symbol: "POLY"
                },
                changePct24hour: -11.6789,
                visibleForNetworkWithPositiveBalance: true
            },
            {
                name: "Common DDT",
                symbol: "CDT",
                enabledNetworkBalance: {
                    amount: 1000,
                    symbol: "CDT"
                },
                changePct24hour: 0,
                visibleForNetworkWithPositiveBalance: true
            },
            {
                name: "Makers' choice",
                symbol: "MKR",
                enabledNetworkBalance: {
                    amount: 1.3,
                    symbol: "MKR"
                },
                changePct24hour: -1,
                visibleForNetworkWithPositiveBalance: true
            },
            {
                name: "GetOuttaHere",
                symbol: "InvisibleHere",
                enabledNetworkBalance: {},
                changePct24hour: 0,
                visibleForNetworkWithPositiveBalance: false
            }
        ]
        Component.onCompleted: append(data)
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500
        ProfileShowcaseAssetsPanel {
            id: showcasePanel
            width: 500
            baseModel: assetsModel
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

// category: Panels

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14588-319260&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-238808&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-239912&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-240991&t=RkXAEv3G6mp3EUvl-0
