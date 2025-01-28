import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0
import AppLayouts.Onboarding.enums 1.0

OnboardingPage {
    id: root

    required property int addKeyPairState // Onboarding.AddKeyPairState.xxx

    signal keypairAddContinueRequested()
    signal keypairAddTryAgainRequested()
    signal reloadKeycardRequested()
    signal createProfilePageRequested()

    states: [
        State {
            name: "inprogress"
            when: root.addKeyPairState === Onboarding.AddKeyPairState.InProgress
            PropertyChanges {
                target: root
                title: qsTr("Adding key pair to Keycard")
            }
            PropertyChanges {
                target: iconLoader
                sourceComponent: loadingIndicator
            }
            PropertyChanges {
                target: subImageText
                text: qsTr("Please keep the Keycard plugged in until the migration is complete")
                visible: true
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/status_keycard_adding_keypair")
            }
        },
        State {
            name: "success"
            when: root.addKeyPairState === Onboarding.AddKeyPairState.Success
            PropertyChanges {
                target: root
                title: qsTr("Key pair added to Keycard")
            }
            PropertyChanges {
                target: subtitle
                text: qsTr("You will now require this Keycard to log into Status and transact with any accounts derived from this key pair")
            }
            PropertyChanges {
                target: iconLoader
                sourceComponent: successIcon
            }
            PropertyChanges {
                target: continueButton
                visible: true
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/status_keycard_adding_keypair_success")
            }
        },
        State {
            name: "failed"
            when: root.addKeyPairState === Onboarding.AddKeyPairState.Failed
            PropertyChanges {
                target: root
                title: "<font color='%1'>".arg(Theme.palette.dangerColor1) + qsTr("Failed to add key pair to Keycard") + "</font>"
            }
            PropertyChanges {
                target: subtitle
                text: qsTr("Something went wrong...")
            }
            PropertyChanges {
                target: iconLoader
                sourceComponent: failedIcon
            }
            PropertyChanges {
                target: buttonColumn
                visible: true
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/status_keycard_adding_keypair_failed")
            }
        }
    ]

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(350, root.availableWidth)
            spacing: Theme.halfPadding

            Loader {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                id: iconLoader
            }

            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                text: root.title
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                id: subtitle
                Layout.fillWidth: true
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                visible: !!text
            }

            StatusImage {
                id: image
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(231, parent.width)
                Layout.preferredHeight: Math.min(211, height)
                Layout.topMargin: Theme.bigPadding
                Layout.bottomMargin: Theme.bigPadding
                source: Theme.png("onboarding/status_keycard_adding_keypair")
                mipmap: true
            }

            StatusBaseText {
                id: subImageText
                Layout.fillWidth: true
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                visible: false
            }

            StatusButton {
                objectName: "btnContinue"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 240
                id: continueButton
                text: qsTr("Continue")
                visible: false
                onClicked: root.keypairAddContinueRequested()
            }

            Column {
                id: buttonColumn
                Layout.preferredWidth: 280
                Layout.alignment: Qt.AlignHCenter
                spacing: 12
                visible: false

                StatusButton {
                    width: parent.width
                    text: qsTr("Try again")
                    onClicked: root.keypairAddTryAgainRequested()
                }
                StatusButton {
                    text: qsTr("I've inserted a different Keycard")
                    width: parent.width
                    isOutline: true
                    onClicked: root.reloadKeycardRequested()
                }
                StatusButton {
                    text: qsTr("Create profile without Keycard")
                    width: parent.width
                    isOutline: true
                    onClicked: root.createProfilePageRequested()
                }
            }
        }
    }

    Component {
        id: loadingIndicator
        Rectangle {
            color: Theme.palette.baseColor2
            radius: width/2
            StatusDotsLoadingIndicator {
                anchors.centerIn: parent
            }
        }
    }

    Component {
        id: successIcon
        StatusRoundIcon {
            asset.name: "check-circle"
            asset.color: Theme.palette.successColor1
            asset.bgColor: Theme.palette.successColor2
        }
    }

    Component {
        id: failedIcon
        StatusRoundIcon {
            asset.name: "close-circle"
            asset.color: Theme.palette.dangerColor1
            asset.bgColor: Theme.palette.dangerColor3
        }
    }
}
