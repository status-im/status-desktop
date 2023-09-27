import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import mainui 1.0
import AppLayouts.Communities.panels 1.0

import Storybook 1.0

SplitView {
    id: root
    SplitView.fillWidth: true

    Popups {
        popupParent: root
        rootStore: QtObject {}
    }

    EditSettingsPanel {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        name: communityEditor.name
        color: communityEditor.color
        logoImageData: communityEditor.image
        description: communityEditor.description
        bannerImageData: communityEditor.banner
        communityId: "0xdeadbeef"
        communityShardingEnabled: communityEditor.shardingEnabled
        communityShardIndex: communityEditor.shardIndex
        onCommunityShardIndexChanged: communityEditor.shardIndex = communityShardIndex
    }

    ScrollView {
         SplitView.minimumWidth: 300
         SplitView.preferredWidth: 300

         CommunityInfoEditor {
             id: communityEditor
             anchors.fill: parent
             colorVisible: true
         }
     }
}

// category: Panels
