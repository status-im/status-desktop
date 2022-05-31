import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Status.Containers
import Status.Controls.Navigation

Item {
    id: root

    signal userLoggedIn()

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        MacTrafficLights {
            Layout.margins: 13
        }

        LayoutSpacer {}
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "TODO OnboardingWorkflow"
        }
        Button {
            text: "Done"
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.userLoggedIn()
        }
        LayoutSpacer {}
    }
}
