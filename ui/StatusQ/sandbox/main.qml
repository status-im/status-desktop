import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Window {
    id: rootWindow
    width: 640
    height: 480
    visible: true
    title: qsTr("Status App Sandbox")

    ButtonGroup {
        id: topicsGroup
        buttons: tabs.children
    }

    Flow {
        id: tabs
        width: parent.width
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
    }

    ScrollView {
        width: parent.width
        anchors.top: tabs.bottom
        anchors.bottom: parent.bottom
        contentHeight: rootWindow.height * rootWindow.factor
        contentWidth: rootWindow.width * rootWindow.factor
        clip: true
        SplitView {
            width: parent.width
            height: rootWindow.height
            handle: Item {}

            scale: rootWindow.factor

            Rectangle {
                id: lightThemeBg

                SplitView.minimumWidth: rootWindow.width / 2
                height: parent.height
                color: lightTheme.baseColor5
                clip: true

                Loader {
                    active: true
                    anchors.centerIn: parent
                    property var currentTheme: StatusLightTheme { id: lightTheme }

                    sourceComponent: {
                        switch(topicsGroup.checkedButton) {
                        case iconsTab:
                            return iconsComponent;
                        case controlsTab:
                            return controlsComponent;
                        case otherTab:
                            return othersComponent;
                        default:
                            return null;
                        }
                    }
                }

            }

            Rectangle {
                id: darkThemeBg

                SplitView.fillWidth: true
                SplitView.minimumWidth: rootWindow.width / 2
                height: parent.height
                color: darkTheme.baseColor5
                clip: true

                Loader {
                    active: true
                    anchors.centerIn: parent
                    property var currentTheme:  StatusDarkTheme { id: darkTheme }

                    sourceComponent: {
                        switch(topicsGroup.checkedButton) {
                        case iconsTab:
                            return iconsComponent;
                        case controlsTab:
                            return controlsComponent;
                        case otherTab:
                            return othersComponent;
                        default:
                            return null;
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
            iconColor: parent? parent.currentTheme.primaryColor1 : "#ffffff"
        }
    }

    Component {
        id: controlsComponent
        Controls {
            anchors.centerIn: parent
            theme: parent.currentTheme
        }
    }

    Component {
        id: othersComponent
        Others {
            anchors.centerIn: parent
            theme: parent.currentTheme
        }
    }
}
