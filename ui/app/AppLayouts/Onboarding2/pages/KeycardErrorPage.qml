import QtQuick

import StatusQ.Core.Theme

import AppLayouts.Onboarding2.controls

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
