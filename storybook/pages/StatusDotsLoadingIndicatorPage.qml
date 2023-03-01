import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1


SplitView {
    id: root

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        ColumnLayout {
            anchors.margins: 100
            anchors.fill: parent
            spacing: 100

            StatusDotsLoadingIndicator {
                dotsDiameter: 5
                duration: 500
                dotsColor: "blue"
            }

            StatusDotsLoadingIndicator {
                dotsDiameter: 15
                duration: 1000
                dotsColor: "orange"
                spacing: 16
            }

            StatusDotsLoadingIndicator {
                dotsDiameter: 30
                duration: 1500
                dotsColor: "green"
                spacing: 30
            }

            // filler
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
