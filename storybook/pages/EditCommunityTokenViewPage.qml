import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import AppLayouts.Communities.views 1.0

import Storybook 1.0
import Models 1.0

import utils 1.0

SplitView {

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            EditCommunityTokenView {
                anchors.fill: parent
                anchors.margins: 50
                isAssetView: isAssetBox.checked
                layer1Networks: NetworksModel.layer1Networks
                layer2Networks: NetworksModel.layer2Networks
                testNetworks: NetworksModel.testNetworks
                enabledNetworks: NetworksModel.enabledNetworks
                allNetworks: enabledNetworks
                accounts: WalletAccountsModel {}
                tokensModel: MintedTokensModel {}
                onPreviewClicked: logs.logEvent("EditCommunityTokenView::previewClicked")
            }
        }


        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText

            CheckBox {
                id: isAssetBox
                text: "Is Assets View?"
                checked: false
            }
        }
    }
}
