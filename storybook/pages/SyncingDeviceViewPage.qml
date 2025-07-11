import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ

import Models
import Storybook

import utils
import shared.views

SplitView {
    id: root

    orientation: Qt.Vertical

    ListModel {
        id: deviceModel
        ListElement {
            name: "Device 1"
            deviceType: "osx"
            timestamp: 0
            isCurrentDevice: true
            enabled: true
            installationId: "a"
        }
        ListElement {
            name: "Device 2"
            deviceType: "windows"
            timestamp: 785957929539634639
            isCurrentDevice: false
            enabled: false
            installationId: "b"
        }
        ListElement {
            name: "Device 3"
            deviceType: "android"
            timestamp: 3456541235346346322
            isCurrentDevice: false
            enabled: true
            installationId: "c"
        }
        ListElement {
            name: "Device 4 (very long device name that should eventually elide)"
            deviceType: "ios"
            timestamp: 385657929539634639
            isCurrentDevice: false
            enabled: true
            installationId: "d"
        }
        ListElement {
            name: "Device 5"
            deviceType: "desktop"
            timestamp: 0
            isCurrentDevice: false
            enabled: true
            installationId: "e"
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        SyncingDeviceView {
            anchors.centerIn: parent
            userDisplayName: ctrlUsername.text
            userPublicKey: "0xdeadbeef"
            userImage: ModelsData.icons.status
            localPairingState: ctrlLocalPairingState.currentIndex
            localPairingError: "The unexpected happened"

            installationId: "a"
            installationName: "DummyDevice"
            installationDeviceType: ctrlDeviceType.currentValue

            devicesModel: ctrlWithDevices.checked ? deviceModel : null
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 250
        SplitView.preferredHeight: 250

        SplitView.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true
            Switch {
                id: ctrlWithDevices
                text: "With devices list"
                checked: true
            }
            RowLayout {
                Label {
                    text: "Pairing state:\t"
                }
                ComboBox {
                    Layout.preferredWidth: 270
                    id: ctrlLocalPairingState
                    currentIndex: 0
                    model: ["Constants.LocalPairingState.Idle", "Constants.LocalPairingState.Transferring",
                        "Constants.LocalPairingState.Error", "Constants.LocalPairingState.Finished"]
                }
            }
            RowLayout {
                Label {
                    text: "User name:\t"
                }
                TextField {
                    Layout.preferredWidth: 270
                    id: ctrlUsername
                    text: "Foobar"
                    placeholderText: "User display name"
                }
            }
            RowLayout {
                Label {
                    text: "Device type:\t"
                }
                ComboBox {
                    Layout.preferredWidth: 270
                    id: ctrlDeviceType
                    currentIndex: 0
                    model: ["desktop", "android", "windows", "ios", "osx"]
                }
            }
        }
    }
}

// category: Views
// status: good
