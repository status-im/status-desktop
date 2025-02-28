import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1

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
