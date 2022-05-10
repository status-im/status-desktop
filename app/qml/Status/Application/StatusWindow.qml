import QtQuick
import QtQuick.Layouts

import Qt.labs.settings

import Status.Application

/** Administrative scope
 */
Window {
    id: root

    minimumWidth: 900
    minimumHeight: 600

    Component.onCompleted: {
        width: mainLayout.implicitWidth
        height: mainLayout.implicitHeight
    }

    visible: true
    title: qsTr(Qt.application.name)

    flags: Qt.FramelessWindowHint

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        // TODO: nav-bar?
//        StatusAppNavBar {
//        }

        StatusContentView {
           Layout.fillWidth: true
           Layout.fillHeight: true
        }
    }

    ApplicationController {
        id: appController
    }

    Settings {
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height

        // TODO: set this in non-deployment to the development "Status" folder
        //fileName: `${appController.userSettings.directory}/appController.userSettings.fileName`
    }

    MainShortcuts {
        window: root
        enableHideWindow: true // TODO: Only if browser selected
    }
}
