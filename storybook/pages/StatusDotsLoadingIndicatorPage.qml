import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1

Item {
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 100

        StatusDotsLoadingIndicator {
            Layout.alignment: Qt.AlignHCenter

            dotsDiameter: 5
            duration: 500
            dotsColor: "blue"
        }

        StatusDotsLoadingIndicator {
            Layout.alignment: Qt.AlignHCenter

            dotsDiameter: 15
            duration: 1000
            dotsColor: "orange"
            spacing: 16
        }

        StatusDotsLoadingIndicator {
            Layout.alignment: Qt.AlignHCenter

            dotsDiameter: 30
            duration: 1500
            dotsColor: "green"
            spacing: 30
        }
    }
}

// category: Components
