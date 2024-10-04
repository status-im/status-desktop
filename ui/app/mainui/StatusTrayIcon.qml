import Qt.labs.platform 1.1

import utils 1.0

SystemTrayIcon {
    id: root

    property bool isProduction: true
    property bool showRedDot: false

    signal activateApp()

    visible: true


    icon.source: {
        if (Qt.platform.os === Constants.windows) {
            return root.showRedDot ? Style.svg("status-logo-white-windows-with-red-dot") : Style.svg("status-logo-white-windows")
        }
        return root.showRedDot ? Style.svg("status-logo-white-with-red-dot") : Style.svg("status-logo-white")
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
            onTriggered: {
                console.log('quit tray')
                Qt.quit()
            }
        }
    }

    onActivated: {
        if (reason !== SystemTrayIcon.Context) {
            root.activateApp()
        }
    }
}