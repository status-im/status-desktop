import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Qt.labs.settings 1.0

ColumnLayout {
    readonly property alias logsView: logsView
    default property alias controls: controlsPane.contentData

    spacing: 0

    TabBar {
        id: tabs

        Layout.fillWidth: true
        contentHeight: 30

        currentIndex: settings.logsOrControlsTab

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
        id: settings

        property alias logsOrControlsTab: tabs.currentIndex
    }
}
