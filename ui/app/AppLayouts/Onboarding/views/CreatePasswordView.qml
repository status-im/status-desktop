import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import utils 1.0
import shared.views 1.0

import "../../Profile/views"
import "../controls"
import "../stores"

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        view.newPswText = root.startupStore.getPassword()
        view.confirmationPswText = root.startupStore.getPassword()
    }

    function forceNewPswInputFocus() { view.forceNewPswInputFocus() }

    QtObject {
        id: d
        readonly property int zBehind: 1
        readonly property int zFront: 100

        function submit() {
            root.startupStore.setPassword(view.newPswText)
            root.startupStore.doPrimaryAction()
        }
    }

    Column {
        spacing: 4 * Style.current.padding
        anchors.centerIn: parent
        z: view.zFront
        PasswordView {
            id: view
            passwordStrengthScoreFunction: root.startupStore.getPasswordStrengthScore
            onReturnPressed: { if(view.ready) d.submit() }
        }
        StatusButton {
            id: submitBtn
            z: d.zFront
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Create password")
            enabled: view.ready
            onClicked: { d.submit() }
        }
    }
}
