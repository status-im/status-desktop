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

        editable: communityEditor.isCommunityEditable
        owned: communityEditor.amISectionAdmin
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        CommunityInfoEditor{
            id: communityEditor
            anchors.fill: parent
        }
    }
}
