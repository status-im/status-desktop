import QtQuick

import StatusQ.Core.Theme

import AppLayouts.Onboarding.controls

KeycardBasePage {
    id: root

    signal createProfileWithEmptyKeycardRequested()

    title: qsTr("Keycard is empty")
    subtitle: qsTr("There is no profile key pair on this Keycard")
    image.source: Assets.png("onboarding/keycard/error")

    buttons: [
        MaybeOutlineButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Create new profile on this Keycard")
            onClicked: root.createProfileWithEmptyKeycardRequested()
        }
    ]
}
