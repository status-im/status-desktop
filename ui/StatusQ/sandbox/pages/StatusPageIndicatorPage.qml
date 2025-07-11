import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme

Item {
    id: root
    width: 800
    height: 100

    Column {
        anchors.fill: parent
        spacing: 30

        Grid {
            columns: 2
            rowSpacing: 20
            columnSpacing: 50

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
