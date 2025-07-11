import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components
import Storybook
import utils

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
