import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import mainui 1.0
import shared.stores 1.0
import AppLayouts.Communities.panels 1.0

import Storybook 1.0

SplitView {
    id: root
    SplitView.fillWidth: true

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: CommunityTokensStore {}
    }

    EditSettingsPanel {
        id: panel
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        name: communityEditor.name
        color: communityEditor.color
        logoImageData: communityEditor.image
        description: communityEditor.description
        bannerImageData: communityEditor.banner
        shardingEnabled: communityEditor.shardingEnabled
        shardIndex: communityEditor.shardIndex
        onShardIndexEdited: {
            panel.shardingInProgress = true
            communityEditor.shardIndex = shardIndex
            panel.shardingInProgress = false
        }
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

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba⎜Desktop?node-id=3132%3A383870&mode=dev
