import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Containers

import "base"

OnboardingPageBase {
    id: root

    ColumnLayout {
        anchors {
            centerIn: parent
            verticalCenterOffset: 50
        }

        Label {
            text: qsTr("Welcome back")
            Layout.alignment: Qt.AlignHCenter
        }

        LayoutSpacer {
            Layout.preferredHeight: 210
        }
    }
}
