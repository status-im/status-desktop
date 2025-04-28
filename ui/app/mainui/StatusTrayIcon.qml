import Qt.labs.platform 1.1

import StatusQ.Core.Theme 0.1

import utils 1.0

SystemTrayIcon {
    id: root

    property bool showRedDot: false

    signal activateApp()

    visible: true

    icon.source: {
        if (Qt.platform.os === Constants.windows) {
            return root.showRedDot ? Theme.svg("status-logo-white-windows-with-red-dot") : Theme.svg("status-logo-white-windows")
        }
        return root.showRedDot ? Theme.svg("status-logo-white-with-red-dot") : Theme.svg("status-logo-white")
    }
    icon.mask: Qt.platform.os !== Constants.windows

    onMessageClicked: {
        if (Qt.platform.os === Constants.windows) {
            root.activateApp()
        }
    }

    menu: Menu {
        MenuItem {
            text: qsTr("Open Status")
            onTriggered: {
                root.activateApp()
            }
        }

        MenuSeparator {
        }

        MenuItem {
            text: qsTr("Quit")
            onTriggered: Qt.exit(0)
        }
    }

    onActivated: {
        if (reason !== SystemTrayIcon.Context) {
            root.activateApp()
        }
    }
}
