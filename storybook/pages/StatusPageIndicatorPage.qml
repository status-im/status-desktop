import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components

Item {
    Column {
        anchors.centerIn: parent
        spacing: 30

        RowLayout {
            width: parent.width
            Text {
                text: "Total pages:"
            }
            SpinBox {
                id: totalPages
                editable: true
                height: 30
                from: 1
                value: 5
            }
        }

        StatusPageIndicator {
            totalPages: totalPages.value

            onCurrentIndexChanged: {
                console.warn("selected page index is: ", currentIndex)
            }
        }
    }
}

// category: Components
// status: good
