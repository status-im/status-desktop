import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook
import Models

import AppLayouts.Profile.panels

import StatusQ

import QtModelsToolkit
import SortFilterProxyModel

SplitView {
    id: root

    readonly property var tokenListsModel: TokenListsModel {}
    readonly property var flatTokensModel: FlatTokensModel {}
    readonly property var joinModel: LeftJoinModel {
        leftModel: root.flatTokensModel
        rightModel: NetworksModel.flatNetworks

        joinRole: "chainId"
    }
    readonly property var tokensProxyModel: SortFilterProxyModel {
        sourceModel: joinModel

        proxyRoles:  [
            ConstantRole {
                name: "explorerUrl"
                value: "https://status.im/"
            }
        ]
    }

    orientation: Qt.Vertical

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        SupportedTokenListsPanel {
            anchors.fill: parent
            tokenListsModel: root.tokenListsModel
            tokensListModel: root.tokensProxyModel
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Panels
// status: good
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18057%3A239410&mode=design&t=zSZ650alzNvE28GO-1
