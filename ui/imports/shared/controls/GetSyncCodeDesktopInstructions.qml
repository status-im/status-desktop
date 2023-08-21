import QtQuick 2.0
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.views 1.0

Column {
    id: root

    property int type: SyncingCodeInstructions.Type.AppSync

    spacing: 4

    QtObject {
        id: d
        readonly property int listItemHeight: 40
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("1. Open Status App on your desktop device")
        }
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("2. Open")
        }
        StatusRoundIcon {
            asset.name: "settings"
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.directColor1
            text: qsTr("Settings")
        }
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("3. Navigate to the ")
        }
        StatusRoundIcon {
            asset.name: {
                if (root.type === SyncingCodeInstructions.Type.KeypairSync) {
                    return "wallet"
                }
                return "rotate"
            }
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: {
                if (root.type === SyncingCodeInstructions.Type.KeypairSync) {
                    return qsTr("Wallet tab")
                }
                return qsTr("Syncing tab")
            }
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("4. Click")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: {
                if (root.type === SyncingCodeInstructions.Type.KeypairSync) {
                    return qsTr("Import missing keypairs")
                }
                return qsTr("Setup Syncing")
            }
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("5.")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("Enable camera")
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("on this device")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: {
                if (root.type === SyncingCodeInstructions.Type.KeypairSync) {
                    return qsTr("6. Scan or enter the encrypted key with this device")
                }
                return qsTr("6. Scan or enter the code")
            }
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }
    }
}
