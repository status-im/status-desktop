import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
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
        d.forcePasswordInputFocus()
    }

    QtObject {
        id: d
        readonly property int zBehind: 1
        readonly property int zFront: 100

        function submit() {
            root.startupStore.setDefaultWalletEmoji(StatusQUtils.Emoji.getRandomEmoji(StatusQUtils.Emoji.size.verySmall))
            root.startupStore.setPassword(view.newPswText)
            root.startupStore.doPrimaryAction()
        }

        function forcePasswordInputFocus() { view.forceNewPswInputFocus() }
    }

    ColumnLayout {
        spacing: Style.current.bigPadding
        anchors.centerIn: parent
        height: 460
        z: view.zFront
        PasswordView {
            id: view
            Layout.preferredWidth: root.width - 2 * Style.current.bigPadding
            Layout.fillHeight: true
            passwordStrengthScoreFunction: root.startupStore.getPasswordStrengthScore
            highSizeIntro: true
            onReturnPressed: { if(view.ready) d.submit() }
        }
        StatusButton {
            id: submitBtn
            objectName: "onboardingCreatePasswordButton"
            z: d.zFront
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Create password")
            enabled: view.ready
            onClicked: { d.submit() }
        }
    }
}
