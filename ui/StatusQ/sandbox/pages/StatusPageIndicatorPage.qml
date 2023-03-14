import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

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
