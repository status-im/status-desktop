import QtQuick 2.15
import QtQuick.Layouts 1.15

import shared.controls 1.0

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
