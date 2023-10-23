import QtQuick 2.14
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Communities.panels 1.0

SplitView {
    id: root
    SplitView.fillWidth: true

    OverviewSettingsPanel {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        name: communityEditor.name
        description: communityEditor.description
        logoImageData: communityEditor.image
        color: communityEditor.color
        bannerImageData: communityEditor.banner

        editable: communityEditor.isCommunityEditable
        isOwner: communityEditor.amISectionAdmin
        communitySettingsDisabled: !editable

        shardingEnabled: communityEditor.shardingEnabled
        shardIndex: communityEditor.shardIndex

        isPendingOwnershipRequest: pendingOwnershipSwitch.checked
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            CommunityInfoEditor{
                id: communityEditor
                anchors.fill: parent
            }

            Switch {
                id: pendingOwnershipSwitch
                text: "Is there a pending transfer ownership request?"
                checked: true
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba⎜Desktop?type=design&node-id=31229-627216&mode=design&t=KoQOW7vmoNc7f41m-0
