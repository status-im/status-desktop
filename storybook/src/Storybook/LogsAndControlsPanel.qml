import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.settings

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
