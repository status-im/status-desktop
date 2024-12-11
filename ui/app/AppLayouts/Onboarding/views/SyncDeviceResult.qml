import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.views 1.0
import utils 1.0

import "../stores"
import "../../Profile/stores"

Item {
    id: root

    property StartupStore startupStore

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    QtObject {
        id: d
        readonly property bool finished: startupStore.localPairingState === Constants.LocalPairingState.Finished
        readonly property bool pairingFailed: startupStore.localPairingState === Constants.LocalPairingState.Error
    }

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 24

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 22
            font.weight: Font.Bold
            color: Theme.palette.directColor1
            text: qsTr("Log in by syncing")
        }

        SyncingDeviceView {
            Layout.alignment: Qt.AlignHCenter

            localPairingState: startupStore.localPairingState
            localPairingError: startupStore.localPairingError

            userDisplayName: startupStore.localPairingName
            userImage: startupStore.localPairingImage
            userColorId: startupStore.localPairingColorId
            userColorHash: startupStore.localPairingColorHash

            installationId: startupStore.localPairingInstallationId
            installationName: startupStore.localPairingInstallationName
            installationDeviceType: startupStore.localPairingInstallationDeviceType
        }

        StatusButton {
            visible: d.pairingFailed
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Use recovery phrase")
            onClicked: root.startupStore.doSecondaryAction()
        }

        StatusFlatButton {
            visible: d.pairingFailed
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Try again")
            onClicked: root.startupStore.doTertiaryAction()
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Sign in")
            opacity: d.finished ? 1 : 0
            enabled: d.finished

            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }

            onClicked: {
                root.startupStore.doPrimaryAction()
            }
        }
    }

}
