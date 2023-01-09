import QtQuick 2.14

import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.stores 1.0

SettingsPageLayout {
    id: root

    property var tokensModel

    signal mintCollectible(string name, string description, int supply,
                           bool transferable, bool selfDestruct, string network)

    property int viewWidth: 560 // by design

    CommunityMintTokenPanel {
        anchors.fill: parent
        tokensModel: root.tokensModel
        onMintCollectible: root.mintCollectible(name, description, supply,
                                                transferable, selfDestruct, network)
    }
}
