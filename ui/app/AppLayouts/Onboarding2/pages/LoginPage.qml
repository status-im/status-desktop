import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Onboarding2.controls 1.0

import utils 1.0

OnboardingPage {
    id: root

    title: qsTr("Log in")

    signal loginWithSeedphraseRequested()
    signal loginWithSyncingRequested()
    signal loginWithKeycardRequested()

    pageClassName: "LoginPage"

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(380, root.availableWidth)
            spacing: Theme.bigPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: -Theme.padding
                text: qsTr("How would you like to log in to Status?")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            OnboardingFrame {
                Layout.fillWidth: true
                contentItem: ColumnLayout {
                    spacing: 20
                    StatusImage {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(245, parent.width)
                        Layout.preferredHeight: Math.min(200, height)
                        source: Theme.png("onboarding/status_seedphrase")
                        mipmap: true
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        text: qsTr("Log in with recovery phrase")
                        font.pixelSize: Theme.secondaryAdditionalTextSize
                        font.bold: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        Layout.topMargin: -Theme.padding
                        text: qsTr("If you have your Status recovery phrase")
                        font.pixelSize: Theme.additionalTextSize
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.palette.baseColor1
                    }
                    StatusButton {
                        Layout.fillWidth: true
                        text: qsTr("Enter recovery phrase")
                        font.pixelSize: Theme.additionalTextSize
                        onClicked: root.loginWithSeedphraseRequested()
                    }
                }
            }

            OnboardingButtonFrame {
                Layout.fillWidth: true
                id: buttonFrame
                contentItem: ColumnLayout {
                    spacing: 0
                    ListItemButton {
                        Layout.fillWidth: true
                        text: qsTr("Log in by syncing")
                        subTitle: qsTr("If you have Status on another device")
                        icon.source: Theme.svg("mobile-sync") // FIXME correct icon
                        onClicked: loginWithSyncAck.createObject(root).open()
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: -buttonFrame.padding
                        Layout.rightMargin: -buttonFrame.padding
                        Layout.preferredHeight: 1
                        color: Theme.palette.statusMenu.separatorColor
                    }
                    ListItemButton {
                        Layout.fillWidth: true
                        text: qsTr("Log in with Keycard")
                        subTitle: qsTr("If your profile keys are stored on a Keycard")
                        icon.source: Theme.png("onboarding/create_profile_keycard")
                        onClicked: root.loginWithKeycardRequested()
                    }
                }
            }
        }
    }

    Component {
        id: loginWithSyncAck
        StatusDialog {
            title: qsTr("Log in by syncing")
            width: 480
            padding: 20
            destroyOnClose: true
            contentItem: ColumnLayout {
                spacing: 20
                StatusBaseText {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: qsTr("To pair your devices and sync your profile, make sure to check and complete the following steps:")
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.padding
                    StatusCheckBox {
                        Layout.fillWidth: true
                        id: ack1
                        text: qsTr("Connect both devices to the same network")
                    }
                    StatusCheckBox {
                        Layout.fillWidth: true
                        id: ack2
                        text: qsTr("Make sure you are logged in on the other device")
                    }
                    StatusCheckBox {
                        Layout.fillWidth: true
                        id: ack3
                        text: qsTr("Disable the firewall and VPN on both devices")
                    }
                }
            }
            footer: StatusDialogFooter {
                spacing: Theme.padding
                rightButtons: ObjectModel {
                    StatusFlatButton {
                        text: qsTr("Cancel")
                        onClicked: close()
                    }
                    StatusButton {
                        text: qsTr("Continue")
                        enabled: ack1.checked && ack2.checked && ack3.checked
                        onClicked: {
                            root.loginWithSyncingRequested()
                            close()
                        }
                    }
                }
            }
        }
    }
}
