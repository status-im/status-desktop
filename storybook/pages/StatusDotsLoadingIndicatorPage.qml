import QtQuick
import QtQuick.Layouts

import StatusQ.Components

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
