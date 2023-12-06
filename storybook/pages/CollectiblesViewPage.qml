import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1

import mainui 1.0
import utils 1.0

import AppLayouts.Wallet.views 1.0

import shared.views 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    ManageCollectiblesModel {
        id: collectiblesModel
    }

    ListModel {
        id: emptyModel
    }

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: QtObject {}
    }

    CollectiblesView {
        id: assetsView
        SplitView.preferredWidth: 600
        SplitView.fillHeight: true
        collectiblesModel: ctrlEmptyModel.checked ? emptyModel : collectiblesModel
        filterVisible: ctrlFilterVisible.checked
        onCollectibleClicked: logs.logEvent("onCollectibleClicked", ["chainId", "contractAddress", "tokenId", "uid"], arguments)
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
            Switch {
                id: ctrlEmptyModel
                text: "Empty model"
            }
        }
    }
}

// category: Views
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=19558-95270&mode=design&t=ShZOuMRfiIIl2aR8-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=19558-96427&mode=design&t=ShZOuMRfiIIl2aR8-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=19087%3A293357&mode=dev
