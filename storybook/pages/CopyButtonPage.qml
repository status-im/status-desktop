import QtQuick
import QtQuick.Layouts

import shared.controls

Item {
    RowLayout {
        anchors.centerIn: parent

        CopyButton {
            textToCopy: "Some text"
        }

        CopyButtonWithCircle {
            textToCopy: "Some text"
            successCircleVisible: true
        }
    }
}

// category: Controls
