import QtQml
import QtQuick
import QtQuick.Layouts

import Status.Controls.Navigation

NavigationBar {
    implicitHeight: mainLayout.implicitHeight

    required property var sections

    ColumnLayout {
        id: mainLayout

        MacTrafficLights {
            Layout.margins: 13
        }

        Repeater {
            model: sections

            Loader {
                Layout.fillWidth: true

                sourceComponent: modelData.navButton
            }
        }
    }
}
