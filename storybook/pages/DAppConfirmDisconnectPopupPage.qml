import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0

import Models 1.0
import Storybook 1.0

import shared.popups.walletconnect 1.0


Item {
    id: root

    DAppConfirmDisconnectPopup {
        anchors.centerIn: parent
        visible: true

        dappIcon: "https://opensea.io/static/images/logos/opensea-logo.svg"
        dappUrl: "opensea.io"
        dappName: "OpenSea"

        destroyOnClose: false

    }
}

// category: Popups
// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=3620-39188&t=py67JrptsxbHYMHW-0
