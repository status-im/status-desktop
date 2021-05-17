import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Window {
    id: rootWindow
    width: 1024
    height: 840
    visible: true
    title: qsTr("Status App Sandbox")

    property ThemePalette lightTheme: StatusLightTheme {}
    property ThemePalette darkTheme: StatusDarkTheme { }

    ButtonGroup {
        id: topicsGroup
        buttons: tabs.children
    }

    ButtonGroup {
        buttons: switchRow.children
    }

    Flow {
        id: tabs
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.right: parent.right

        Button {
            text: "Reload QML"
            onClicked: app.restartQml()
        }
        Button {
            id: iconsTab
            checkable: true
            text: "Icons"
        }
        Button {
            id: controlsTab
            checkable: true
            text: "Controls"
        }
        Button {
            id: otherTab
            checkable: true
            text: "Other"
        }

        Button {
            id: buttonsTab
            checkable: true
            text: "Buttons"
        }
    }



    ScrollView {
        width: parent.width
        anchors.top: tabs.bottom
        anchors.bottom: parent.bottom
        contentHeight: rootWindow.height * rootWindow.factor
        contentWidth: rootWindow.width * rootWindow.factor
        clip: true


        Rectangle {
            id: lightThemeBg

            width: rootWindow.width
            height: parent.height
            color: Theme.palette.baseColor5
            clip: true
            scale: rootWindow.factor

            Loader {
                active: true
                anchors.centerIn: parent

                sourceComponent: {
                    switch(topicsGroup.checkedButton) {
                    case iconsTab:
                        return iconsComponent;
                    case controlsTab:
                        return controlsComponent;
                    case otherTab:
                        return othersComponent;
                    case buttonsTab:
                        return buttonsComponent;
                    default:
                        return null;
                    }
                }
            }
            Row {
                id: switchRow
                scale: 0.8
                anchors.right: parent.right
                anchors.top: parent.top

                Button {
                    checkable: true
                    checked: true
                    text: "Light Theme"
                    onCheckedChanged: {
                        if (checked) {
                            Theme.setTheme(lightTheme)
                        }
                    }
                }

                Button {
                    checkable: true
                    text: "Dark Theme"
                    onCheckedChanged: {
                        if (checked) {
                            Theme.setTheme(darkTheme)
                        }
                    }
                }
            }
        }
    }

    readonly property real maxFactor: 2.0
    readonly property real minFactor: 0.5

    property real factor: 1.0
    Action {
        shortcut: "CTRL+="
        onTriggered: {
            if (rootWindow.factor < 2.0)
                rootWindow.factor += 0.2
        }
    }

    Action {
        shortcut: "CTRL+-"
        onTriggered: {
            if (rootWindow.factor > 0.5)
                rootWindow.factor -= 0.2
        }
    }

    Action {
        shortcut: "CTRL+0"
        onTriggered: {
            rootWindow.factor = 1.0
        }
    }

    Component {
        id: iconsComponent
        Icons {
            anchors.centerIn: parent
            iconColor: Theme.palette.primaryColor1
        }
    }

    Component {
        id: controlsComponent
        Controls {
            anchors.centerIn: parent
            theme: Theme.palette
        }
    }

    Component {
        id: othersComponent
        Others {
            anchors.centerIn: parent
            theme: Theme.palette
        }
    }

    Component {
        id: buttonsComponent
        Buttons {
            anchors.centerIn: parent
        }
    }
}
