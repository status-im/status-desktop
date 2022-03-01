import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12


import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import "../views"

StatusModal {
    id: root

    property var privacyStore
    signal passwordChanged()

    function onChangePasswordResponse(success) {
        if (success) {
            passwordChanged()
            submitBtn.enabled = false
        } else {
            view.reset()
            console.warn("TODO: Display error message when change password action failure! ")
        }
        submitBtn.loading = false
    }

    Connections {
        target: root.privacyStore.privacyModule
        onPasswordChanged: onChangePasswordResponse(success)
    }

    width: 480
    height: 546
    closePolicy: Popup.NoAutoClose
    header.title: qsTr("Change password")

    onOpened: view.reset()

    PasswordView {
        id: view
        anchors.topMargin: Style.current.padding
        anchors.centerIn: parent
        titleVisible: false
        introText: qsTr("Change password used to unlock Status on this device & sign transactions.")
        createNewPsw: false
    }

    rightButtons: [
        StatusButton {
            id: submitBtn
            text: qsTr("Change Password")
            enabled: !submitBtn.loading && view.ready

            property Timer sim: Timer {
                id: pause
                interval: 20
                onTriggered: {
                    // Change current password call action to the backend
                    root.privacyStore.changePassword(view.currentPswText, view.newPswText)
                }
            }

            onClicked: {
                submitBtn.loading = true;
                // ChangePassword operation blocks the UI so loading = true; will never have any affect until changePassword/createPassword is done.
                // Getting around it with a small pause (timer) in order to get the desired behavior
                pause.start();
            }
        }
    ]

    // By clicking anywhere outside password entries fields or focusable element in the view, it is needed to check if passwords entered matches
    MouseArea {
        anchors.fill: parent
        z: view.zBehind // Behind focusable components in the view
        onClicked: { view.checkPasswordMatches() }
    }
}
