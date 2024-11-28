import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

OnboardingPage {
    id: root

    required property int addKeyPairState // KeycardAddKeyPairPage.AddKeyPairState.xxx
    property int timeoutInterval: 30000

    enum AddKeyPairState {
        InProgress,
        Success,
        Failed
    }

    signal keypairAddContinueRequested()
    signal keypairAddTryAgainRequested()

    pageClassName: "KeycardAddKeyPairPage"

    Timer {
        id: timer
        interval: root.timeoutInterval
        running: root.addKeyPairState === KeycardAddKeyPairPage.AddKeyPairState.InProgress
        onTriggered: root.addKeyPairState = KeycardAddKeyPairPage.AddKeyPairState.Failed
    }

    states: [
        State {
            name: "inprogress"
            when: root.addKeyPairState === KeycardAddKeyPairPage.AddKeyPairState.InProgress
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
        },
        State {
            name: "success"
            when: root.addKeyPairState === KeycardAddKeyPairPage.AddKeyPairState.Success
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
        },
        State {
            name: "failed"
            when: root.addKeyPairState === KeycardAddKeyPairPage.AddKeyPairState.Failed
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
                target: tryAgainButton
                visible: true
            }
        }
    ]

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(400, root.availableWidth)
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
                Layout.preferredWidth: Math.min(185, parent.width)
                Layout.preferredHeight: Math.min(314, height)
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
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 240
                id: continueButton
                text: qsTr("Continue")
                visible: false
                onClicked: root.keypairAddContinueRequested()
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 240
                id: tryAgainButton
                text: qsTr("Try again")
                visible: false
                onClicked: root.keypairAddTryAgainRequested()
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
