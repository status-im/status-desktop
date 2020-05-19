import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "./onboarding"
import "./app"

ApplicationWindow {
    id: applicationWindow
    width: 1232
    height: 770
    title: "Nim Status Client"
    visible: true
    font.family: "Inter"

    SystemTrayIcon {
        visible: true
        icon.source: "shared/img/status-logo.png"
        menu: Menu {
            MenuItem {
                text: qsTr("Quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: {
            applicationWindow.show()
            applicationWindow.raise()
            applicationWindow.requestActivate()
        }
    }

    OnboardingMain {
        id: onboarding
        visible: !app.visible
        anchors.fill: parent
    }

    AppMain {
        id: app
        // TODO: Set this to a logic result determining when we need to show the onboarding screens
        // Set to true to hide the onboarding screens manually
        // Set to false to show the onboarding screens manually
        visible: false // logic.accountResult !== ""
        anchors.fill: parent
    }
}




