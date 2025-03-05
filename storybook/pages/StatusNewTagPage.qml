import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import Storybook 1.0
import utils 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusNewTag {
            anchors.centerIn: parent
            tooltipText: ctrlTooltip.text
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 400

        SplitView.fillHeight: true

        ColumnLayout {
            Label {
                text: "Tooltip:"
            }
            TextField {
                id: ctrlTooltip
                text: "New feature is incoming soon!"
            }
        }
    }
}

// category: Components
