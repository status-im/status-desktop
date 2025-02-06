import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0

KeycardBasePage {
    id: root

    signal createProfileWithEmptyKeycardRequested()

    title: qsTr("Keycard is empty")
    subtitle: qsTr("There is no profile key pair on this Keycard")
    image.source: Theme.png("onboarding/keycard/error")

    buttons: [
        MaybeOutlineButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Create new profile on this Keycard")
            onClicked: root.createProfileWithEmptyKeycardRequested()
        }
    ]
}
