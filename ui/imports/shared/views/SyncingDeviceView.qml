import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import shared.controls
import shared.controls.chat
import utils

import SortFilterProxyModel

Item {
    id: root

    property var devicesModel
    property string userDisplayName
    property bool usesDefaultName
    property int userColorId
    property string userPublicKey
    property string userImage
    property string installationId
    property string installationName
    property string installationDeviceType

    property int localPairingState: Constants.LocalPairingState.Idle
    property string localPairingError

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    QtObject {
        id: d

        readonly property bool pairingFailed: root.localPairingState === Constants.LocalPairingState.Error
        readonly property bool pairingSuccess: root.localPairingState === Constants.LocalPairingState.Finished
        readonly property bool pairingInProgress: !d.pairingFailed && !d.pairingSuccess
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: 0

        StatusUserImage {
            Layout.alignment: Qt.AlignHCenter
            name: root.userDisplayName
            usesDefaultName: root.usesDefaultName
            userColor: Utils.colorForColorId(root.userColorId)
            image: root.userImage
            interactive: false
            imageWidth: 80
            imageHeight: 80
            loading: name === ""
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: Theme.halfPadding
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.directColor1
            font.weight: Font.Bold
            font.pixelSize: Theme.fontSize(22)
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            text: root.userDisplayName
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: Theme.xlPadding
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSize(22)
            color: d.pairingFailed ? Theme.palette.dangerColor1 : Theme.palette.directColor1
            text: {
                if (d.pairingInProgress)
                    return qsTr("Device found!");
                if (d.pairingSuccess)
                    return qsTr("Device synced!");
                if (d.pairingFailed)
                    return qsTr("Device failed to sync");
                return "";
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.bottomMargin: Theme.bigPadding
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.baseColor1
            visible: !!text
            text: {
                if (d.pairingInProgress)
                    return qsTr("Syncing your profile and settings preferences");
                if (d.pairingSuccess)
                    return qsTr("Your devices are now in sync");
                return "";
            }
        }

        StatusSyncDeviceDelegate {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            visible: !d.pairingFailed
            subTitle: d.pairingInProgress ? qsTr("Syncing with device")
                                          : qsTr("Synced device")
            enabled: false
            loading: d.pairingInProgress
            loadingSubTitle: false
            deviceName: root.installationName
            deviceType: root.installationDeviceType
            isCurrentDevice: false
            showOnlineBadge: false
        }

        ErrorDetails {
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 60
            Layout.rightMargin: 60
            Layout.preferredWidth: 360
            Layout.topMargin: 12
            visible: d.pairingFailed
            title: qsTr("Failed to sync devices")
            details: root.localPairingError
        }

        Rectangle {
            Layout.topMargin: Theme.bigPadding
            Layout.bottomMargin: Theme.bigPadding
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.palette.baseColor4
            opacity: listView.count ? 1 : 0
        }

        StatusListView {
            id: listView

            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: contentHeight

            spacing: 4
            clip: true

            model: SortFilterProxyModel {
                sourceModel: root.devicesModel
                filters: [
                    ValueFilter {
                        enabled: true
                        roleName: "installationId"
                        value: root.installationId
                        inverted: true
                    }
                ]
            }

            delegate: StatusSyncDeviceDelegate {
                width: ListView.view.width
                enabled: false
                deviceName: model.name
                deviceType: model.deviceType
                timestamp: model.timestamp
                isCurrentDevice: model.isCurrentDevice
            }
        }
    }
}
