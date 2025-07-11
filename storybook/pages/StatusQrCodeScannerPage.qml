import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components

Item {
    id: root

    StatusQrCodeScanner {
        id: scanner

        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: row
    }

    RowLayout {
        id: row
        Label {
            text: scanner.lastTag
        }
    }
}

// category: Components
// status: good
