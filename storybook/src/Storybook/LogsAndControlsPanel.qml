import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

ColumnLayout {
    readonly property alias logsView: logsView
    default property alias controls: controlsPane.contentData

    spacing: 0

    TabBar {
        id: tabs

        Layout.fillWidth: true
        contentHeight: 30

        TabButton {
            text: "Events"
            width: implicitWidth
        }
        TabButton {
            text: "Controls"
            width: implicitWidth
        }
    }

    StackLayout {
        currentIndex: tabs.currentIndex

        Layout.fillWidth: true
        Layout.fillHeight: true

        LogsView {
            id: logsView

            clip: true
        }

        Pane {
            id: controlsPane
        }
    }

    Settings {
        property alias logsOrControlsTab: tabs.currentIndex
    }
}
