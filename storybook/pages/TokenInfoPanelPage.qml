import QtQuick

import Models

import AppLayouts.Communities.panels
import AppLayouts.Communities.helpers

import utils

Item {
    id: root

    TokenInfoPanel {
        anchors.fill: frame

        token: TokenObject {
            accountName: "My Account"
            chainName: "Arbitrum Arbitrum Arbitrum Arbitrum Arbitrum Arbitrum Arbitrum Arbitrum Arbitrum Arbitrum Arbitrum Arbitrum"
            name: "Owner-CatsComm"
            symbol: "OWNCAT"
            type: Constants.TokenType.ERC721
            accountAddress: "0x012304123"
            chainId: 1
            chainIcon: ModelsData.networks.arbitrum
            artworkSource: ModelsData.collectibles.doodles
            privilegesLevel: Constants.TokenPrivilegesLevel.Owner
            transferable: true
            remotelyDestruct: false
            supply: "1"
            infiniteSupply: false
            color: "red"
            description: "This is the %1 Owner token. The hodler of this collectible has ultimate control over %1 Community token administration."
        }
    }

    Rectangle {
        id: frame

        anchors.fill: parent
        anchors.margins: 120
        border.color: "blue"
        color: "transparent"
    }
}

// category: Panels
// status: good
