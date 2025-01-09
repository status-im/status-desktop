import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0
import AppLayouts.Onboarding.enums 1.0

import utils 1.0

KeycardBasePage {
    id: root

    required property int keycardState // cf Onboarding.KeycardState
    property bool displayPromoBanner
    property bool unlockUsingSeedphrase

    signal keycardFactoryResetRequested()
    signal unlockWithSeedphraseRequested()
    signal reloadKeycardRequested()
    signal emptyKeycardDetected()
    signal notEmptyKeycardDetected()

    pageClassName: "KeycardIntroPage"

    OnboardingFrame {
        id: promoBanner
        visible: false
        dropShadow: false
        cornerRadius: 12
        width: 600
        leftPadding: 0
        rightPadding: 20
        topPadding: Theme.halfPadding
        bottomPadding: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.bigPadding

        contentItem: RowLayout {
            spacing: 0
            StatusImage {
                Layout.bottomMargin: -2
                Layout.preferredWidth: 154
                Layout.preferredHeight: 82
                source: Theme.png("onboarding/status_keycard_multiple")
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: -promoBanner.topPadding
                spacing: 2
                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("New to Keycard?")
                    font.pixelSize: Theme.additionalTextSize
                    font.weight: Font.DemiBold
                }
                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("Store and trade your crypto with a simple, secure and slim hardware wallet.")
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.additionalTextSize
                    color: Theme.palette.baseColor1
                }
            }
            StatusButton {
                Layout.leftMargin: 20
                Layout.topMargin: -promoBanner.topPadding
                size: StatusBaseButton.Size.Small
                text: qsTr("keycard.tech")
                icon.name: "external-link"
                icon.width: 24
                icon.height: 24
                onClicked: openLink("https://keycard.tech/")
            }
        }
    }

    buttons: [
        MaybeOutlineButton {
            id: btnFactoryReset
            visible: false
            text: qsTr("Factory reset Keycard")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.keycardFactoryResetRequested()
        },
        MaybeOutlineButton {
            id: btnUnlockWithSeedphrase
            visible: false
            text: qsTr("Unlock with recovery phrase")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.unlockWithSeedphraseRequested()
        },
        MaybeOutlineButton {
            id: btnReload
            visible: false
            text: qsTr("I’ve inserted a different Keycard")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.reloadKeycardRequested()
        }
    ]

    states: [
        // normal/intro states
        State {
            name: "plugin"
            when: root.keycardState === Onboarding.KeycardState.PluginReader ||
                  root.keycardState === -1
            PropertyChanges {
                target: root
                title: qsTr("Plug in your Keycard reader")
                image.source: Theme.png("onboarding/keycard/empty")
            }
            PropertyChanges {
                target: promoBanner
                visible: root.displayPromoBanner
            }
        },
        State {
            name: "insert"
            when: root.keycardState === Onboarding.KeycardState.InsertKeycard
            PropertyChanges {
                target: root
                title: qsTr("Insert your Keycard")
                infoText.text: qsTr("Get help via %1 🔗").arg(Utils.getStyledLink("https://keycard.tech", "https://keycard.tech/docs/",
                                                                                infoText.hoveredLink,
                                                                                Theme.palette.baseColor1,
                                                                                Theme.palette.primaryColor1))
                image.source: Theme.png("onboarding/keycard/insert")
            }
        },
        State {
            name: "reading"
            when: root.keycardState === Onboarding.KeycardState.ReadingKeycard
            PropertyChanges {
                target: root
                title: qsTr("Reading Keycard...")
                image.source: Theme.png("onboarding/keycard/reading")
            }
        },
        // error states
        State {
            name: "notKeycard"
            when: root.keycardState === Onboarding.KeycardState.WrongKeycard ||
                  root.keycardState === Onboarding.KeycardState.NotKeycard
            PropertyChanges {
                target: root
                title: qsTr("Oops this isn’t a Keycard")
                subtitle: qsTr("Remove card and insert a Keycard")
                image.source: Theme.png("onboarding/keycard/invalid")
            }
            PropertyChanges {
                target: btnReload
                visible: true
                text: qsTr("I’ve inserted a Keycard")
            }
        },
        State {
            name: "noService"
            when: root.keycardState === Onboarding.KeycardState.NoPCSCService
            PropertyChanges {
                target: root
                title: qsTr("Smartcard reader service unavailable")
                subtitle: qsTr("The Smartcard reader service (PCSC service), required for using Keycard, is not currently working. Ensure PCSC is installed and running and try again.")
                image.source: Theme.png("onboarding/keycard/error")
            }
            PropertyChanges {
                target: btnReload
                visible: true
                text: qsTr("Retry")
            }
        },
        State {
            name: "occupied"
            when: root.keycardState === Onboarding.KeycardState.MaxPairingSlotsReached
            PropertyChanges {
                target: root
                title: qsTr("All pairing slots occupied")
                subtitle: qsTr("Factory reset this Keycard or insert a different one")
                image.source: Theme.png("onboarding/keycard/error")
            }
            PropertyChanges {
                target: btnFactoryReset
                visible: true
            }
            PropertyChanges {
                target: btnReload
                visible: true
            }
        },
        State {
            name: "locked"
            when: root.keycardState === Onboarding.KeycardState.Locked
            PropertyChanges {
                target: root
                title: "<font color='%1'>".arg(Theme.palette.dangerColor1) + qsTr("Keycard locked") + "</font>"
                subtitle: root.unlockUsingSeedphrase ? qsTr("The Keycard you have inserted is locked, you will need to unlock it using the recovery phrase or insert a different one")
                                                     : qsTr("The Keycard you have inserted is locked, you will need to factory reset it or insert a different one")
                image.source: Theme.png("onboarding/keycard/error")
            }
            PropertyChanges {
                target: btnFactoryReset
                visible: !root.unlockUsingSeedphrase
            }
            PropertyChanges {
                target: btnUnlockWithSeedphrase
                visible: root.unlockUsingSeedphrase
            }
            PropertyChanges {
                target: btnReload
                visible: true
            }
        },
        // exit states
        State {
            name: "empty"
            when: root.keycardState === Onboarding.KeycardState.Empty
            StateChangeScript {
                script: root.emptyKeycardDetected()
            }
        },
        State {
            name: "notEmpty"
            when: root.keycardState === Onboarding.KeycardState.NotEmpty
            StateChangeScript {
                script: root.notEmptyKeycardDetected()
            }
        }
    ]
}
