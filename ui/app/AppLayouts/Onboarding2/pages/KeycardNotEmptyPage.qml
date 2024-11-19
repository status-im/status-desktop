import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0

KeycardBasePage {
    id: root

    signal reloadKeycardRequested()
    signal loginWithThisKeycardRequested()
    signal keycardFactoryResetRequested()

    title: qsTr("Keycard is not empty")
    subtitle: qsTr("You can’t use it to store new keys right now")
    image.source: Theme.png("onboarding/keycard/error")

    pageClassName: "KeycardNotEmptyPage"

    buttons: [
        MaybeOutlineButton {
            id: btnReload
            text: qsTr("I’ve inserted a Keycard")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.reloadKeycardRequested()
        },
        MaybeOutlineButton {
            id: btnLogin
            text: qsTr("Log in with this Keycard")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.loginWithThisKeycardRequested()
        },
        MaybeOutlineButton {
            id: btnFactoryReset
            text: qsTr("Factory reset Keycard")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.keycardFactoryResetRequested()
        }
    ]
}
