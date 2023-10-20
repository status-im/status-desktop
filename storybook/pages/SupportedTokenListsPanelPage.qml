import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0
import Models 1.0
import SortFilterProxyModel 0.2

import StatusQ.Core.Theme 0.1

import AppLayouts.Profile.panels 1.0
import AppLayouts.Profile.stores 1.0

import StatusQ 0.1

SplitView {
    id: root

    readonly property var sourcesOfTokensModel: SourceOfTokensModel {}
    readonly property var flatTokensModel: FlatTokensModel {}
    readonly property var joinModel: LeftJoinModel {
        leftModel: root.flatTokensModel
        rightModel: NetworksModel.allNetworks

        joinRole: "chainId"
    }
    readonly property var tokensProxyModel: SortFilterProxyModel {
        sourceModel: joinModel

        proxyRoles:  [
            ExpressionRole {
                name: "explorerUrl"
                expression: { return  "https://status.im/" }
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
            sourcesOfTokensModel: root.sourcesOfTokensModel
            tokensListModel: root.tokensProxyModel

            onItemClicked: logs.logEvent("SupportedTokenListsPanel::onItemClicked --> Key --> " + key)
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
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=18057%3A239410&mode=design&t=zSZ650alzNvE28GO-1
