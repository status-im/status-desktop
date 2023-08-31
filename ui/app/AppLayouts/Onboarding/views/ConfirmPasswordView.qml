import QtQuick 2.0
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1

import shared.views 1.0
import utils 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        passwordView.forceInputFocus()
    }

    QtObject {
        id: d

        property bool submitEnabled: !submitBtn.loading && passwordView.passwordMatch

        function submit() {
            if (!d.submitEnabled) {
                return
            }
            root.startupStore.doPrimaryAction()
        }
    }

    ColumnLayout {
        id: view
        spacing: Style.current.bigPadding
        height: 460
        anchors.centerIn: parent

        PasswordConfirmationView {
            id: passwordView

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Style.current.bigPadding

            expectedPassword: root.startupStore.getPassword()

            onSubmit: {
                d.submit()
            }
        }

        StatusButton {
            id: submitBtn
            objectName: "confirmPswSubmitBtn"
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Finalise Status Password Creation")
            enabled: d.submitEnabled

            onClicked: {
                d.submit()
            }
        }
    }
}
