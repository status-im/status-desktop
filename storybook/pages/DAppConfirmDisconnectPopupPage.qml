import QtCore
import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import Models
import Storybook

import shared.popups.walletconnect


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
