import QtQuick

import StatusQ.Core.Theme

import AppLayouts.Onboarding.controls

KeycardBasePage {
    id: root

    signal loginWithThisKeycardRequested()
    signal keycardFactoryResetRequested()

    title: qsTr("Keycard is not empty")
    subtitle: qsTr("You can’t use it to store new keys right now")
    image.source: Theme.png("onboarding/keycard/error")

    buttons: [
        MaybeOutlineButton {
            text: qsTr("Log in with this Keycard")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.loginWithThisKeycardRequested()
        },
        MaybeOutlineButton {
            text: qsTr("Factory reset Keycard")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.keycardFactoryResetRequested()
        }
    ]
}
