import QtQuick
import QtQuick.Controls

import Qt.labs.platform

import Status.Assets

SystemTrayIcon {
    id: root

    property bool production: true

    signal showApplication()

    visible: true
    icon.source: {
        if (production)
            return Qt.platform.os === "osx" ? Resources.svg("status-logo-icon") : Resources.png("status-logo")
        else
            return Resources.svg("status-logo-dark")
    }
    icon.mask: false

    menu: Menu {
        MenuItem {
            text: qsTr("Open Status")
            onTriggered: root.showApplication()
        }

        MenuSeparator {
        }

        MenuItem {
            text: qsTr("Quit")
            onTriggered: Qt.quit()
        }
    }

    onActivated: function (reason) {
        if (reason !== SystemTrayIcon.Context && Qt.platform.os !== "osx")
            root.showApplication()
    }
}
