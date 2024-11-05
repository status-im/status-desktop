import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0

import utils 1.0

KeycardBasePage {
    id: root

    required property string keycardState // Constants.startupState.keycardXXX
    property bool displayPromoBanner

    signal reloadKeycardRequested()
    signal keycardFactoryResetRequested()
    signal loginWithKeycardRequested()

    signal emptyKeycardDetected()

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
            id: btnLogin
            text: qsTr("Log in with this Keycard")
            onClicked: root.loginWithKeycardRequested()
        },
        MaybeOutlineButton {
            id: btnFactoryReset
            text: qsTr("Factory reset Keycard")
            onClicked: root.keycardFactoryResetRequested()
        },
        MaybeOutlineButton {
            id: btnReload
            text: qsTr("I’ve inserted a Keycard")
            onClicked: root.reloadKeycardRequested()
        }
    ]

    // inside a Column (or another Positioner), make all but the first button outline
    component MaybeOutlineButton: StatusButton {
        id: maybeOutlineButton
        width: 320
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        Binding on normalColor {
            value: "transparent"
            when: !maybeOutlineButton.Positioner.isFirstItem
            restoreMode: Binding.RestoreBindingOrValue
        }
        Binding on borderWidth {
            value: 1
            when: !maybeOutlineButton.Positioner.isFirstItem
            restoreMode: Binding.RestoreBindingOrValue
        }
        Binding on borderColor {
            value: Theme.palette.baseColor2
            when: !maybeOutlineButton.Positioner.isFirstItem
            restoreMode: Binding.RestoreBindingOrValue
        }
    }

    states: [
        // normal/intro states
        State {
            name: "plugin"
            when: root.keycardState === Constants.startupState.keycardPluginReader ||
                  root.keycardState === ""
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
            when: root.keycardState === Constants.startupState.keycardInsertKeycard
            PropertyChanges {
                target: root
                title: qsTr("Insert your Keycard")
                infoText.text: qsTr("Need a little %1?").arg(Utils.getStyledLink(qsTr("help"), "https://keycard.tech/docs/", infoText.hoveredLink,
                                                                                 Theme.palette.baseColor1, Theme.palette.primaryColor1))
                image.source: Theme.png("onboarding/keycard/insert")
            }
        },
        State {
            name: "reading"
            when: root.keycardState === Constants.startupState.keycardReadingKeycard ||
                  root.keycardState === Constants.startupState.keycardInsertedKeycard
            PropertyChanges {
                target: root
                title: qsTr("Reading Keycard...")
                image.source: Theme.png("onboarding/keycard/reading")
            }
        },
        // error states
        State {
            name: "error"
            PropertyChanges {
                target: root
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
            name: "notKeycard"
            extend: "error"
            when: root.keycardState === Constants.startupState.keycardWrongKeycard ||
                  root.keycardState === Constants.startupState.keycardNotKeycard
            PropertyChanges {
                target: root
                title: qsTr("Oops this isn’t a Keycard")
                subtitle: qsTr("Remove card and insert a Keycard")
                image.source: Theme.png("onboarding/keycard/invalid")
            }
            PropertyChanges {
                target: btnFactoryReset
                visible: false
            }
        },
        State {
            name: "occupied"
            extend: "error"
            when: root.keycardState === Constants.startupState.keycardMaxPairingSlotsReached
            PropertyChanges {
                target: root
                title: qsTr("All pairing slots occupied")
                subtitle: qsTr("Factory reset this Keycard or insert a different one")
            }
        },
        State {
            name: "locked"
            extend: "error"
            when: root.keycardState === Constants.startupState.keycardLocked
            PropertyChanges {
                target: root
                title: qsTr("Keycard locked")
                subtitle: qsTr("The Keycard you have inserted is locked, you will need to factory reset it or insert a different one")
            }
        },
        State {
            name: "notEmpty"
            extend: "error"
            when: root.keycardState === Constants.startupState.keycardNotEmpty
            PropertyChanges {
                target: root
                title: qsTr("Keycard is not empty")
                subtitle: qsTr("You can’t use it to store new keys right now")
            }
            PropertyChanges {
                target: btnLogin
                visible: true
            }
        },
        // success/exit state
        State {
            name: "emptyDetected"
            when: root.keycardState === Constants.startupState.keycardEmpty
            StateChangeScript {
                script: root.emptyKeycardDetected()
            }
        }
    ]
}
