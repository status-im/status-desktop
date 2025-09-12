import QtQuick

import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Onboarding.controls

KeycardBasePage {
    id: root

    signal createReplacementKeycardRequested()
    signal useProfileWithoutKeycardRequested()

    title: qsTr("Lost Keycard")
    subtitle: qsTr("Sorry you've lost your Keycard")
    image.source: Theme.png("onboarding/keycard/empty")

    buttons: [
        StatusButton {
            objectName: "createReplacementButton"
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Create replacement Keycard using the same recovery phrase")
            onClicked: root.createReplacementKeycardRequested()
        },
        StatusButton {
            objectName: "startUsingWithoutKeycardButton"
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Start using this profile without Keycard")
            onClicked: root.useProfileWithoutKeycardRequested()
        }
    ]

    StatusButton {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 28

        isOutline: true

        size: StatusBaseButton.Size.Small
        text: qsTr("Order a new Keycard")
        icon.name: "external-link"
        icon.width: 24
        icon.height: 24
        onClicked: openLink("https://keycard.tech/")
    }
}
