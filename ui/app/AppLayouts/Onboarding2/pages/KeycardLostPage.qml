import QtQuick 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0

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
            width: 486
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Create replacement Keycard using the same recovery phrase")
            onClicked: root.createReplacementKeycardRequested()
        },
        StatusButton {
            objectName: "startUsingWithoutKeycardButton"
            width: 486
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
