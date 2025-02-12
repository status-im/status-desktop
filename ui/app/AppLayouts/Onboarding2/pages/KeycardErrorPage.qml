import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0

KeycardBasePage {
    id: root

    signal tryAgainRequested()
    signal factoryResetRequested()

    title: qsTr("Communication with Keycard lost")
    subtitle: qsTr("There seems to be an issue communicating with your Keycard. Reinsert the card or reader and try again.")
    image.source: Theme.png("onboarding/keycard/error")

    buttons: [
        MaybeOutlineButton {
            text: qsTr("Try again")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.tryAgainRequested()
        },
        MaybeOutlineButton {
            text: qsTr("Factory reset Keycard")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.factoryResetRequested()
        }
    ]
}
