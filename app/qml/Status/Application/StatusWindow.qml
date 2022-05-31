import QtQuick
import QtQuick.Layouts

import Qt.labs.settings

import Status.Application

import Status.Controls.Navigation
import Status.Core.Theme

import "Workflows"

/*! Administrative scope
 */
Window {
    id: root

    minimumWidth: 900
    minimumHeight: 600

    Component.onCompleted: {
        width: contentView.implicitWidth
        height: contentView.implicitHeight
    }

    visible: true
    title: qsTr(Qt.application.name)

    flags: Qt.FramelessWindowHint
    color: "transparent"

    ApplicationController {
        id: appController
    }

    Rectangle {
        id: windowBackground
        anchors.fill: parent
        radius: Style.geometry.appCornersRadius
        color: Theme.palette.appBackgroundColor

        StatusContentView {
            id: contentView

            anchors.fill: parent

            appState: appState
            appController: appController
        }
    }

    // Title gestures handler
    MouseArea {
        id: dragArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        height: Style.geometry.titleBarHeight
        // lower than contentView to not steal events from user controls
        z: contentView.z - 1

        onDoubleClicked: root.visibility === Window.Maximized ? Window.window.showNormal() : Window.window.showMaximized()

        property point prevMousePoint
        onPressed: (mouse) => prevMousePoint = Qt.point(mouse.x, mouse.y)
        onMouseXChanged: root.x += mouseX - prevMousePoint.x
        onMouseYChanged: root.y += mouseY - prevMousePoint.y
    }

    ApplicationState {
        id: appState
    }

    onClosing: function(close) {
        close.accepted = closeHandler.canApplicationClose()
    }

    CloseApplicationHandler {
        id: closeHandler

        quitOnClose: appSettings.quitOnClose

        onHideApplication: root.visible = false
    }

    ApplicationSettings {
        id: appSettings

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
