import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import Storybook 1.0
import utils 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusExperimentalTag {
            id: tag
            anchors.centerIn: parent
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 400

        SplitView.fillHeight: true
    }
}

// category: Components

// https://www.figma.com/design/bZJgpgchRfMGIKNBoyYUh8/Experimental-tag?node-id=2-15420&t=F3R5CcOZSOMWYtkk-0
