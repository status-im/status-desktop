import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Containers

import "base"

SetupNewProfilePageBase {
    id: root

    ColumnLayout {
        anchors {
            centerIn: parent
            verticalCenterOffset: 50
        }

        Label {
            text: qsTr("Your profile")
            Layout.alignment: Qt.AlignHCenter
        }

        LayoutSpacer {
            Layout.preferredHeight: 210
        }

        TempTextInput {
            id: nameInput

            text: newAccountController.name
            Binding {
                target: newAccountController
                property: "name"
                value: nameInput.text
            }

            Layout.preferredWidth: 328
            Layout.preferredHeight: 44

            Layout.alignment: Qt.AlignHCenter

            font.pointSize: 23
        }

        LayoutSpacer {
            Layout.preferredHeight: 144
        }

        Button {
            text: qsTr("Next")

            Layout.alignment: Qt.AlignHCenter

            enabled: newAccountController.nameIsValid

            onClicked: root.pageDone()
        }
    }
}
