import QtQuick
import QtQuick.Controls

import Status.Onboarding

import "base"

SetupNewProfilePageBase {
    id: root

    TempTextInput {
        id: confirmPasswordInput

        width: 416
        height: 44

        anchors {
            horizontalCenter: alignmentItem.horizontalCenter
            verticalCenter: alignmentItem.verticalCenter
            verticalCenterOffset: -baselineOffset
        }

        font.pointSize: 23
        verticalAlignment: TextInput.AlignVCenter
    }

    Label {
        id: errorLabel

        anchors {
            bottom: finalizeButton.top
            horizontalCenter: finalizeButton.horizontalCenter
            margins: 10
        }

        color: "red"
        text: qsTr("Something went wrong")
        visible: false
    }

    Button {
        id: finalizeButton
        text: qsTr("Finalize Status Password Creation")

        anchors {
            horizontalCenter: alignmentItem.horizontalCenter
            top: alignmentItem.bottom
            topMargin: 125
        }

        enabled: confirmPasswordInput.text === newAccountController.password

        onClicked: {
            // TODO have states to drive async creation
            errorLabel.visible = false
            finalizeButton.enabled = false
            busyIndicatorMouseArea.cursorShape = Qt.BusyCursor

            newAccountController.createAccount()
        }
    }

    Connections {
        target: newAccountController
        function onAccountCreatedAndLoggedIn() {
            busyIndicatorMouseArea.cursorShape = undefined
            root.pageDone()
        }
        function onAccountCreationError() {
            errorLabel.visible = true;
            busyIndicatorMouseArea.cursorShape = undefined
        }
    }

    MouseArea {
        id: busyIndicatorMouseArea

        anchors.fill: parent

        acceptedButtons: Qt.NoButton
        enabled: false
    }
}
