import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import Storybook
import utils

SplitView {
    id: root

    orientation: Qt.Horizontal

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusBetaTag {
            anchors.centerIn: parent
            tooltipText: ctrlTooltip.text
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 400

        SplitView.fillHeight: true

        RowLayout {
            Label {
                text: "Tooltip:"
            }
            TextField {
                id: ctrlTooltip
                text: "Hic sunt leones!!!"
            }
        }
    }
}

// category: Components

// https://www.figma.com/design/bZJgpgchRfMGIKNBoyYUh8/Experimental-tag?node-id=2-15420&t=F3R5CcOZSOMWYtkk-0
