import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1

import mainui 1.0
import utils 1.0

import shared.views 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    ManageTokensModel {
        id: assetsModel
    }

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: QtObject {}
    }

    AssetsView {
        id: assetsView
        SplitView.preferredWidth: 600
        SplitView.fillHeight: true
        assets: assetsModel
        filterVisible: ctrlFilterVisible.checked
        onAssetClicked: logs.logEvent("onAssetClicked", ["token"], [token.symbol, token.communityId])
        onSendRequested: logs.logEvent("onSendRequested", ["symbol"], arguments)
        onReceiveRequested: logs.logEvent("onReceiveRequested", ["symbol"], arguments)
        onSwitchToCommunityRequested: logs.logEvent("onSwitchToCommunityRequested", ["communityId"], arguments)
        onManageTokensRequested: logs.logEvent("onManageTokensRequested")
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumWidth: 150
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        ColumnLayout {
            Switch {
                id: ctrlFilterVisible
                text: "Filter visible"
                checked: true
            }
        }
    }
}

// category: Views
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17159-67977&mode=design&t=s5EXsh6Vi4nTNYUh-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17171-285559&mode=design&t=s5EXsh6Vi4nTNYUh-0
