import QtQuick
import QtQuick.Layouts

import StatusQ.Core.Theme
import StatusQ.Core

import shared.controls
import shared.views

ColumnLayout {
    id: root

    property int purpose: SyncingCodeInstructions.Purpose.AppSync
    property int type: SyncingCodeInstructions.Type.QRCode

    QtObject {
        id: d

        readonly property int itemHeight: 32
    }

    spacing: Theme.padding

    StatusBaseText {
        Layout.preferredHeight: d.itemHeight
        Layout.fillWidth: true
        Layout.fillHeight: true

        verticalAlignment: Text.AlignVCenter
        text: "1. " + qsTr("Ensure both devices are on the same network")
        color: Theme.palette.baseColor1
        wrapMode: Text.WordWrap
    }

    StatusBaseText {
        Layout.preferredHeight: d.itemHeight
        Layout.fillWidth: true

        verticalAlignment: Text.AlignVCenter
        text: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                return "2. " + qsTr("Open Status on the device you want to import from")
            }
            return "2. " + qsTr("Open Status App on your desktop device")
        }
        color: Theme.palette.baseColor1
        wrapMode: Text.WordWrap
    }

    // TODO: To improve. It's not responsive
    DecoratedListItem {
        Layout.preferredHeight: d.itemHeight
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true

        order: "3."
        text1: qsTr("Open")
        icon: "settings"
        text2: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                return qsTr("Settings / Wallet")
            }
            return qsTr("Settings")
        }
        text2Color: Theme.palette.directColor1
    }

    // TODO: To improve. It's not responsive
    DecoratedListItem {
        Layout.preferredHeight: d.itemHeight
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true

        order: "4."
        text1: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                return qsTr("Click")
            }
            return qsTr("Navigate to the")
        }
        icon: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                return ""
            }
            return "rotate"
        }
        text2: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                return qsTr("Show encrypted QR of key pairs on this device")
            }
            return qsTr("Syncing tab")
        }
        text2Color: Theme.palette.directColor1
    }

    StatusBaseText {
        readonly property string text1: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return "5. " + qsTr("Copy the")
                }
                return "5. " + qsTr("Scan QR")
            }
            return "5. " + qsTr("Click")
        }
        readonly property color text1Color: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return Theme.palette.baseColor1
                }
                return Theme.palette.directColor1
            }
            return Theme.palette.baseColor1
        }
        readonly property string text2: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return qsTr("encrypted key pairs code")
                }
                return qsTr("on this device")
            }
            return qsTr("Setup Syncing")
        }
        readonly property color text2Color: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return Theme.palette.directColor1
                }
                return Theme.palette.baseColor1
            }
            return Theme.palette.directColor1
        }

        Layout.preferredHeight: d.itemHeight
        Layout.fillWidth: true

        verticalAlignment: Text.AlignVCenter
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        color: text1Color
        text: qsTr("%1 %2").arg(qsTr(text1))
                           .arg("<span style='color:" + text2Color + ";'>" + qsTr(text2) + "</span>")

    }

    StatusBaseText {
        readonly property string text1: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return "6. " + qsTr("Paste the")
                }
                return "6. " + qsTr("Scan or enter the encrypted QR with this device")
            }
            return "6. "
        }
        readonly property string text2: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return qsTr("encrypted key pairs code")
                }
                return ""
            }
            return qsTr("Scan QR")
        }
        readonly property string text3: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return qsTr("to this device")
                }
                return ""
            }
            return qsTr("on this device")
        }

        Layout.preferredHeight: d.itemHeight
        Layout.fillWidth: true

        verticalAlignment: Text.AlignVCenter
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        color: Theme.palette.baseColor1


        text: qsTr("%1 %2 %3").arg(qsTr(text1))
                              .arg("<span style='color:" + Theme.palette.directColor1 + ";'>" + qsTr(text2) + "</span>")
                              .arg(qsTr(text3))

    }

    StatusBaseText {
        Layout.preferredHeight: d.itemHeight
        Layout.fillWidth: true

        verticalAlignment: Text.AlignVCenter
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        color: Theme.palette.baseColor1

        readonly property string order: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return "7. "
                }
                return ""
            }
            return "7. "
        }
        readonly property string text1: {
            if (root.purpose === SyncingCodeInstructions.Purpose.KeypairSync) {
                if (root.type === SyncingCodeInstructions.Type.EncryptedKey) {
                    return qsTr("For security, delete the code as soon as you are done")
                }
                return ""
            }
            return qsTr("Scan or enter the code")
        }
        text: order + text1
    }
}
