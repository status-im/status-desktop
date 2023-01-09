import QtQuick 2.14

import AppLayouts.Chat.layouts 1.0

SettingsPageLayout {
    id: root

    property var tokensModel

    signal mintCollectible(string address, string name, string symbol, string description, int supply,
                           bool infiniteSupply, bool transferable, bool selfDestruct, string network)

    property int viewWidth: 560 // by design

    CommunityMintTokenPanel {
        anchors.fill: parent
        tokensModel: root.tokensModel
        onMintCollectible: root.mintCollectible(address, name, symbol, description, supply,
                                                infiniteSupply, transferable, selfDestruct, network)
    }
}
